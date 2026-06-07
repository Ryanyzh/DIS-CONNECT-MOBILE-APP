import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

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
        badgeBg: Color(0xFFDBEAFE),
        badgeText: Color(0xFF1D4ED8),
        accentColor: Color(0xFF2563EB),
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
        badgeBg: Color(0xFFE0E7FF),
        badgeText: Color(0xFF4338CA),
        accentColor: Color(0xFF4338CA),
        icon: Icons.campaign_outlined,
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              automaticallyImplyLeading: false,
              title: Text(
                'Announcements',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  fontSize: 18,
                ),
              ),
              centerTitle: false,
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AnnouncementCard(
                      entry: announcementsList[i],
                      ),
                    ),
                  ),
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
                          child: Icon(style.icon,
                              color: style.accentColor, size: 20),
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
                                    DateFormat('d MMM yyyy')
                                        .format(entry.date),
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            size: 18, color: Color(0xFFCBD5E1)),
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