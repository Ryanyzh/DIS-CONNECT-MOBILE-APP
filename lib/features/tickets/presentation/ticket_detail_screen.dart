import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/features/tickets/data/ticket_repository.dart';
import 'package:disconnect_mobile/features/tickets/widgets/ticket_status_badge.dart';

// Data models

class AttachmentFile {
  final String name;
  final int sizeKb;
  const AttachmentFile({required this.name, required this.sizeKb});

  factory AttachmentFile.fromJson(Map<String, dynamic> json) {
    final sizeBytes = (json['file_size'] ?? json['size_bytes'] ?? 0) as num;
    return AttachmentFile(
      name: (json['file_name'] ?? json['name'] ?? '').toString(),
      sizeKb: (sizeBytes / 1024).ceil(),
    );
  }
}

class TicketTask {
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const TicketTask({
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

class TicketDetailData {
  final String ticketCode;
  final String subject;
  final String category;
  final String? priority;
  final Color? priorityColor;
  // Status (from TicketStatus table)
  final String statusName;
  final String? statusType;
  final bool isClosed;
  // Content
  final String? description;
  final String? source;
  // Assigned officer (hr_profiles.assigned_to)
  final String? officerName;
  final String? officerRole;
  final String? officerInitials;
  // Escalation
  final bool isEscalated;
  final String? escalatedToName;
  final DateTime? escalatedAt;
  // Dates
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  // Attachments
  final List<AttachmentFile> attachments;

  const TicketDetailData({
    required this.ticketCode,
    required this.subject,
    required this.category,
    this.priority,
    this.priorityColor,
    required this.statusName,
    this.statusType,
    this.isClosed = false,
    this.description,
    this.source,
    this.officerName,
    this.officerRole,
    this.officerInitials,
    this.isEscalated = false,
    this.escalatedToName,
    this.escalatedAt,
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
    this.resolvedAt,
    this.closedAt,
    this.attachments = const [],
  });

  factory TicketDetailData.fromJson(Map<String, dynamic> json) {
    String resolveNested(dynamic field, String nameKey) {
      if (field is Map) return (field[nameKey] ?? '').toString();
      if (field is String) return field;
      return '';
    }

    final rawStatus = json['status'];
    final rawCategory = json['category'];
    final rawPriority = json['priority'];
    final rawOfficer = json['assigned_officer'] ?? json['assigned_to'];
    final rawEscalation = json['escalation'];

    final colorCode = rawPriority is Map
        ? rawPriority['color_code']?.toString()
        : json['priority_color']?.toString();

    final rawAttachments = (json['attachments'] as List?) ?? [];

    return TicketDetailData(
      ticketCode: (json['ticket_code'] ?? json['display_id'] ?? '').toString(),
      subject: (json['subject'] ?? json['title'] ?? '').toString(),
      category: resolveNested(rawCategory, 'category_name'),
      priority: resolveNested(rawPriority, 'priority_name').isEmpty
          ? null
          : resolveNested(rawPriority, 'priority_name'),
      priorityColor: _colorFromHex(colorCode),
      statusName: resolveNested(rawStatus, 'status_name'),
      statusType: rawStatus is Map
          ? rawStatus['status_type']?.toString()
          : json['status_type']?.toString(),
      isClosed:
          (rawStatus is Map ? rawStatus['is_closed'] : json['is_closed']) ==
          true,
      description: json['description']?.toString(),
      source: json['source']?.toString(),
      officerName: rawOfficer is Map
          ? rawOfficer['name']?.toString()
          : json['officer_name']?.toString(),
      officerRole: rawOfficer is Map
          ? rawOfficer['role']?.toString()
          : json['officer_role']?.toString(),
      officerInitials: rawOfficer is Map
          ? rawOfficer['initials']?.toString()
          : json['officer_initials']?.toString(),
      isEscalated: (json['is_escalated'] ?? false) == true,
      escalatedToName: rawEscalation is Map
          ? rawEscalation['to_name']?.toString()
          : json['escalated_to_name']?.toString(),
      escalatedAt: _parseDate(
        rawEscalation is Map
            ? rawEscalation['escalated_at']
            : json['escalated_at'],
      ),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      dueAt: _parseDate(json['due_at'] ?? json['due_date']),
      resolvedAt: _parseDate(json['resolved_at']),
      closedAt: _parseDate(json['closed_at']),
      attachments: rawAttachments
          .map((a) => AttachmentFile.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    final parsed = DateTime.tryParse(v.toString());
    if (parsed == null || parsed.millisecondsSinceEpoch <= 0) return null;
    return parsed.toLocal();
  }

  static Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final clean = hex.replaceFirst('#', '');
    if (clean.length != 6) return null;
    final value = int.tryParse('FF$clean', radix: 16);
    return value != null ? Color(value) : null;
  }
}

// Screen

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  TicketDetailData? _detail;
  bool _loading = true;
  bool _liveUpdating = false;

  // Firestore listener — fires whenever the HR side changes the ticket document.
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _firestoreSub;
  bool _firstSnapshot = true;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeToTicketChanges();
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    super.dispose();
  }

  // Subscribes to Firestore changes for the ticket document, triggering a reload of the ticket details when changes occur
  // The first snapshot is ignored to avoid unnecessary reloads on initial subscription
  void _subscribeToTicketChanges() {
    _firestoreSub = FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.ticketId)
        .snapshots()
        .listen(
          (snap) {
            if (_firstSnapshot) {
              _firstSnapshot = false; // Ignore the immediate first emission.
              return;
            }
            if (!mounted) return;
            setState(() => _liveUpdating = true);
            _load().then((_) {
              if (mounted) setState(() => _liveUpdating = false);
            });
          },
          onError: (e) {
            debugPrint('Firestore ticket listener error: $e');
          },
        );
  }

  // Loads the ticket details from the API and updates the state accordingly
  Future<void> _load() async {
    try {
      final data = await TicketRepository(
        ApiClient(),
      ).getTicket(widget.ticketId);
      if (mounted)
        setState(() {
          _detail = TicketDetailData.fromJson(data);
          _loading = false;
        });
    } catch (e) {
      debugPrint('Failed to load ticket: $e');
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  // Builds the UI for the ticket detail screen based on the current state
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(backgroundColor: const Color(0xFFF8FAFC), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_detail == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(backgroundColor: const Color(0xFFF8FAFC), elevation: 0),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load ticket'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });
                  _load();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final detail = _detail!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context, detail.ticketCode, _liveUpdating),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // subject + meta
                  _SubjectCard(detail: detail),
                  const SizedBox(height: 20),

                  // status
                  const _SectionLabel(label: 'STATUS'),
                  const SizedBox(height: 8),
                  _StatusCard(detail: detail),
                  const SizedBox(height: 20),

                  // assigned to
                  const _SectionLabel(label: 'ASSIGNED TO'),
                  const SizedBox(height: 8),
                  _OfficerCard(detail: detail),
                  const SizedBox(height: 20),

                  // escalation (conditional)
                  if (detail.isEscalated) ...[
                    _EscalationCard(detail: detail),
                    const SizedBox(height: 20),
                  ],

                  // timeline
                  const _SectionLabel(label: 'TIMELINE'),
                  const SizedBox(height: 8),
                  _DatesCard(detail: detail),
                  const SizedBox(height: 20),

                  // description
                  if (detail.description != null &&
                      detail.description!.isNotEmpty) ...[
                    const _SectionLabel(label: 'DESCRIPTION'),
                    const SizedBox(height: 8),
                    _DescriptionCard(text: detail.description!),
                    const SizedBox(height: 20),
                  ],

                  // attachments
                  if (detail.attachments.isNotEmpty) ...[
                    const _SectionLabel(label: 'ATTACHMENTS'),
                    const SizedBox(height: 8),
                    _AttachmentsCard(
                      files: detail.attachments,
                      ticketId: widget.ticketId,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    String ticketCode,
    bool liveUpdating,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      leading: IconButton(
        icon: const GradientIcon(icon: Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        ticketCode,
        style: AppTypography.bodyMd.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      // Thin progress bar shown while the live update re-fetch is in flight.
      bottom: liveUpdating
          ? PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF6A2FF3).withValues(alpha: 0.35),
                ),
              ),
            )
          : null,
      actions: [
        IconButton(
          tooltip: 'Conversation',
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.ink,
          ),
          onPressed: () =>
              context.push('/tickets/${widget.ticketId}/conversation'),
        ),
        IconButton(
          tooltip: 'History',
          icon: const Icon(Icons.history_rounded, color: AppColors.ink),
          onPressed: () => context.push('/tickets/${widget.ticketId}/history'),
        ),
      ],
    );
  }
}

