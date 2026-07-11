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
}
