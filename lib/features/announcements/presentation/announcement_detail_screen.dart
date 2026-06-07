import 'package:flutter/material.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/announcements/presentation/announcements_screen.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final String announcementId;

  const AnnouncementDetailScreen({super.key, required this.announcementId});

  // ── Author initials ───────────────────────────────────────────────────────
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final entry = null; // TODO: load announcement by ID

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.ink),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: const Center(child: Text('Announcement not found.')),
      );
    }

    final style = announcementCategoryStyle(entry.category);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.ink),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(
              entry.category,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                color: style.badgeText,
                fontSize: 14,
              ),
            ),
            centerTitle: true,
            // ── Category color bar ─────────────────────────────────────
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: Container(height: 3, color: style.accentColor),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category  ─────────────────────────────────────────
                  Row(
                    children: [_CategoryChip(entry: entry, style: style)],
                  ),
                  const SizedBox(height: 16),

                  // ── Title ─────────────────────────────────────────────
                  Text(
                    entry.title,
                    style: AppTypography.displayXs.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      height: 1.25,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chips
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final AnnouncementEntry entry;
  final AnnouncementCategoryStyle style;
  const _CategoryChip({required this.entry, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: style.badgeBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 13, color: style.badgeText),
          const SizedBox(width: 5),
          Text(
            entry.category.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: style.badgeText,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
