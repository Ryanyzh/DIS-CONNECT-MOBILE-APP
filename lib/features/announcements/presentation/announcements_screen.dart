import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementEntry {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String author;
  final String authorRole;

  /// 'General' | 'Deadline' | 'Event' | 'Maintenance' | 'Urgent' | 'Result'
  final String category;
  final List<String> tags;

  const AnnouncementEntry({
    required this.id,
    required this.title,
    this.body = '',
    required this.date,
    this.author = 'Scholarship Office',
    this.authorRole = 'Administration',
    this.category = 'General',
    this.tags = const [],
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Category style
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementCategoryStyle {
  final Color badgeBg;
  final Color badgeText;
  final Color accentColor;
  final IconData icon;

  const AnnouncementCategoryStyle({
    required this.badgeBg,
    required this.badgeText,
    required this.accentColor,
    required this.icon,
  });
}

AnnouncementCategoryStyle announcementCategoryStyle(String category) {
  switch (category.toLowerCase()) {
    case 'deadline':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFFEE2E2),
        badgeText: Color(0xFFDC2626),
        accentColor: Color(0xFFEF4444),
        icon: Icons.timer_outlined,
      );
    case 'event':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFDBEAFE),
        badgeText: Color(0xFF1D4ED8),
        accentColor: Color(0xFF2563EB),
        icon: Icons.event_outlined,
      );
    case 'maintenance':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFF1F5F9),
        badgeText: Color(0xFF475569),
        accentColor: Color(0xFF64748B),
        icon: Icons.build_outlined,
      );
    case 'urgent':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFFFEDD5),
        badgeText: Color(0xFFEA580C),
        accentColor: Color(0xFFF97316),
        icon: Icons.warning_amber_rounded,
      );
    case 'result':
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFD1FAE5),
        badgeText: Color(0xFF059669),
        accentColor: Color(0xFF10B981),
        icon: Icons.check_circle_outline_rounded,
      );
    default: // General
      return const AnnouncementCategoryStyle(
        badgeBg: Color(0xFFE0E7FF),
        badgeText: Color(0xFF4338CA),
        accentColor: Color(0xFF4338CA),
        icon: Icons.campaign_outlined,
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample data (replace with repository calls)
// ─────────────────────────────────────────────────────────────────────────────

final announcementsList = <AnnouncementEntry>[
  AnnouncementEntry(
    id: 'ann-001',
    title: 'Overseas Exchange Briefing for May 2024',
    date: DateTime(2024, 5, 15, 10, 30),
    author: 'Ms. Rachel Tan',
    authorRole: 'Exchange Programme Coordinator',
    category: 'Event',
    tags: ['Exchange', 'Mandatory', 'May 2024'],
    body: '''Dear Scholars,

We would like to invite all scholars who are planning to participate in the Overseas Exchange Programme for the upcoming academic semester to attend a mandatory briefing session.

This briefing will cover the full application process, programme timeline, financial support available, and documentation required for your exchange application.

Date & Time: 15 May 2024, 10:30 AM
Venue: Seminar Room 3, Administration Block
Duration: Approximately 90 minutes

All scholars are strongly encouraged to attend as attendance will be recorded. If you are unable to attend, please notify your scholarship coordinator at least 48 hours in advance with a valid reason.

Please bring along your student card and the pre-briefing checklist that was sent to your registered email address.

For any queries, please contact the Scholarship Office at scholarship@dis-connect.sg or submit a support ticket through the DisConnect portal.

We look forward to seeing you there.''',
  ),
  AnnouncementEntry(
    id: 'ann-002',
    title: 'Internship Declaration Submission Deadline',
    date: DateTime(2024, 5, 20, 9, 0),
    author: 'Mr. David Lim',
    authorRole: 'Internship & Career Office',
    category: 'Deadline',
    tags: ['Internship', 'Deadline', 'Declaration'],
    body: '''Attention Scholars,

This is an important reminder that the Internship Declaration Form submission deadline is fast approaching. All scholars who are currently on an internship or have completed one in the current semester are required to submit their declaration.

Submission Deadline: 20 May 2024, 11:59 PM
Form: Available via DisConnect → Create Ticket → Category: Internship

Please ensure the following documents are attached with your submission:
• Internship offer letter or acceptance email
• Company registration details
• Supervisor's name and contact information
• Completed weekly log (where applicable)

Scholars who fail to submit by the stated deadline may have their scholarship allowance withheld pending receipt and approval of the declaration.

If you encounter any difficulties with the submission process, please raise a support ticket immediately so our team can assist you in time.

Do not delay — late submissions will not be accepted without prior approval.''',
  ),
  AnnouncementEntry(
    id: 'ann-003',
    title: 'Scholarship Results Released',
    date: DateTime(2024, 5, 22, 14, 0),
    author: 'Scholarship Office',
    authorRole: 'Administration',
    category: 'Result',
    tags: ['Scholarship', 'Results', 'Renewal'],
    body: '''Dear Scholars,

We are pleased to announce that the results for the Annual Scholarship Review have been released. You may view your updated scholarship status by navigating to your Profile in the DisConnect app.

We warmly congratulate all scholars who have maintained their academic standing and are eligible for scholarship renewal. Your continued dedication is truly commendable.

For scholars whose applications for renewal were reviewed this cycle, individual outcome letters have been sent to your registered email addresses. Please check your inbox and spam folder if you have not received your letter.

Next Steps:
• If renewed — no action required. Allowance disbursement will proceed as scheduled.
• If conditionally renewed — please follow the instructions in your outcome letter within 14 days.
• If not renewed — you are welcome to appeal within 21 days of this announcement.

If you have any questions regarding your scholarship status or the review outcome, please submit a ticket via the DisConnect portal and our team will respond within 3 – 5 business days.

The scholarship team wishes you all the very best in your continued academic journey.''',
  ),
  AnnouncementEntry(
    id: 'ann-004',
    title: 'Scheduled System Maintenance — 25 May 2024',
    date: DateTime(2024, 5, 25, 23, 0),
    author: 'DisConnect Tech Team',
    authorRole: 'Platform Support',
    category: 'Maintenance',
    tags: ['System', 'Downtime', 'Maintenance'],
    body: '''Dear Users,

Please be informed that scheduled maintenance will be carried out on the DisConnect platform to improve system performance and deploy critical security updates.

Maintenance Window:
Start: 25 May 2024, 11:00 PM (SGT)
End: 26 May 2024, 3:00 AM (SGT) (estimated)

Services Affected:
• Ticket submission and status updates
• File uploads and downloads
• User authentication (login / logout)
• Push notifications may be delayed

Read-only access to your existing tickets and profile information may also be affected intermittently during this window.

We strongly advise all users to complete any pending submissions before the maintenance window begins. Any tickets submitted close to or during the maintenance period may not be processed until after the maintenance is complete.

We apologise for any inconvenience this may cause and appreciate your patience and understanding.

If you experience any issues after the maintenance window has passed, please contact support at support@dis-connect.sg.''',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sorted = [...announcementsList]
      ..sort((a, b) {
        return b.date.compareTo(a.date);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              automaticallyImplyLeading: false,
              title: Text(
                'Announcements',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  fontSize: 18,
                ),
              ),
              centerTitle: false,
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AnnouncementCard(
                      entry: sorted[i],
                      onTap: () => context.push(
                        '/announcements/${sorted[i].id}',
                        extra: sorted[i],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Announcement card
// ─────────────────────────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementEntry entry;
  final VoidCallback onTap;
  const _AnnouncementCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = announcementCategoryStyle(entry.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Category accent strip ───────────────────────────────
                Container(width: 4, color: style.accentColor),

                // ── Content ─────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: style.badgeBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            style.icon,
                            color: style.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category badge
                              Row(children: [

                                ],
                              ),
                              const SizedBox(height: 6),

                              // Title
                              Text(
                                entry.title,
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Meta row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 12,
                                    color: AppColors.mute,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      entry.author,
                                      style: AppTypography.caption,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: AppColors.mute,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    DateFormat('d MMM yyyy').format(entry.date),
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Color(0xFFCBD5E1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final AnnouncementCategoryStyle style;
  const _CategoryBadge({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.badgeBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: style.badgeText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
