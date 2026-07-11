import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/home/widgets/announcement_banner.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// Fixed date used across tests — noon avoids any AM/PM locale ambiguity when
// checking the rendered date string.
final _date = DateTime(2025, 8, 15, 12, 0);

AnnouncementBanner _banner({
  String title = 'Test Announcement',
  DateTime? date,
  VoidCallback? onTap,
}) => AnnouncementBanner(
  announcement: AnnouncementItem(
    title: title,
    date: date ?? _date,
    onTap: onTap,
  ),
);

void main() {
  // ── AnnouncementBanner ────────────────────────────────────────────────────
  // The banner sits at the top of the home screen and highlights the most
  // recent announcement. It is the first thing a scholar sees after logging in,
  // so the title, date, and CTA button must all render correctly.

  // ── Content rendering ─────────────────────────────────────────────────────

  group('AnnouncementBanner — content', () {
    // The announcement title is the primary text; scholars must be able to read
    // what the announcement is about without tapping into it.
    testWidgets('displays the announcement title', (tester) async {
      await tester.pumpWidget(_wrap(
        _banner(title: 'New Exchange Programme Deadline'),
      ));
      expect(find.text('New Exchange Programme Deadline'), findsOneWidget);
    });

    // The date tells scholars how recent the announcement is. The banner
    // formats it as 'd MMM yyyy h:mm a'; we check the date portion which is
    // locale-independent (intl uses English month abbreviations by default).
    testWidgets('displays the formatted date', (tester) async {
      await tester.pumpWidget(_wrap(
        _banner(date: DateTime(2025, 8, 15, 12, 0)),
      ));
      expect(find.textContaining('15 Aug 2025'), findsOneWidget);
    });

    // The 'View details' button is the CTA that drives scholars into the detail
    // screen; it must always be visible regardless of the announcement content.
    testWidgets('shows the View details button', (tester) async {
      await tester.pumpWidget(_wrap(_banner()));
      expect(find.text('View details'), findsOneWidget);
    });

    // The campaign icon is the visual anchor of the banner. It should be present
    // in the widget tree so the banner is recognisable even at small sizes.
    testWidgets('shows the campaign icon', (tester) async {
      await tester.pumpWidget(_wrap(_banner()));
      expect(find.byIcon(Icons.campaign_rounded), findsOneWidget);
    });
  });

  // ── Interaction ───────────────────────────────────────────────────────────

  group('AnnouncementBanner — tap behaviour', () {
    // The View details button must fire the onTap callback so the home screen
    // can push the announcement detail route.
    testWidgets('fires onTap when View details is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(_banner(onTap: () => tapped = true)));

      await tester.tap(find.text('View details'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    // If no onTap handler is supplied (e.g. navigation not yet wired up in a
    // placeholder build), tapping must not throw an unhandled null exception.
    testWidgets('does not crash when onTap is null and button is tapped',
        (tester) async {
      await tester.pumpWidget(_wrap(_banner(onTap: null)));
      await tester.tap(find.text('View details'));
      await tester.pump();
      // Reaching here means the null GestureDetector.onTap is safe to omit.
    });
  });

  // ── AnnouncementItem model ─────────────────────────────────────────────────

  group('AnnouncementItem', () {
    // onTap is optional so callers that only need to display the banner
    // (e.g. in a read-only list) can omit the callback.
    test('onTap defaults to null', () {
      final item = AnnouncementItem(title: 'Hello', date: _date);
      expect(item.onTap, isNull);
    });

    // Verify that all three fields round-trip correctly through the constructor
    // so the banner widget receives what the caller intended.
    test('stores title, date, and onTap correctly', () {
      var called = false;
      final item = AnnouncementItem(
        title: 'Important Notice',
        date: _date,
        onTap: () => called = true,
      );
      expect(item.title, 'Important Notice');
      expect(item.date, _date);
      item.onTap!();
      expect(called, isTrue);
    });
  });
}
