import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/features/faq/data/faq_repository.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  List<FaqEntry> _faqs = [];
  bool _loadingFaqs = true;

  @override
  void initState() {
    super.initState();
    FaqRepository(ApiClient()).getFaqs().then((faqs) {
      if (mounted) setState(() { _faqs = faqs.take(4).toList(); _loadingFaqs = false; });
    }).catchError((_) {
      if (mounted) setState(() => _loadingFaqs = false);
    });
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
          'Help & Support',
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          // ── Hero ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9A32F8), Color(0xFF4C39F2), Color(0xFF1D67F5)],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.wiseLg),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded, size: 40, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How can we help?',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Browse the FAQs below or reach out to us directly.',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── FAQ ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _SectionLabel(label: 'FREQUENTLY ASKED QUESTIONS'),
              GestureDetector(
                onTap: () => context.push('/faqs'),
                child: Text(
                  'View all',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF4C39F2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loadingFaqs)
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_faqs.isEmpty)
            GestureDetector(
              onTap: () => context.push('/faqs'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Browse all FAQs →',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF4C39F2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            _FaqCard(
              faqs: _faqs,
              onViewAll: () => context.push('/faqs'),
            ),
          const SizedBox(height: 28),

          // ── Contact ───────────────────────────────────────────────────
          const _SectionLabel(label: 'CONTACT SUPPORT'),
          const SizedBox(height: 10),
          _ContactCard(
            items: [
              _ContactItem(
                icon: Icons.email_outlined,
                iconBg: const Color(0xFFE4DCFF),
                iconColor: const Color(0xFF1D67F5),
                label: 'Email Us',
                subtitle: 'support@dis-connect.sg',
                badge: 'Replies within 1 – 2 business days',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening mail app…')),
                ),
              ),
              _ContactItem(
                icon: Icons.confirmation_number_outlined,
                iconBg: const Color(0xFFF0ECFF),
                iconColor: const Color(0xFF9A32F8),
                label: 'Submit a Ticket',
                subtitle: 'Create a ticket for technical issues',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Quick tips ────────────────────────────────────────────────
          const _SectionLabel(label: 'QUICK TIPS'),
          const SizedBox(height: 10),
          _TipsCard(
            tips: const [
              'Keep your ticket description concise but include all relevant details.',
              'Attach supporting documents (invoices, forms) when submitting.',
              'Check the Announcements tab for platform-wide updates.',
              'Enable notifications so you never miss a status change.',
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.caption.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        color: AppColors.mute,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final List<FaqEntry> faqs;
  final VoidCallback onViewAll;
  const _FaqCard({required this.faqs, required this.onViewAll});

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
          children: [
            ...faqs.asMap().entries.map((e) {
              return Column(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0ECFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          size: 14,
                          color: Color(0xFF9A32F8),
                        ),
                      ),
                      title: Text(
                        e.value.question,
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      iconColor: AppColors.mute,
                      collapsedIconColor: AppColors.mute,
                      children: [
                        Text(
                          e.value.answer,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.body,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                    indent: 60,
                  ),
                ],
              );
            }),
            // View all row
            InkWell(
              onTap: onViewAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 14,
                        color: AppColors.body,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Browse all FAQs',
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4C39F2),
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });
}

class _ContactCard extends StatelessWidget {
  final List<_ContactItem> items;
  const _ContactCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: e.key == 0
                      ? const Radius.circular(AppBorderRadius.wiseMd)
                      : Radius.zero,
                  bottom: isLast
                      ? const Radius.circular(AppBorderRadius.wiseMd)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, size: 20, color: item.iconColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: AppTypography.bodySm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(item.subtitle, style: AppTypography.caption),
                            if (item.badge != null) ...[
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Text(
                                  item.badge!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                  indent: 70,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final List<String> tips;
  const _TipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: tips.asMap().entries.map((e) {
          final isLast = e.key == tips.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0ECFF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9A32F8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.value,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.body,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
