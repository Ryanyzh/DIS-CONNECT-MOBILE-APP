import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/announcements/presentation/announcements_screen.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final String announcementId;

  const AnnouncementDetailScreen({super.key, required this.announcementId});

  // ── Reading time ──────────────────────────────────────────────────────────
  String _readingTime(String text) {
    final words = text.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return '$minutes min read';
  }

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
    final readTime = _readingTime(entry.body);
    final paragraphs = entry.body
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

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

                  // ── Author + meta row ─────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: style.badgeBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(entry.author),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: style.badgeText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.author,
                              style: AppTypography.bodySm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    entry.authorRole,
                                    style: AppTypography.caption,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text('  ·  ', style: AppTypography.caption),
                                Text(
                                  DateFormat(
                                    'd MMM yyyy, h:mm a',
                                  ).format(entry.date),
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Read time ─────────────────────────────────────────
                  Row(
                    children: [
                      const SizedBox(width: 48), // align under avatar
                      const Icon(
                        Icons.schedule_outlined,
                        size: 12,
                        color: AppColors.mute,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        readTime,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mute,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Divider ───────────────────────────────────────────
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 28),

                  // ── Body text ─────────────────────────────────────────
                  ...paragraphs.map((para) {
                    // Detect bullet lines (start with •)
                    if (para.contains('\n') ||
                        para.startsWith('•') ||
                        para.contains(':\n') ||
                        RegExp(
                          r'^[A-Z][^.]*:\s*$',
                        ).hasMatch(para.split('\n').first)) {
                      return _BodyBlock(text: para);
                    }
                    return _BodyBlock(text: para);
                  }),
                  const SizedBox(height: 32),
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

// ─────────────────────────────────────────────────────────────────────────────
// Body block — renders a single paragraph with smart formatting
// ─────────────────────────────────────────────────────────────────────────────

class _BodyBlock extends StatelessWidget {
  final String text;
  const _BodyBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');

    // If the block is a single line label like "Date & Time: ..." keep inline
    if (lines.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Text(
          text,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.body,
            height: 1.75,
          ),
        ),
      );
    }

    // Multi-line block: first line may be a heading (e.g. "Date & Time:")
    final firstLine = lines.first;
    final rest = lines.skip(1).toList();

    final isLabeledBlock =
        firstLine.endsWith(':') ||
        (firstLine.length < 50 &&
            RegExp(r'^[A-Z]').hasMatch(firstLine) &&
            !firstLine.startsWith('•'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLabeledBlock)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                firstLine,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.6,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Text(
                firstLine,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.body,
                  height: 1.75,
                ),
              ),
            ),
          ...rest.map((line) {
            final isBullet = line.trim().startsWith('•');
            return Padding(
              padding: EdgeInsets.only(bottom: 4, left: isBullet ? 4 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBullet) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Color(0xFF4338CA),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        line.replaceFirst('•', '').trim(),
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.body,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Text(
                        line,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.body,
                          height: 1.75,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
