import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/features/announcements/data/announcement_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementEntry {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String author;
  final String authorRole;

  /// 'General' | 'Deadline' | 'Event' | 'Maintenance' | 'Urgent' | 'Result'
  final String category;
  final List<String> tags;

  const AnnouncementEntry({
    required this.id,
    required this.title,
    this.body = '',
    required this.date,
    this.author = 'Scholarship Office',
    this.authorRole = 'Administration',
    this.category = 'General',
    this.tags = const [],
  });

  factory AnnouncementEntry.fromJson(Map<String, dynamic> json) {
    return AnnouncementEntry(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      date: _parseDate(json['date']),
      author: json['author'] as String? ?? 'Scholarship Office',
      authorRole: json['authorRole'] as String? ?? 'Administration',
      category: json['category'] as String? ?? 'General',
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate().toLocal();
    if (raw is String) return DateTime.tryParse(raw)?.toLocal() ?? DateTime.now();
    return DateTime.now();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category style
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementCategoryStyle {
  final Color badgeBg;
  final Color badgeText;
  final Color accentColor;
  final IconData icon;

  const AnnouncementCategoryStyle({
    required this.badgeBg,
    required this.badgeText,
    required this.accentColor,
    required this.icon,
  });
}

AnnouncementCategoryStyle announcementCategoryStyle(String category) {
  switch (category.toLowerCase()) {
    case 'deadline':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFFEE2E2),
        badgeText: Color(0xFFDC2626),
        accentColor: Color(0xFFEF4444),
        icon: Icons.timer_outlined,
      );
    case 'event':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFE4DCFF),
        badgeText: Color(0xFF1D4BEB),
        accentColor: Color(0xFF1D67F5),
        icon: Icons.event_outlined,
      );
    case 'maintenance':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFF1F5F9),
        badgeText: Color(0xFF475569),
        accentColor: Color(0xFF64748B),
        icon: Icons.build_outlined,
      );
    case 'urgent':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFFFEDD5),
        badgeText: Color(0xFFEA580C),
        accentColor: Color(0xFFF97316),
        icon: Icons.warning_amber_rounded,
      );
    case 'result':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFD1FAE5),
        badgeText: Color(0xFF059669),
        accentColor: Color(0xFF10B981),
        icon: Icons.check_circle_outline_rounded,
      );
    default: // General
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFE4DCFF),
        badgeText: Color(0xFF4C39F2),
        accentColor: Color(0xFF4C39F2),
        icon: Icons.campaign_outlined,
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<AnnouncementEntry> _announcements = [];
  bool _loading = true;

  StreamSubscription<QuerySnapshot>? _firestoreSub;
  bool _firstSnapshot = true;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeToChanges();
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final entries =
          await AnnouncementRepository(ApiClient()).getAnnouncements();
      if (mounted) {
        setState(() {
          _announcements = entries;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load announcements: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // Firestore listener is used only as a change signal — not as the data
  // source. When the HR side creates/updates an announcement, the snapshot
  // fires and we re-fetch the full list from the REST API.
  void _subscribeToChanges() {
    _firestoreSub = FirebaseFirestore.instance
        .collection('announcements')
        .snapshots()
        .listen((snapshot) {
      // Skip the first emission — it fires immediately on subscribe and
      // would cause a redundant fetch alongside the initial _load() call.
      if (_firstSnapshot) { _firstSnapshot = false; return; }
      if (!mounted) return;
      _refresh();
    }, onError: (e) {
      debugPrint('Firestore announcements listener error: $e');
    });
  }

  // Silently re-fetches in the background; keeps the existing list visible.
  Future<void> _refresh() async {
    try {
      final entries =
          await AnnouncementRepository(ApiClient()).getAnnouncements();
      if (mounted) setState(() => _announcements = entries);
    } catch (e) {
      debugPrint('Failed to refresh announcements: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._announcements]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refresh,
                color: const Color(0xFF4C39F2),
                child: CustomScrollView(
                slivers: [
                  // ── App bar ───────────────────────────────────────────
                  SliverAppBar(
                    backgroundColor: const Color(0xFFF8FAFC),
                    elevation: 0,
                    scrolledUnderElevation: 1,
                    shadowColor: Colors.black.withValues(alpha: 0.06),
                    automaticallyImplyLeading: false,
                    pinned: true,
                    title: Text(
                      'Announcements',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        fontSize: 17,
                      ),
                    ),
                    centerTitle: true,
                  ),

                  if (sorted.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No announcements yet.',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AnnouncementCard(
                              entry: sorted[i],
                              onTap: () => context.push(
                                '/announcements/${sorted[i].id}',
                                extra: sorted[i],
                              ),
                            ),
                          ),
                          childCount: sorted.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Announcement card
// ─────────────────────────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementEntry entry;
  final VoidCallback onTap;
  const _AnnouncementCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = announcementCategoryStyle(entry.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Category accent strip ───────────────────────────────
                Container(width: 4, color: style.accentColor),

                // ── Content ─────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: style.badgeBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            style.icon,
                            color: style.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category badge
                              Row(
                                children: [
                                  _CategoryBadge(
                                    label: entry.category,
                                    style: style,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Title
                              Text(
                                entry.title,
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Meta row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 12,
                                    color: AppColors.mute,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      entry.author,
                                      style: AppTypography.caption,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: AppColors.mute,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    DateFormat('d MMM yyyy').format(entry.date),
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Color(0xFFCBD5E1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final AnnouncementCategoryStyle style;
  const _CategoryBadge({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.badgeBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: style.badgeText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
