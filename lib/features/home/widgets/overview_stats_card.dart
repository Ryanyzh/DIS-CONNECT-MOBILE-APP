import 'package:flutter/material.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

class TicketOverview {
  final int inReview;
  final int waiting;
  final int resolved;
  final int closed;

  const TicketOverview({
    this.inReview = 0,
    this.waiting = 0,
    this.resolved = 0,
    this.closed = 0,
  });
}

class OverviewStatsCard extends StatelessWidget {
  final TicketOverview overview;
  final VoidCallback? onViewAll;

  const OverviewStatsCard({super.key, required this.overview, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Overview',
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View all',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
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
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.description_outlined,
                    iconBg: const Color(0xFFDBEAFE),
                    iconColor: const Color(0xFF2563EB),
                    count: overview.inReview,
                    label: 'In Review',
                    labelColor: const Color(0xFF2563EB),
                    isFirst: true,
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                Expanded(
                  child: _StatCell(
                    icon: Icons.access_time_outlined,
                    iconBg: const Color(0xFFFFEDD5),
                    iconColor: const Color(0xFFEA580C),
                    count: overview.waiting,
                    label: 'Waiting',
                    labelColor: const Color(0xFFEA580C),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                Expanded(
                  child: _StatCell(
                    icon: Icons.check_circle_outline,
                    iconBg: const Color(0xFFD1FAE5),
                    iconColor: const Color(0xFF059669),
                    count: overview.resolved,
                    label: 'Resolved',
                    labelColor: const Color(0xFF059669),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                Expanded(
                  child: _StatCell(
                    icon: Icons.archive_outlined,
                    iconBg: const Color(0xFFF1F5F9),
                    iconColor: const Color(0xFF64748B),
                    count: overview.closed,
                    label: 'Closed',
                    labelColor: const Color(0xFF64748B),
                    isLast: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int count;
  final String label;
  final Color labelColor;
  final bool isFirst;
  final bool isLast;

  const _StatCell({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.labelColor,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isFirst ? 16 : 8, 16, isLast ? 16 : 8, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
