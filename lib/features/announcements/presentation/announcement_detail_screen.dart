import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/features/announcements/data/announcement_repository.dart';
import 'package:disconnect_mobile/features/announcements/presentation/announcements_screen.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final String announcementId;

  const AnnouncementDetailScreen({super.key, required this.announcementId});

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  AnnouncementEntry? _entry;
  bool _loading = false;
  bool _fetchError = false;

  Future<void> _fetchById() async {
    setState(() {
      _loading = true;
      _fetchError = false;
    });
    try {
      final entry = await AnnouncementRepository(
        ApiClient(),
      ).getAnnouncementById(widget.announcementId);
      if (mounted)
        setState(() {
          _entry = entry;
          _loading = false;
        });
    } catch (e) {
      debugPrint('Failed to load announcement: $e');
      if (mounted)
        setState(() {
          _loading = false;
          _fetchError = true;
        });
    }
  }

  String _readingTime(String text) {
    final words = text.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return '$minutes min read';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is AnnouncementEntry) {
      _entry = extra;
      return;
    }
    if (_entry == null && !_loading && !_fetchError) {
      _fetchById();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_entry == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          leading: IconButton(
            icon: const GradientIcon(icon: Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _fetchError
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 40,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load announcement',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _fetchById,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : const Center(child: Text('Announcement not found.')),
      );
    }

    final entry = _entry!;

    final style = announcementCategoryStyle(entry.category);
    final readTime = _readingTime(entry.body);
    final paragraphs = entry.body
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // app bar
          SliverAppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0.5,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            pinned: true,
            leading: IconButton(
              icon: const GradientIcon(icon: Icons.arrow_back),
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
            // category color bar
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: Container(height: 3, color: style.accentColor),
            ),
          ),

          // content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // category
                  Row(
                    children: [_CategoryChip(entry: entry, style: style)],
                  ),
                  const SizedBox(height: 16),

                  // title
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

                  // author + meta row
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

                  // read time
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

                  // divider
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 28),

                  // body text
                  ...paragraphs.map((para) => _BodyBlock(text: para)),
                  const SizedBox(height: 32),

                  // tags
                  if (entry.tags.isNotEmpty) ...[
                    const Divider(color: Color(0xFFF1F5F9), height: 1),
                    const SizedBox(height: 20),
                    Text(
                      'TAGS',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.mute,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.tags
                          .map((tag) => _TagChip(label: tag))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Chips

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

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.body,
        ),
      ),
    );
  }
}

// Body text block - handles single-line labels, multi-line paragraphs, and bullet points

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

    // If the block is multiple lines, treat the first line as a label if it ends with a colon or is short and capitalized. The rest of the lines are treated as body text.
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
                        backgroundColor: Color(0xFF4C39F2),
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
