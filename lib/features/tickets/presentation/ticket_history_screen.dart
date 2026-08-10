import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/tickets/data/ticket_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryEntry {
  final String actionId;
  final String action;
  final String detail;
  final String actorName;
  final DateTime timestamp;

  const _HistoryEntry({
    required this.actionId,
    required this.action,
    required this.detail,
    required this.actorName,
    required this.timestamp,
  });

  factory _HistoryEntry.fromJson(Map<String, dynamic> json) {
    return _HistoryEntry(
      actionId: json['action_id'] as String? ?? '',
      action: json['action_type'] as String? ?? 'Update',
      detail: json['message'] as String? ?? '',
      actorName: json['officer_name'] as String? ?? 'System',
      timestamp:
          (DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal()) ??
          DateTime.now(),
    );
  }
}

// Maps an action_type string to icon + colors
({IconData icon, Color iconColor, Color iconBg}) _styleFor(String action) {
  switch (action) {
    case 'assignment':
      return (
        icon: Icons.person_add_outlined,
        iconColor: const Color(0xFF059669),
        iconBg: const Color(0xFFD1FAE5),
      );
    case 'Escalated':
      return (
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFEA580C),
        iconBg: const Color(0xFFFFEDD5),
      );
    case 'Resolved':
      return (
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFD1FAE5),
      );
    case 'Closed':
      return (
        icon: Icons.lock_outline,
        iconColor: const Color(0xFF475569),
        iconBg: const Color(0xFFF1F5F9),
      );
    case 'Open':
      return (
        icon: Icons.add_circle_outline_rounded,
        iconColor: const Color(0xFF7C3AED),
        iconBg: const Color(0xFFEDE9FE),
      );
    default:
      return (
        icon: Icons.swap_horiz_rounded,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFDBEAFE),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TicketHistoryScreen extends StatefulWidget {
  final String ticketId;
  const TicketHistoryScreen({super.key, required this.ticketId});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  List<_HistoryEntry> _history = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await TicketRepository(ApiClient()).getHistory(widget.ticketId);
      if (mounted) {
        setState(() {
          _history = raw.map(_HistoryEntry.fromJson).toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load ticket history: $e');
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          icon: const GradientIcon(icon: Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Ticket History',
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load history',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        setState(() { _loading = true; _error = false; });
                        _load();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _history.isEmpty
          ? const Center(
              child: Text(
                'No history yet.',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              itemCount: _history.length,
              itemBuilder: (_, i) => _HistoryTile(
                entry: _history[i],
                isLast: i == _history.length - 1,
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final _HistoryEntry entry;
  final bool isLast;
  const _HistoryTile({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(entry.action);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline spine ───────────────────────────────────────────
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: style.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(style.icon, color: style.iconColor, size: 18),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    entry.action,
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  if (entry.detail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.detail,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.body,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 11,
                        color: AppColors.mute,
                      ),
                      const SizedBox(width: 3),
                      Text(entry.actorName, style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 11,
                        color: AppColors.mute,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        DateFormat('d MMM yyyy, h:mm a').format(entry.timestamp),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
