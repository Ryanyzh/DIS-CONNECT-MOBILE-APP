import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementEntry {
  final String title;
  final DateTime date;
  final VoidCallback? onTap;

  const AnnouncementEntry({
    required this.title,
    required this.date,
    this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  // Sample data — replace with repository calls
  static final _announcements = [
    AnnouncementEntry(
      title: 'Overseas Exchange Briefing for May 2024',
      date: DateTime(2024, 5, 15, 10, 30),
    ),
    AnnouncementEntry(
      title: 'Internship Declaration Submission Deadline',
      date: DateTime(2024, 5, 20, 9, 0),
    ),
    AnnouncementEntry(
      title: 'Scholarship Results Released',
      date: DateTime(2024, 5, 22, 14, 0),
    ),
    AnnouncementEntry(
      title: 'System Maintenance Window',
      date: DateTime(2024, 5, 25, 23, 0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar — no back button (this is a tab) ─────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFFF5F7FA),
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              automaticallyImplyLeading: false,
              pinned: true,
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
                    child: _AnnouncementCard(entry: _announcements[i]),
                  ),
                  childCount: _announcements.length,
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
  const _AnnouncementCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: entry.onTap,
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_outlined,
                color: Color(0xFF4338CA),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppColors.mute,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM yyyy  h:mm a').format(entry.date),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
