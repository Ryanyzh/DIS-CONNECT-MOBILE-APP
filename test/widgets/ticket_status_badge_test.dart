import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/tickets/widgets/ticket_status_badge.dart';

// Helper — provides the minimal widget tree needed to pump a bare widget.
Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  // ── TicketStatusBadge widget ──────────────────────────────────────────────
  // Tests that the badge renders the correct text and honours the fontSize
  // parameter. Colour correctness is verified separately via ticketStatusStyle()
  // so these tests stay focused on the widget's structural output.

  group('TicketStatusBadge — rendering', () {
    // The primary job of the badge is to display the status string.
    // Users and screen-readers both depend on the exact text being present.
    testWidgets('renders the status string as visible text', (tester) async {
      await tester.pumpWidget(
        _wrap(const TicketStatusBadge(status: 'In Review')),
      );
      expect(find.text('In Review'), findsOneWidget);
    });

    // Verify each status value produces a visible label so no status is
    // silently dropped or replaced by a fallback.
    testWidgets('renders Waiting text', (tester) async {
      await tester.pumpWidget(
        _wrap(const TicketStatusBadge(status: 'Waiting')),
      );
      expect(find.text('Waiting'), findsOneWidget);
    });

    testWidgets('renders Open text', (tester) async {
      await tester.pumpWidget(_wrap(const TicketStatusBadge(status: 'Open')));
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('renders Resolved text', (tester) async {
      await tester.pumpWidget(
        _wrap(const TicketStatusBadge(status: 'Resolved')),
      );
      expect(find.text('Resolved'), findsOneWidget);
    });

    testWidgets('renders Closed text', (tester) async {
      await tester.pumpWidget(_wrap(const TicketStatusBadge(status: 'Closed')));
      expect(find.text('Closed'), findsOneWidget);
    });

    // The default fontSize of 11 is chosen so badges fit in tight list rows.
    // Verifying the default prevents accidental style regressions.
    testWidgets('uses default fontSize of 11 when not specified', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const TicketStatusBadge(status: 'Open')));
      final text = tester.widget<Text>(find.text('Open'));
      expect(text.style?.fontSize, 11);
    });

    // Callers that need a larger badge (e.g. the detail screen header) pass a
    // custom fontSize. Verify it is forwarded to the Text widget.
    testWidgets('applies a custom fontSize when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(const TicketStatusBadge(status: 'Open', fontSize: 16)),
      );
      final text = tester.widget<Text>(find.text('Open'));
      expect(text.style?.fontSize, 16);
    });

    // An unknown status (e.g. a new server value) must not crash; the badge
    // falls through to the default (closed-style) colours and still displays text.
    testWidgets('renders an unknown status without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(const TicketStatusBadge(status: 'Pending Approval')),
      );
      expect(find.text('Pending Approval'), findsOneWidget);
    });
  });

  // ── ticketStatusStyle() ───────────────────────────────────────────────────
  // Pure function — no widget pumping needed. Each status maps to a specific
  // colour palette; these colours drive badge background and text colour across
  // every screen that shows a ticket status, so regressions here affect the
  // whole app's visual language.

  group('ticketStatusStyle() — colour mapping', () {
    // Blue = "active review in progress" — calming, informational.
    test('In Review → blue badge and text colours', () {
      final s = ticketStatusStyle('In Review');
      expect(s.badgeBg, const Color(0xFFDBEAFE));
      expect(s.badgeText, const Color(0xFF1D4ED8));
    });

    // Orange = "awaiting scholar action" — draws attention without alarm.
    test('Waiting → orange badge and text colours', () {
      final s = ticketStatusStyle('Waiting');
      expect(s.badgeBg, const Color(0xFFFFEDD5));
      expect(s.badgeText, const Color(0xFFEA580C));
    });

    // Purple = matches the app's primary brand colour for newly created tickets.
    test('Open → purple badge and text colours', () {
      final s = ticketStatusStyle('Open');
      expect(s.badgeBg, const Color(0xFFEDE9FE));
      expect(s.badgeText, const Color(0xFF7C3AED));
    });

    // Green = positive outcome, ticket fully addressed.
    test('Resolved → green badge and text colours', () {
      final s = ticketStatusStyle('Resolved');
      expect(s.badgeBg, const Color(0xFFD1FAE5));
      expect(s.badgeText, const Color(0xFF059669));
    });

    // Gray = neutral / archived — closed tickets should not compete for
    // attention with active ones.
    test('Closed (default) → gray badge and text colours', () {
      final s = ticketStatusStyle('Closed');
      expect(s.badgeBg, const Color(0xFFF1F5F9));
      expect(s.badgeText, const Color(0xFF64748B));
    });

    // Unknown future status values fall to the same neutral gray so the UI
    // never breaks when the backend adds a new status.
    test('unknown status → gray fallback colours', () {
      final s = ticketStatusStyle('Unknown Status');
      expect(s.badgeBg, const Color(0xFFF1F5F9));
      expect(s.badgeText, const Color(0xFF64748B));
    });

    // API responses may use different capitalisation; the switch is lowercase-
    // normalised so 'in review' and 'In Review' map to the same palette.
    test('match is case-insensitive', () {
      expect(
        ticketStatusStyle('in review').badgeBg,
        ticketStatusStyle('In Review').badgeBg,
      );
      expect(
        ticketStatusStyle('RESOLVED').badgeBg,
        ticketStatusStyle('resolved').badgeBg,
      );
    });
  });

  // ── statusSortOrder() ─────────────────────────────────────────────────────
  // Controls the order in which status groups appear in the ticket list.
  // "In Review" (requires active attention) surfaces first; archived tickets
  // sink to the bottom. Changing this order would re-arrange every ticket list.

  group('statusSortOrder() — sort priority', () {
    // In Review tickets need HR attention right now — they must appear first.
    test('In Review has the lowest sort order (0)', () {
      expect(statusSortOrder('In Review'), 0);
    });

    test('Waiting is second (1)', () {
      expect(statusSortOrder('Waiting'), 1);
    });

    test('Open is third (2)', () {
      expect(statusSortOrder('Open'), 2);
    });

    test('Resolved is fourth (3)', () {
      expect(statusSortOrder('Resolved'), 3);
    });

    // Closed and any unknown status share the lowest-priority slot (4).
    test('Closed / unknown status has the highest sort order (4)', () {
      expect(statusSortOrder('Closed'), 4);
      expect(statusSortOrder('Archived'), 4);
    });

    // Sorting uses the lowercased form internally, so mixed-case inputs must
    // produce the same sort order as canonical ones.
    test('sort order is case-insensitive', () {
      expect(statusSortOrder('in review'), statusSortOrder('In Review'));
      expect(statusSortOrder('WAITING'), statusSortOrder('Waiting'));
    });
  });
}
