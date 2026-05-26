import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/home/widgets/greeting_header.dart';
import 'package:disconnect_mobile/features/home/widgets/quick_actions_section.dart';
import 'package:disconnect_mobile/features/home/widgets/overview_stats_card.dart';
import 'package:disconnect_mobile/features/home/widgets/recent_tickets_section.dart';
import 'package:disconnect_mobile/features/tickets/models/ticket_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const TicketOverview _overview = TicketOverview(
    inReview: 3,
    waiting: 2,
    resolved: 5,
    closed: 1,
  );

  // ---------------------------------------------------------------------------
  // Sample data — replace with real repository calls when the backend is ready
  // ---------------------------------------------------------------------------
  static final List<Ticket> _recentTickets = [
    Ticket(
      id: '1',
      displayId: 'REB-2024-0012',
      title: 'Exchange Programme Reimbursement',
      category: 'Reimbursement',
      status: 'In Review',
      priority: 'Medium',
      createdAt: DateTime(2024, 5, 12),
    ),
    Ticket(
      id: '2',
      displayId: 'EXCH-2024-0051',
      title: 'Internship Forms Submission',
      category: 'Internship',
      status: 'Waiting',
      priority: 'High',
      createdAt: DateTime(2024, 5, 11),
    ),
    Ticket(
      id: '3',
      displayId: 'ACD-2024-0080',
      title: 'Scholarship Declaration',
      category: 'Scholarship',
      status: 'Resolved',
      priority: 'Low',
      createdAt: DateTime(2024, 5, 8),
    ),
  ];

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Sticky search app-bar ───────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFFF5F7FA),
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              toolbarHeight: 0, // header lives in the body
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Greeting ─────────────────────────────────────────
                    const GreetingHeader(),
                    const SizedBox(height: 20),

                    // ── Quick actions ────────────────────────────────────
                    const QuickActionsSection(),
                    const SizedBox(height: 28),

                    // ── My Overview ──────────────────────────────────────
                    OverviewStatsCard(
                      overview: _overview,
                      onViewAll: () => context.go('/tickets'),
                    ),
                    const SizedBox(height: 28),

                    // ── Recent Tickets ───────────────────────────────────
                    RecentTicketsSection(
                      tickets: _recentTickets,
                      onViewAll: () => context.go('/tickets'),
                      onTicketTap: (_) {
                        // TODO: navigate to ticket detail
                      },
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
