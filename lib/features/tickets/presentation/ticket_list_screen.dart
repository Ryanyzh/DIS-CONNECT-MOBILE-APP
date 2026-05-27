import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/tickets/models/ticket_model.dart';
// ─────────────────────────────────────────────────────────────────────────────
// History entry — status change event shown in the list
// ─────────────────────────────────────────────────────────────────────────────

class TicketEntry {
  final Ticket ticket;
  final String changedBy;
  final DateTime changedAt;

  const TicketEntry({
    required this.ticket,
    required this.changedBy,
    required this.changedAt,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  // Sample data — replace with repository calls when backend is ready
  final List<TicketEntry> _all = [
    TicketEntry(
      ticket: Ticket(
        id: '1',
        displayId: 'REB-2024-0012',
        title: 'Exchange Programme Reimbursement',
        category: 'Reimbursement',
        status: 'In Review',
        priority: 'Medium',
        createdAt: DateTime(2024, 5, 12, 10, 15),
      ),
      changedBy: 'Eileen',
      changedAt: DateTime(2024, 5, 12, 10, 15),
    ),
    TicketEntry(
      ticket: Ticket(
        id: '2',
        displayId: 'EXCH-2024-0051',
        title: 'Internship Forms Submission',
        category: 'Internship',
        status: 'Waiting',
        priority: 'High',
        createdAt: DateTime(2024, 5, 11, 14, 32),
      ),
      changedBy: 'Benjamin',
      changedAt: DateTime(2024, 5, 11, 14, 32),
    ),
    TicketEntry(
      ticket: Ticket(
        id: '3',
        displayId: 'ACD-2024-0080',
        title: 'Scholarship Declaration',
        category: 'Scholarship',
        status: 'Resolved',
        priority: 'Low',
        createdAt: DateTime(2024, 5, 8, 11, 47),
      ),
      changedBy: 'Diana',
      changedAt: DateTime(2024, 5, 8, 11, 47),
    ),
    TicketEntry(
      ticket: Ticket(
        id: '4',
        displayId: 'INT-2024-0033',
        title: 'Leave Application',
        category: 'Leave',
        status: 'Closed',
        priority: 'Low',
        createdAt: DateTime(2024, 4, 28, 9, 0),
      ),
      changedBy: 'Marcus',
      changedAt: DateTime(2024, 4, 28, 9, 0),
    ),
  ];

  List<TicketEntry> get visible => _all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFFF5F7FA),
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              automaticallyImplyLeading: false,
              pinned: true,
              title: Text(
                'Ticket History',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),

            // ── Search bar ──────────────────────────────────────────────

            // ── Cards ───────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _HistoryCard(
                      entry: visible[i],
                      onTap: () =>
                          context.go('/tickets/${visible[i].ticket.id}'),
                    ),
                  ),
                  childCount: visible.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History card
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final TicketEntry entry;
  final VoidCallback onTap;

  const _HistoryCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ID + badge ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.ticket.displayId.isNotEmpty
                      ? entry.ticket.displayId
                      : entry.ticket.id,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                // add ticket status here
              ],
            ),
            const SizedBox(height: 10),

            // ── Action description ────────────────────────────────────
            RichText(
              text: TextSpan(
                style: AppTypography.bodySm.copyWith(color: AppColors.body),
                children: [
                  TextSpan(
                    text: 'Status changed to ${entry.ticket.status}\nby ',
                  ),
                  TextSpan(
                    text: entry.changedBy,
                    style: const TextStyle(
                      color: Color(0xFF4338CA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Date ─────────────────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.mute,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('d MMM yyyy  hh:mm a').format(entry.changedAt),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
