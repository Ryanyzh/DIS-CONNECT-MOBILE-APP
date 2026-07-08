import 'package:flutter/material.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/features/faq/data/faq_repository.dart';

const _categories = [
  'All',
  'General',
  'Tickets',
  'Account',
  'Notifications',
  'Files',
];

const _categoryColors = <String, Color>{
  'General': Color(0xFF9A32F8),
  'Tickets': Color(0xFF1D67F5),
  'Account': Color(0xFFD97706),
  'Notifications': Color(0xFF059669),
  'Files': Color(0xFF71717A),
};

const _categoryBg = <String, Color>{
  'General': Color(0xFFF0ECFF),
  'Tickets': Color(0xFFE4DCFF),
  'Account': Color(0xFFFEF3C7),
  'Notifications': Color(0xFFD1FAE5),
  'Files': Color(0xFFF4F4F5),
};

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<FaqEntry> _faqs = [];
  bool _loading = true;
  String? _error;
  String _activeCategory = 'All';
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final faqs = await FaqRepository(ApiClient()).getFaqs();
      if (mounted) {
        setState(() {
          _faqs = faqs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load FAQs.';
          _loading = false;
        });
      }
    }
  }

  // Called by RefreshIndicator — keeps existing entries visible while fetching.
  Future<void> _refresh() async {
    try {
      final faqs = await FaqRepository(ApiClient()).getFaqs();
      if (mounted) setState(() { _faqs = faqs; _error = null; });
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to refresh FAQs.');
    }
  }

  List<FaqEntry> get _filtered {
    var list = _faqs;
    if (_activeCategory != 'All') {
      list = list.where((f) => f.category == _activeCategory).toList();
    }
    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (f) =>
                f.question.toLowerCase().contains(q) ||
                f.answer.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  Map<String, List<FaqEntry>> get _grouped {
    final result = <String, List<FaqEntry>>{};
    for (final cat in _categories.skip(1)) {
      final items = _filtered.where((f) => f.category == cat).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      if (items.isNotEmpty) result[cat] = items;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          icon: const GradientIcon(icon: Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'FAQs',
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _search = v),
              style: AppTypography.bodySm.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Search FAQs…',
                hintStyle: AppTypography.bodySm.copyWith(color: AppColors.mute),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.mute,
                ),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.mute,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Category chips ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((cat) {
                  final isActive = _activeCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.ink : Colors.white,
                          border: Border.all(
                            color: isActive
                                ? AppColors.ink
                                : const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.wisePill,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : AppColors.body,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.negative,
                      ),
                    ),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No FAQs found.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.mute,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    color: const Color(0xFF4C39F2),
                    child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    children: [
                      // When searching, show flat list; otherwise group by category
                      if (_search.isNotEmpty || _activeCategory != 'All')
                        _FaqGroup(
                          faqs: _filtered
                            ..sort((a, b) => a.order.compareTo(b.order)),
                          showCategoryBadge: _activeCategory == 'All',
                        )
                      else
                        ..._grouped.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CategoryHeader(category: entry.key),
                                const SizedBox(height: 8),
                                _FaqGroup(
                                  faqs: entry.value,
                                  showCategoryBadge: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String category;
  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[category] ?? AppColors.mute;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          category.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.mute,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _FaqGroup extends StatelessWidget {
  final List<FaqEntry> faqs;
  final bool showCategoryBadge;
  const _FaqGroup({required this.faqs, required this.showCategoryBadge});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        child: Column(
          children: faqs.asMap().entries.map((e) {
            final faq = e.value;
            final isLast = e.key == faqs.length - 1;
            final catColor = _categoryColors[faq.category] ?? AppColors.mute;
            final catBg = _categoryBg[faq.category] ?? const Color(0xFFF4F4F5);
            return Column(
              children: [
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: catBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 14,
                        color: catColor,
                      ),
                    ),
                    title: Text(
                      faq.question,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    subtitle: showCategoryBadge
                        ? Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              faq.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: catColor,
                              ),
                            ),
                          )
                        : null,
                    iconColor: AppColors.mute,
                    collapsedIconColor: AppColors.mute,
                    children: [
                      Text(
                        faq.answer,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.body,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                    indent: 60,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
