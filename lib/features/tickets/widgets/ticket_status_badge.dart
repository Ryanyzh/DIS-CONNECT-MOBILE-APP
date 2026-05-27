import 'package:flutter/material.dart';

/// Shared status colours used across the ticket feature.
class TicketStatusStyle {
  final Color badgeBg;
  final Color badgeText;
  final Color iconBg;
  final Color iconColor;

  const TicketStatusStyle({
    required this.badgeBg,
    required this.badgeText,
    required this.iconBg,
    required this.iconColor,
  });
}

TicketStatusStyle ticketStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'in review':
      return const TicketStatusStyle(
        badgeBg: Color(0xFFDBEAFE),
        badgeText: Color(0xFF1D4ED8),
        iconBg: Color(0xFFDBEAFE),
        iconColor: Color(0xFF2563EB),
      );
    case 'waiting':
      return const TicketStatusStyle(
        badgeBg: Color(0xFFFFEDD5),
        badgeText: Color(0xFFEA580C),
        iconBg: Color(0xFFFFEDD5),
        iconColor: Color(0xFFEA580C),
      );
    case 'open':
      return const TicketStatusStyle(
        badgeBg: Color(0xFFEDE9FE),
        badgeText: Color(0xFF7C3AED),
        iconBg: Color(0xFFEDE9FE),
        iconColor: Color(0xFF7C3AED),
      );
    case 'resolved':
      return const TicketStatusStyle(
        badgeBg: Color(0xFFD1FAE5),
        badgeText: Color(0xFF059669),
        iconBg: Color(0xFFD1FAE5),
        iconColor: Color(0xFF059669),
      );
    default: // closed
      return const TicketStatusStyle(
        badgeBg: Color(0xFFF1F5F9),
        badgeText: Color(0xFF64748B),
        iconBg: Color(0xFFF1F5F9),
        iconColor: Color(0xFF64748B),
      );
  }
}

/// Status priority for sorting: lower = shown first.
int statusSortOrder(String status) {
  switch (status.toLowerCase()) {
    case 'in review':
      return 0;
    case 'waiting':
      return 1;
    case 'open':
      return 2;
    case 'resolved':
      return 3;
    default:
      return 4; // closed / unknown
  }
}

class TicketStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const TicketStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final style = ticketStatusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.badgeBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: style.badgeText,
        ),
      ),
    );
  }
}
