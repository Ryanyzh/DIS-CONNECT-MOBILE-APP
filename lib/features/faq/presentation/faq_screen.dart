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
  'General': Color(0xFF7C3AED),
  'Tickets': Color(0xFF2563EB),
  'Account': Color(0xFFD97706),
  'Notifications': Color(0xFF059669),
  'Files': Color(0xFF71717A),
};

const _categoryBg = <String, Color>{
  'General': Color(0xFFEDE9FE),
  'Tickets': Color(0xFFDBEAFE),
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
      if (mounted)
        setState(() {
          _faqs = faqs;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = 'Failed to load FAQs.';
          _loading = false;
        });
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
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
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
      body: Column(),
    );
  }
}
