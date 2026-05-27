import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/tickets/models/ticket_model.dart';

class RecentTicketsSection extends StatelessWidget {
  final List<Ticket> tickets;
  final VoidCallback? onViewAll;
  final ValueChanged<Ticket>? onTicketTap;

  const RecentTicketsSection({
    super.key,
    required this.tickets,
    this.onViewAll,
    this.onTicketTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Tickets',
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF2563EB),
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
          child: tickets.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No recent tickets',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.mute,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: tickets.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                    indent: 56,
                  ),
                  itemBuilder: (context, i) => _TicketRow(
                    ticket: tickets[i],
                    isFirst: i == 0,
                    isLast: i == tickets.length - 1,
                    onTap: () => onTicketTap?.call(tickets[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _TicketRow extends StatelessWidget {
  final Ticket ticket;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _TicketRow({
    required this.ticket,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(ticket.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst
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
            // Category icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusStyle.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(ticket.category),
                color: statusStyle.iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Ticket ID + title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.displayId.isNotEmpty ? ticket.displayId : ticket.id,
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ticket.title,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.body,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status + date column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(label: ticket.status, style: statusStyle),
                if (ticket.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM yyyy').format(ticket.createdAt!),
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'reimbursement':
        return Icons.send_outlined;
      case 'internship':
        return Icons.assignment_outlined;
      case 'scholarship':
        return Icons.school_outlined;
      case 'leave':
        return Icons.calendar_today_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  _StatusStyle _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'in review':
        return const _StatusStyle(
          label: 'In Review',
          badgeBg: Color(0xFFDBEAFE),
          badgeText: Color(0xFF1D4ED8),
          iconBg: Color(0xFFDBEAFE),
          iconColor: Color(0xFF2563EB),
        );
      case 'waiting':
        return const _StatusStyle(
          label: 'Waiting',
          badgeBg: Color(0xFFFFEDD5),
          badgeText: Color(0xFFEA580C),
          iconBg: Color(0xFFFFEDD5),
          iconColor: Color(0xFFEA580C),
        );
      case 'resolved':
        return const _StatusStyle(
          label: 'Resolved',
          badgeBg: Color(0xFFD1FAE5),
          badgeText: Color(0xFF059669),
          iconBg: Color(0xFFD1FAE5),
          iconColor: Color(0xFF059669),
        );
      case 'open':
        return const _StatusStyle(
          label: 'Open',
          badgeBg: Color(0xFFEDE9FE),
          badgeText: Color(0xFF7C3AED),
          iconBg: Color(0xFFEDE9FE),
          iconColor: Color(0xFF7C3AED),
        );
      default:
        return const _StatusStyle(
          label: 'Closed',
          badgeBg: Color(0xFFF1F5F9),
          badgeText: Color(0xFF64748B),
          iconBg: Color(0xFFF1F5F9),
          iconColor: Color(0xFF64748B),
        );
    }
  }
}

class _StatusStyle {
  final String label;
  final Color badgeBg;
  final Color badgeText;
  final Color iconBg;
  final Color iconColor;

  const _StatusStyle({
    required this.label,
    required this.badgeBg,
    required this.badgeText,
    required this.iconBg,
    required this.iconColor,
  });
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final _StatusStyle style;

  const _StatusBadge({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.badgeBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.wisePill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: style.badgeText,
        ),
      ),
    );
  }
}
