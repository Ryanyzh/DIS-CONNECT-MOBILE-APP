// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_driver.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab navigation integration tests
// ─────────────────────────────────────────────────────────────────────────────
// All tests in this file require an authenticated session.
// Provide credentials via:
//   flutter test integration_test/navigation_test.dart \
//     --dart-define=TEST_EMAIL=... --dart-define=TEST_PASSWORD=...

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Sign in once before all tests in this file.
  setUpAll(
    () => print(
      credentialsAvailable
          ? '[setup] credentials available — tests will run.'
          : '[setup] No credentials — all tests will be skipped.',
    ),
  );

  // ── Bottom nav structure ──────────────────────────────────────────────────

  group('Bottom navigation bar', () {
    // The MainShell renders exactly four tab labels. If any label is missing
    // the scholar cannot reach that section of the app.
    testWidgets(
      'shows all four tab labels after login',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Tickets'), findsOneWidget);
        expect(find.text('Announcements'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      },
    );

    // The router's initialLocation is '/home', so the Home tab should be
    // the active one immediately after login — not Tickets or Profile.
    testWidgets(
      'Home tab is active immediately after login',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        // The home screen is uniquely identified by the 'My Overview' section
        // heading rendered by OverviewStatsCard.
        expect(find.text('My Overview'), findsOneWidget);
      },
    );
  });

  // ── Tab destinations ──────────────────────────────────────────────────────

  group('Tab destinations', () {
    // Tapping each tab must replace the body with the correct screen. We verify
    // by looking for a unique heading or landmark widget on each screen.

    testWidgets(
      'tapping Tickets tab shows the ticket list screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Tickets');

        // The ticket list FAB label is the most reliable identifier of that screen.
        expect(find.text('New Ticket'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Announcements tab shows the announcements screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Announcements');

        // The announcements screen AppBar title.
        expect(find.text('Announcements'), findsWidgets);
      },
    );

    testWidgets(
      'tapping Profile tab shows the profile screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Profile');

        // Profile screen heading is 'Profile' in a large display style.
        // findsWidgets because the tab label also says 'Profile'.
        expect(find.text('Profile'), findsWidgets);
        // Sign Out uniquely identifies the profile screen body.
        expect(find.text('Sign Out'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Home tab after visiting another tab returns to home',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        // Navigate away first.
        await tapNavTab(tester, 'Tickets');
        expect(find.text('My Overview'), findsNothing);

        // Return to home.
        await tapNavTab(tester, 'Home');
        expect(find.text('My Overview'), findsOneWidget);
      },
    );

    // Navigating across tabs and back must not push the same screen onto a
    // stack (StatefulShellRoute preserves each branch's state independently).
    testWidgets(
      'tab state is preserved when switching between tabs',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        // Visit tickets, then announcements, then return to tickets.
        // The ticket list should still be shown (not re-navigated to sub-route).
        await tapNavTab(tester, 'Tickets');
        await tapNavTab(tester, 'Announcements');
        await tapNavTab(tester, 'Tickets');

        expect(find.text('New Ticket'), findsOneWidget);
      },
    );
  });

  // ── Quick actions on home ─────────────────────────────────────────────────

  group('Home screen quick actions navigation', () {
    testWidgets(
      'tapping New Ticket quick action opens the create ticket screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        // The home screen has a Quick actions section with a "New Ticket" card.
        // 'New Ticket' text also appears on the ticket list FAB but we are on
        // the home screen right now.
        expect(find.text('Quick actions'), findsOneWidget);
        await tester.tap(find.text('New Ticket').first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // The create ticket screen's AppBar title.
        expect(find.text('New Ticket'), findsOneWidget);
        // Its step subtitle uniquely confirms we're on the create screen.
        expect(find.text('Ticket Info'), findsOneWidget);
      },
    );
  });
}
