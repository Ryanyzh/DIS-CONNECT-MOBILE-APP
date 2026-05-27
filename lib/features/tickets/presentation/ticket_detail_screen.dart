import 'package:flutter/material.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/tickets/widgets/ticket_status_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class TicketTask {
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const TicketTask({
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

class TicketDetailData {
  final String displayId;
  final String status;
  final String stage;
  final String officerName;
  final String officerRole;
  final String officerInitials;

  const TicketDetailData({
    required this.displayId,
    required this.status,
    required this.stage,
    required this.officerName,
    required this.officerRole,
    required this.officerInitials,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  // Sample detail — swap for repository lookup by widget.ticketId
  late final TicketDetailData _detail = TicketDetailData(
    displayId: 'REB-2024-0012',
    status: 'In Review',
    stage: 'Open',
    officerName: 'Eileen (Scholarship Admin)',
    officerRole: 'Scholarship Administration',
    officerInitials: 'EA',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status ──────────────────────────────────────────────
                  _SectionLabel(label: 'Status'),
                  const SizedBox(height: 10),
                  _StatusCard(stage: _detail.stage, status: _detail.status),
                  const SizedBox(height: 24),

                  // ── HR Officer ───────────────────────────────────────────
                  _SectionLabel(label: 'HR Officer'),
                  const SizedBox(height: 10),
                  _OfficerCard(
                    name: _detail.officerName,
                    role: _detail.officerRole,
                    initials: _detail.officerInitials,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        _detail.displayId,
        style: AppTypography.bodyMd.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.ink),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
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
        fontSize: 12,
        color: AppColors.mute,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String stage;
  final String status;
  const _StatusCard({required this.stage, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            stage,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.body,
              fontWeight: FontWeight.w500,
            ),
          ),
          TicketStatusBadge(status: status, fontSize: 12),
        ],
      ),
    );
  }
}

class _OfficerCard extends StatelessWidget {
  final String name;
  final String role;
  final String initials;
  const _OfficerCard({
    required this.name,
    required this.role,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E7FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4338CA),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(role, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