// Sub-widgets

// Title card
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.caption.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: AppColors.mute,
        letterSpacing: 0.3,
      ),
    );
  }
}

// subject card with category and priority chips
class _SubjectCard extends StatelessWidget {
  final TicketDetailData detail;
  const _SubjectCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.subject,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MetaChip(
                icon: Icons.category_outlined,
                label: detail.category,
                bg: const Color(0xFFF0ECFF),
                color: const Color(0xFF9A32F8),
              ),
              if (detail.priority != null)
                _MetaChip(
                  icon: Icons.flag_outlined,
                  label: detail.priority!,
                  bg: (detail.priorityColor ?? AppColors.body).withValues(
                    alpha: 0.1,
                  ),
                  color: detail.priorityColor ?? AppColors.body,
                ),
              if (detail.source != null)
                _MetaChip(
                  icon: Icons.devices_outlined,
                  label: detail.source!,
                  bg: const Color(0xFFF1F5F9),
                  color: AppColors.body,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color color;
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Status card with current stage and status badge
class _StatusCard extends StatelessWidget {
  final TicketDetailData detail;
  const _StatusCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TicketStatusBadge(status: detail.statusName, fontSize: 13),
              if (detail.statusType != null) ...[
                const SizedBox(height: 4),
                Text(detail.statusType!, style: AppTypography.caption),
              ],
            ],
          ),
          if (detail.isClosed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Closed',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OfficerCard extends StatelessWidget {
  final TicketDetailData detail;
  const _OfficerCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final hasOfficer = detail.officerName != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasOfficer
                  ? const Color(0xFFE4DCFF)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: hasOfficer
                ? Text(
                    detail.officerInitials ?? '?',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4C39F2),
                    ),
                  )
                : const Icon(
                    Icons.person_outline,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: hasOfficer
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.officerName!,
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      if (detail.officerRole != null) ...[
                        const SizedBox(height: 2),
                        Text(detail.officerRole!, style: AppTypography.caption),
                      ],
                    ],
                  )
                : Text(
                    'Pending assignment',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.mute,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Escalation card showing escalation status and details
class _EscalationCard extends StatelessWidget {
  final TicketDetailData detail;
  const _EscalationCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEA580C),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ticket Escalated',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEA580C),
                  ),
                ),
                if (detail.escalatedToName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Escalated to ${detail.escalatedToName}',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFFC2410C),
                    ),
                  ),
                ],
                if (detail.escalatedAt != null)
                  Text(
                    'on ${DateFormat('d MMM yyyy').format(detail.escalatedAt!)}',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFFC2410C),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dates card showing timeline of ticket events
