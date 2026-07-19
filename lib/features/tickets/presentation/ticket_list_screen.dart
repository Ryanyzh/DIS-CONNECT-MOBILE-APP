import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/tickets/data/ticket_repository.dart';
import 'package:disconnect_mobile/features/tickets/models/ticket_model.dart';
import 'package:disconnect_mobile/features/tickets/widgets/ticket_status_badge.dart';
import 'package:disconnect_mobile/features/tickets/widgets/search_bar.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  List<Ticket> _tickets = [];
  bool _loading = true;
  String _query = '';

  // Route-change tracking for auto-refresh on return from sub-routes
  bool _firstDepChange = true;
  bool? _wasCurrent;

  static bool _isDone(Ticket t) {
    final s = t.status.toLowerCase();
    return s == 'resolved' || s == 'closed';
  }

  List<Ticket> get _visible {
    if (_query.isEmpty) return _tickets;
    final q = _query.toLowerCase();
    return _tickets.where((t) =>
      t.title.toLowerCase().contains(q) ||
      t.displayId.toLowerCase().contains(q) ||
      t.category.toLowerCase().contains(q) ||
      t.status.toLowerCase().contains(q),
    ).toList();
  }

  List<Ticket> get _active   => _visible.where((t) => !_isDone(t)).toList();
  List<Ticket> get _resolved => _visible.where(_isDone).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstDepChange) {
      _firstDepChange = false;
      _wasCurrent = ModalRoute.of(context)?.isCurrent;
      return;
    }
    final isCurrent = ModalRoute.of(context)?.isCurrent == true;
    // Reload only when transitioning from hidden → current (returned from sub-route)
    if (isCurrent && _wasCurrent == false && !_loading) {
      _load();
    }
    _wasCurrent = isCurrent;
  }

  Future<void> _load() async {
    if (_loading && _tickets.isNotEmpty) return;
    setState(() => _loading = true);
    try {
      final tickets = await TicketRepository(ApiClient()).getTickets();
      if (mounted) setState(() { _tickets = tickets; _loading = false; });
    } catch (e) {
      debugPrint('Failed to load tickets: $e');
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C39F2).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => context.push('/tickets/create').then((_) => _load()),
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withValues(alpha: 0.18),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'New Ticket',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: const Color(0xFF6A2FF3),
          child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              automaticallyImplyLeading: false,
              pinned: true,
              title: Text(
                'Tickets',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  fontSize: 17,
                ),
              ),
              centerTitle: true,
            ),

            // ── Search bar ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: AppSearchBar(
                  onChanged: (q) => setState(() => _query = q),
                ),
              ),
            ),

            // ── Cards ───────────────────────────────────────────────────
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_visible.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No tickets found')),
              )
            else ...[
              // Active tickets
              if (_active.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _TicketCard(
                          ticket: _active[i],
                          onTap: () => context.go('/tickets/${_active[i].id}'),
                        ),
                      ),
                      childCount: _active.length,
                    ),
                  ),
                ),

              // Resolved / Closed section
              if (_resolved.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 13,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'RESOLVED & CLOSED (${_resolved.length})',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _TicketCard(
                          ticket: _resolved[i],
                          onTap: () => context.go('/tickets/${_resolved[i].id}'),
                          muted: true,
                        ),
                      ),
                      childCount: _resolved.length,
                    ),
                  ),
                ),
              ],

              // Bottom padding so FAB doesn't overlap last card
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ],
        ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ticket card
// ─────────────────────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;
  final bool muted;

  const _TicketCard({required this.ticket, required this.onTap, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final date = ticket.updatedAt ?? ticket.createdAt;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: muted ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
          boxShadow: muted ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: muted
              ? Border.all(color: const Color(0xFFE2E8F0))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ID + badge ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.displayId.isNotEmpty ? ticket.displayId : ticket.id,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                TicketStatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: 10),

            // ── Subject ───────────────────────────────────────────────
            Text(
              ticket.title,
              style: AppTypography.bodySm.copyWith(color: AppColors.body),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // ── Date ─────────────────────────────────────────────────
            if (date != null)
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.mute,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('d MMM yyyy  hh:mm a').format(date),
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
