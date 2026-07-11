import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/home/widgets/recent_tickets_section.dart';
import 'package:disconnect_mobile/features/tickets/models/ticket_model.dart';

// Builds a scrollable scaffold so RecentTicketsSection (which uses a
// shrink-wrapped ListView internally) always has a bounded height.
Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

// Factory for Ticket test data — only supply the fields relevant to each test.
Ticket _ticket({
  String id = 't1',
  String displayId = 'TKT-001',
  String title = 'Test Ticket',
  String category = 'Policy',
  String status = 'Open',
  String priority = 'Low',
  DateTime? createdAt,
}) => Ticket(
  id: id,
  displayId: displayId,
  title: title,
  category: category,
  status: status,
  priority: priority,
  createdAt: createdAt,
);

void main() {
  // ── RecentTicketsSection ──────────────────────────────────────────────────
  // This widget appears at the bottom of the home screen. It shows the scholar's
  // most recent support tickets so they can track progress at a glance.
  // Three states matter: empty list, single ticket, and multiple tickets.

  // ── Empty state ───────────────────────────────────────────────────────────

  group('RecentTicketsSection — empty state', () {
    // A new scholar who has not filed any tickets must see a friendly message,
    // not a blank white box or an error.
    testWidgets('shows "No recent tickets" when the list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(RecentTicketsSection(tickets: const [])));
      expect(find.text('No recent tickets'), findsOneWidget);
    });

    // The 'View all' link is always rendered (even on empty state) so the
    // scholar can navigate to the full ticket list without going to the nav bar.
    testWidgets('always shows the View all link', (tester) async {
      await tester.pumpWidget(_wrap(RecentTicketsSection(tickets: const [])));
      expect(find.text('View all'), findsOneWidget);
    });
  });

  // ── Single ticket ─────────────────────────────────────────────────────────

  group('RecentTicketsSection — single ticket content', () {
    // The display ID (e.g. TKT-001) is the primary identifier a scholar uses
    // when following up with HR; it must be prominently visible.
    testWidgets('shows the ticket displayId', (tester) async {
      await tester.pumpWidget(
        _wrap(RecentTicketsSection(tickets: [_ticket(displayId: 'TKT-042')])),
      );
      expect(find.text('TKT-042'), findsOneWidget);
    });

    // The ticket title gives context without needing to open the detail screen.
    testWidgets('shows the ticket title', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RecentTicketsSection(
            tickets: [_ticket(title: 'Reimbursement for Books')],
          ),
        ),
      );
      expect(find.text('Reimbursement for Books'), findsOneWidget);
    });

    // The status badge lets scholars see at a glance whether action is needed.
    testWidgets('shows the status badge text', (tester) async {
      await tester.pumpWidget(
        _wrap(RecentTicketsSection(tickets: [_ticket(status: 'In Review')])),
      );
      expect(find.text('In Review'), findsOneWidget);
    });

    // The date helps scholars assess how long a ticket has been open.
    // Using 1 Jun 2025 — the formatted output is locale-independent for
    // the date portion ('1 Jun 2025') regardless of AM/PM locale settings.
    testWidgets('shows the formatted createdAt date when present', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          RecentTicketsSection(
            tickets: [_ticket(createdAt: DateTime(2025, 6, 1))],
          ),
        ),
      );
      expect(find.textContaining('1 Jun 2025'), findsOneWidget);
    });

    // When createdAt is null (e.g. backend hasn't set it yet) the date row
    // must be omitted rather than showing 'null' or a blank space.
    testWidgets('hides the date row when createdAt is null', (tester) async {
      await tester.pumpWidget(
        _wrap(RecentTicketsSection(tickets: [_ticket(createdAt: null)])),
      );
      // No date-like text should appear alongside the ticket row.
      expect(find.textContaining('Jun'), findsNothing);
    });
  });
}