class _DateRow {
  final IconData icon;
  final String label;
  final DateTime date;
  final Color color;
  final bool flagOverdue;
  const _DateRow({
    required this.icon,
    required this.label,
    required this.date,
    required this.color,
    this.flagOverdue = false,
  });
}

class _DatesCard extends StatelessWidget {
  final TicketDetailData detail;
  const _DatesCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final overdue =
        detail.dueAt != null &&
        detail.dueAt!.isBefore(now) &&
        detail.resolvedAt == null &&
        detail.closedAt == null;

    final rows = <_DateRow>[
      _DateRow(
        icon: Icons.schedule_outlined,
        label: 'Submitted',
        date: detail.createdAt,
        color: AppColors.body,
      ),
      if (detail.dueAt != null)
        _DateRow(
          icon: Icons.event_outlined,
          label: 'Due',
          date: detail.dueAt!,
          color: overdue ? const Color(0xFFEF4444) : AppColors.body,
          flagOverdue: overdue,
        ),
      if (detail.updatedAt.isAfter(detail.createdAt))
        _DateRow(
          icon: Icons.update_outlined,
          label: 'Last Updated',
          date: detail.updatedAt,
          color: AppColors.body,
        ),
      if (detail.resolvedAt != null)
        _DateRow(
          icon: Icons.check_circle_outline,
          label: 'Resolved',
          date: detail.resolvedAt!,
          color: const Color(0xFF059669),
        ),
      if (detail.closedAt != null)
        _DateRow(
          icon: Icons.lock_outline,
          label: 'Closed',
          date: detail.closedAt!,
          color: AppColors.mute,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final row = e.value;
          final isLast = e.key == rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(row.icon, size: 15, color: row.color),
                    const SizedBox(width: 10),
                    Text(
                      row.label,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.mute,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (row.flagOverdue) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: const Text(
                          'Overdue',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      DateFormat('d MMM yyyy').format(row.date),
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: row.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _AttachmentsCard extends StatelessWidget {
  final List<AttachmentFile> files;
  final String ticketId;
  const _AttachmentsCard({required this.files, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: files.asMap().entries.map((e) {
          final isLast = e.key == files.length - 1;
          return Column(
            children: [
              _AttachmentRow(file: e.value, ticketId: ticketId),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String text;
  const _DescriptionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.body,
          height: 1.65,
        ),
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  final AttachmentFile file;
  final String ticketId;
  const _AttachmentRow({required this.file, required this.ticketId});

  static IconData _iconForFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  static Color _colorForFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return const Color(0xFF3B82F6);
      case 'doc':
      case 'docx':
        return const Color(0xFF4C39F2);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF64748B);
    }
  }

  Future<void> _download(BuildContext context) async {
    try {
      final url = await FirebaseStorage.instance
          .ref('tickets/$ticketId/${file.name}')
          .getDownloadURL();
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download link copied to clipboard')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch download link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            _iconForFile(file.name),
            color: _colorForFile(file.name),
            size: 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text('${file.sizeKb} KB', style: AppTypography.caption),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _download(context),
            child: const Icon(
              Icons.download_outlined,
              color: AppColors.body,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
