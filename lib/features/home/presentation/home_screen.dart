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
  bool _ticketsError = false;
  AnnouncementEntry? _latestAnnouncement;

  // Computes the overview stats from the loaded tickets.
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

  // Returns the three most recently updated tickets, sorted by updatedAt (or createdAt if updatedAt is null).
  List<Ticket> get _recentTickets {
    final sorted = [..._tickets]
      ..sort((a, b) {
        final ad = a.updatedAt ?? a.createdAt ?? DateTime(0);
        final bd = b.updatedAt ?? b.createdAt ?? DateTime(0);
        return bd.compareTo(ad);
      });
    return sorted.take(3).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadTickets();
    _loadLatestAnnouncement();
  }

  // Loads the user's tickets from the API and updates the state accordingly.
  Future<void> _loadTickets() async {
    setState(() {
      _ticketsError = false;
    });
    try {
      final tickets = await TicketRepository(ApiClient()).getTickets();
      if (mounted)
        setState(() {
          _tickets = tickets;
          _loadingTickets = false;
        });
    } catch (e) {
      debugPrint('Failed to load home tickets: $e');
      if (mounted)
        setState(() {
          _loadingTickets = false;
          _ticketsError = true;
        });
    }
  }

  // Loads the latest announcement from the API and updates the state accordingly.
  Future<void> _loadLatestAnnouncement() async {
    try {
      final entries = await AnnouncementRepository(
        ApiClient(),
      ).getAnnouncements();
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // greeting
                    const GreetingHeader(),
                    const SizedBox(height: 20),

                    // quick actions
                    const QuickActionsSection(),
                    const SizedBox(height: 28),

                    // my overview
                    if (_loadingTickets)
                      const _SectionSkeleton(height: 100)
                    else if (_ticketsError)
                      _ErrorRetryBlock(onRetry: _loadTickets)
                    else
                      OverviewStatsCard(
                        overview: _overview,
                        onViewAll: () => context.go('/tickets'),
                      ),
                    const SizedBox(height: 28),

                    // recent tickets
                    if (_loadingTickets)
                      const _SectionSkeleton(height: 160)
                    else if (!_ticketsError)
                      RecentTicketsSection(
                        tickets: _recentTickets,
                        onViewAll: () => context.go('/tickets'),
                        onTicketTap: (t) => context.push('/tickets/${t.id}'),
                      ),
                    const SizedBox(height: 28),

                    // announcement banner
                    if (ann != null) ...[
                      AnnouncementBanner(
                        entry: ann,
                        onTap: () => context.push(
                          '/announcements/${ann.id}',
                          extra: ann,
                        ),
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

class _ErrorRetryBlock extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRetryBlock({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Could not load ticket data',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
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
