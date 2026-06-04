import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Stub data
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryEntry {
  final String action;
  final String? detail;
  final String actorName;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _HistoryEntry({
    required this.action,
    this.detail,
    required this.actorName,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

final _stubHistory = [
  _HistoryEntry(
    action: 'Ticket Created',
    detail: 'Submitted via Mobile App',
    actorName: 'You',
    timestamp: DateTime(2024, 9, 10, 9, 0),
    icon: Icons.add_circle_outline_rounded,
    iconColor: Color(0xFF7C3AED),
    iconBg: Color(0xFFEDE9FE),
  ),
  _HistoryEntry(
    action: 'Status Changed',
    detail: 'Open → In Review',
    actorName: 'Eileen (Scholarship Admin)',
    timestamp: DateTime(2024, 9, 10, 10, 15),
    icon: Icons.swap_horiz_rounded,
    iconColor: Color(0xFF2563EB),
    iconBg: Color(0xFFDBEAFE),
  ),
  _HistoryEntry(
    action: 'Ticket Assigned',
    detail: 'Assigned to Eileen (Scholarship Admin)',
    actorName: 'System',
    timestamp: DateTime(2024, 9, 10, 10, 15),
    icon: Icons.person_add_outlined,
    iconColor: Color(0xFF059669),
    iconBg: Color(0xFFD1FAE5),
  ),
  _HistoryEntry(
    action: 'Comment Added',
    detail: 'Requested supporting documents',
    actorName: 'Eileen (Scholarship Admin)',
    timestamp: DateTime(2024, 9, 10, 10, 30),
    icon: Icons.chat_bubble_outline_rounded,
    iconColor: Color(0xFF6366F1),
    iconBg: Color(0xFFE0E7FF),
  ),
  _HistoryEntry(
    action: 'Attachment Added',
    detail: 'flight_ticket.pdf, invoice.pdf',
    actorName: 'You',
    timestamp: DateTime(2024, 9, 10, 11, 5),
    icon: Icons.attach_file_rounded,
    iconColor: Color(0xFFEA580C),
    iconBg: Color(0xFFFFEDD5),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TicketHistoryScreen extends StatelessWidget {
  final String ticketId;
  const TicketHistoryScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Ticket History',
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        itemCount: _stubHistory.length,
        itemBuilder: (_, i) => _HistoryTile(
          entry: _stubHistory[i],
          isLast: i == _stubHistory.length - 1,
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
                    color: entry.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(entry.icon, color: entry.iconColor, size: 18),
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
                  if (entry.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.detail!,
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
                        DateFormat(
                          'd MMM yyyy, h:mm a',
                        ).format(entry.timestamp),
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
