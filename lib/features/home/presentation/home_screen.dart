import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/features/announcements/data/announcement_repository.dart';
import 'package:disconnect_mobile/features/announcements/presentation/announcements_screen.dart';
import 'package:disconnect_mobile/features/home/widgets/greeting_header.dart';
import 'package:disconnect_mobile/features/home/widgets/quick_actions_section.dart';
import 'package:disconnect_mobile/features/home/widgets/overview_stats_card.dart';
import 'package:disconnect_mobile/features/home/widgets/recent_tickets_section.dart';
import 'package:disconnect_mobile/features/tickets/data/ticket_repository.dart';
import 'package:disconnect_mobile/features/tickets/models/ticket_model.dart';
import 'package:disconnect_mobile/features/home/widgets/announcement_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Ticket> _tickets = [];
  bool _loadingTickets = true;
  AnnouncementEntry? _latestAnnouncement;

  // Derived from _tickets ────────────────────────────────────────────────────

  TicketOverview get _overview {
    int inReview = 0, waiting = 0, resolved = 0, closed = 0;
    for (final t in _tickets) {
      final s = t.status.toLowerCase();
      if (s.contains('review')) {
        inReview++;
      } else if (s.contains('wait') || s.contains('pending')) {
        waiting++;
      } else if (s == 'resolved') {
        resolved++;
      } else if (s == 'closed') {
        closed++;
      }
    }
    return TicketOverview(
      inReview: inReview,
      waiting: waiting,
      resolved: resolved,
      closed: closed,
    );
  }

  List<Ticket> get _recentTickets {
    final sorted = [..._tickets]
      ..sort((a, b) {
        final ad = a.updatedAt ?? a.createdAt ?? DateTime(0);
        final bd = b.updatedAt ?? b.createdAt ?? DateTime(0);
        return bd.compareTo(ad);
      });
    return sorted.take(3).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadTickets();
    _loadLatestAnnouncement();
  }

  Future<void> _loadTickets() async {
    try {
      final tickets = await TicketRepository(ApiClient()).getTickets();
      if (mounted) setState(() { _tickets = tickets; _loadingTickets = false; });
    } catch (e) {
      debugPrint('Failed to load home tickets: $e');
      if (mounted) setState(() => _loadingTickets = false);
    }
  }

  Future<void> _loadLatestAnnouncement() async {
    try {
      final entries =
          await AnnouncementRepository(ApiClient()).getAnnouncements();
      if (entries.isNotEmpty && mounted) {
        entries.sort((a, b) => b.date.compareTo(a.date));
        setState(() => _latestAnnouncement = entries.first);
      }
    } catch (e) {
      debugPrint('Failed to load latest announcement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ann = _latestAnnouncement;

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
              toolbarHeight: 0,
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
                    if (_loadingTickets)
                      const _SectionSkeleton(height: 100)
                    else
                      OverviewStatsCard(
                        overview: _overview,
                        onViewAll: () => context.go('/tickets'),
                      ),
                    const SizedBox(height: 28),

                    // ── Recent Tickets ───────────────────────────────────
                    if (_loadingTickets)
                      const _SectionSkeleton(height: 160)
                    else
                      RecentTicketsSection(
                        tickets: _recentTickets,
                        onViewAll: () => context.go('/tickets'),
                        onTicketTap: (t) => context.push('/tickets/${t.id}'),
                      ),
                    const SizedBox(height: 28),

                    // ── Announcement banner ──────────────────────────────
                    if (ann != null) ...[
                      AnnouncementBanner(
                        entry: ann,
                        onTap: () => context.push('/announcements/${ann.id}', extra: ann),
                      ),
                      const SizedBox(height: 32),
                    ],
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

class _SectionSkeleton extends StatelessWidget {
  final double height;
  const _SectionSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
