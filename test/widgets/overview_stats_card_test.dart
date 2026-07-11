import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/home/widgets/overview_stats_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

OverviewStatsCard _card(TicketOverview overview) =>
    OverviewStatsCard(overview: overview);

void main() {
  // ── OverviewStatsCard ─────────────────────────────────────────────────────
  // The card sits at the top of the home screen and gives scholars an instant
  // summary of their ticket activity. Four stat cells render in a single row;
  // each shows a count and a label. Getting the count or label wrong would
  // silently mislead users about the state of their support requests.

  // ── Section labels ────────────────────────────────────────────────────────

  group('OverviewStatsCard — stat labels', () {
    // All four labels must be visible so the card is self-explanatory
    // without requiring the scholar to tap into each category.
    testWidgets('shows the My Overview section heading', (tester) async {
      await tester.pumpWidget(_wrap(_card(const TicketOverview())));
      expect(find.text('My Overview'), findsOneWidget);
    });

    testWidgets('shows In Review label', (tester) async {
      await tester.pumpWidget(_wrap(_card(const TicketOverview())));
      expect(find.text('In Review'), findsOneWidget);
    });

    testWidgets('shows Waiting label', (tester) async {
      await tester.pumpWidget(_wrap(_card(const TicketOverview())));
      expect(find.text('Waiting'), findsOneWidget);
    });

    testWidgets('shows Resolved label', (tester) async {
      await tester.pumpWidget(_wrap(_card(const TicketOverview())));
      expect(find.text('Resolved'), findsOneWidget);
    });

    testWidgets('shows Closed label', (tester) async {
      await tester.pumpWidget(_wrap(_card(const TicketOverview())));
      expect(find.text('Closed'), findsOneWidget);
    });
  });

  // ── Stat counts ───────────────────────────────────────────────────────────

  group('OverviewStatsCard — counts', () {
    // Counts are rendered as strings from an integer. Verify each field maps
    // to its own cell so a Waiting count cannot bleed into the Resolved cell.
    testWidgets('displays the inReview count', (tester) async {
      await tester.pumpWidget(_wrap(
        _card(const TicketOverview(inReview: 3)),
      ));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('displays the waiting count', (tester) async {
      await tester.pumpWidget(_wrap(
        _card(const TicketOverview(waiting: 5)),
      ));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays the resolved count', (tester) async {
      await tester.pumpWidget(_wrap(
        _card(const TicketOverview(resolved: 12)),
      ));
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('displays the closed count', (tester) async {
      await tester.pumpWidget(_wrap(
        _card(const TicketOverview(closed: 7)),
      ));
      expect(find.text('7'), findsOneWidget);
    });

    // A new scholar with no tickets must see zeros, not blanks or nulls, so
    // the card always renders a complete row of four cells.
    testWidgets('shows 0 for every count when all are zero (default)', (tester) async {
      await tester.pumpWidget(_wrap(_card(const TicketOverview())));
      // Four separate '0' texts, one per stat cell.
      expect(find.text('0'), findsNWidgets(4));
    });

    // With all four fields set, each unique count must appear exactly once —
    // no cell should accidentally display another cell's value.
    testWidgets('shows all four different counts simultaneously', (tester) async {
      await tester.pumpWidget(_wrap(
        _card(const TicketOverview(
          inReview: 1,
          waiting:  2,
          resolved: 3,
          closed:   4,
        )),
      ));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    // Power users or batch imports can produce large counts. Verify the widget
    // renders a three-digit number without truncation or overflow.
    testWidgets('renders large counts without layout overflow', (tester) async {
      await tester.pumpWidget(_wrap(
        _card(const TicketOverview(inReview: 999)),
      ));
      expect(find.text('999'), findsOneWidget);
      // Flutter's test framework fails the test if any RenderFlex overflows
      // are logged during pump, so reaching here means no overflow occurred.
    });
  });

  // ── TicketOverview model ──────────────────────────────────────────────────
  // TicketOverview is a simple value type; verify its default values so callers
  // can safely omit fields they don't have data for.

  group('TicketOverview — defaults', () {
    // All fields default to zero so partial responses from the API never
    // leave the card displaying null or negative numbers.
    test('all counts default to zero', () {
      const o = TicketOverview();
      expect(o.inReview, 0);
      expect(o.waiting, 0);
      expect(o.resolved, 0);
      expect(o.closed, 0);
    });
  });
}
