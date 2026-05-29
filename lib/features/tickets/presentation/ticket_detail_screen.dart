import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/tickets/widgets/ticket_status_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class AttachmentFile {
  final String name;
  final int sizeKb;
  const AttachmentFile({required this.name, required this.sizeKb});
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  // Sample detail — swap for repository lookup by ticketId
  TicketDetailData get _detail => TicketDetailData(
    ticketCode: 'REB-2024-0012',
    subject: 'Reimbursement for Flight Ticket — Exchange Programme',
    category: 'Reimbursement',
    priority: 'High',
    priorityColor: const Color(0xFFEF4444),
    statusName: 'In Review',
    statusType: 'Processing',
    isClosed: false,
    description:
        'I am requesting reimbursement for my flight ticket purchased for '
        'the NUS Global Exchange Programme. The flight was on 12 Sep 2024 '
        'from Singapore to Frankfurt. Please find attached the invoice and '
        'boarding pass for your reference.',
    source: 'Mobile App',
    officerName: 'Eileen (Scholarship Admin)',
    officerRole: 'Scholarship Administration',
    officerInitials: 'EA',
    isEscalated: false,
    createdAt: DateTime(2024, 9, 10, 9, 0),
    updatedAt: DateTime(2024, 9, 10, 11, 5),
    dueAt: DateTime(2024, 9, 24),
    attachments: const [
      AttachmentFile(name: 'flight_ticket.pdf', sizeKb: 245),
      AttachmentFile(name: 'invoice.pdf', sizeKb: 130),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Subject + meta ─────────────────────────────────────────
                  _SubjectCard(detail: detail),
                  const SizedBox(height: 20),

                  // ── Status ─────────────────────────────────────────────────
                  const _SectionLabel(label: 'STATUS'),
                  const SizedBox(height: 8),
                  _StatusCard(detail: detail),
                  const SizedBox(height: 20),

                  // ── Assigned to ────────────────────────────────────────────
                  const _SectionLabel(label: 'ASSIGNED TO'),
                  const SizedBox(height: 8),
                  _OfficerCard(detail: detail),
                  const SizedBox(height: 20),

                  // ── Escalation (conditional) ───────────────────────────────
                  if (detail.isEscalated) ...[
                    _EscalationCard(detail: detail),
                    const SizedBox(height: 20),
                  ],

                  // ── Attachments ────────────────────────────────────────────
                  if (detail.attachments.isNotEmpty) ...[
                    const _SectionLabel(label: 'ATTACHMENTS'),
                    const SizedBox(height: 8),
                    _AttachmentsCard(files: detail.attachments),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        _detail.ticketCode,
        style: AppTypography.bodyMd.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.ink),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

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
                bg: const Color(0xFFEDE9FE),
                color: const Color(0xFF7C3AED),
              ),
              if (detail.priority != null)
                _MetaChip(
                  icon: Icons.flag_outlined,
                  label: detail.priority!,
                  bg: detail.priorityColor!.withValues(alpha: 0.1),
                  color: detail.priorityColor!,
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
                  ? const Color(0xFFE0E7FF)
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
                      color: Color(0xFF4338CA),
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

// Attachment card for each file
class _AttachmentsCard extends StatelessWidget {
  final List<AttachmentFile> files;
  const _AttachmentsCard({required this.files});

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
              _AttachmentRow(file: e.value),
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

class _AttachmentRow extends StatelessWidget {
  final AttachmentFile file;
  const _AttachmentRow({required this.file});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf_outlined,
            color: Color(0xFFEF4444),
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
          const Icon(Icons.download_outlined, color: AppColors.body, size: 20),
        ],
      ),
    );
  }
}
