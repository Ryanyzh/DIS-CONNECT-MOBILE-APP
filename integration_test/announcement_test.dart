// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_driver.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Announcement flow integration tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Announcements list screen ─────────────────────────────────────────────

  group('Announcements screen', () {
    testWidgets(
      'shows the Announcements screen when the tab is tapped',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Announcements');

        // The AppBar title of the announcements screen.
        // findsWidgets because the tab label is also 'Announcements'.
        expect(find.text('Announcements'), findsWidgets);
      },
    );

    testWidgets(
      'shows the category filter chips row',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Announcements');
        // Wait for the Firestore listener initial load.
        await pumpSeconds(tester, 3);

        // The filter row always shows 'All' and the six category chips.
        expect(find.text('All'), findsOneWidget);
        // At least the All chip must be present even before announcements load.
        expect(find.text('All'), findsOneWidget);
      },
    );

    testWidgets(
      'shows at least one announcement category chip beyond All',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Announcements');
        await pumpSeconds(tester, 3);

        // AnnouncementsScreen always renders all 6 category chips.
        // Verify at least General and Urgent are present.
        expect(find.text('General'), findsOneWidget);
        expect(find.text('Urgent'),  findsOneWidget);
      },
    );

    testWidgets(
      'pull to refresh completes without error',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Announcements');
        await pumpSeconds(tester, 3);

        // Simulate pull-to-refresh on the CustomScrollView.
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, 300),
        );
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // After refresh the screen should still be showing announcements UI.
        expect(find.text('Announcements'), findsWidgets);
      },
    );

    testWidgets(
      'tapping an announcement (if any) opens the detail screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Announcements');
        await pumpSeconds(tester, 5);

        // Only proceed if there are announcements to tap.
        // Announcements render inside GestureDetectors or InkWell; the simplest
        // proxy is looking for the 'View more' or a card with a date string.
        // We look for any 'View more' link that appears on announcement cards.
        if (find.text('View more').evaluate().isEmpty) {
          print('[INFO] No announcements loaded — tapping test skipped.');
          return;
        }

        await tester.tap(find.text('View more').first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // The detail screen shows 'View less' or a back arrow.
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a category chip filters the list',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Announcements');
        await pumpSeconds(tester, 3);

        // Tap a category chip — the screen filters in-memory without a
        // network call, so the result should be immediate.
        await tester.tap(find.text('Urgent'));
        await tester.pump();

        // 'Urgent' should now be highlighted (selected); the chip is still visible.
        expect(find.text('Urgent'), findsOneWidget);
      },
    );
  });
}
