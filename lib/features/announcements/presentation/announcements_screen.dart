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