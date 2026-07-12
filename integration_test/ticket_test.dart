// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_driver.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Ticket flow integration tests
// ─────────────────────────────────────────────────────────────────────────────
// Covers the Ticket List screen and the Create Ticket multi-step form.
// Requires TEST_EMAIL / TEST_PASSWORD credentials.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Ticket list screen ────────────────────────────────────────────────────

  group('Ticket list screen', () {
    testWidgets(
      'shows the New Ticket floating action button',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Tickets');

        expect(find.text('New Ticket'), findsOneWidget);
      },
    );

    testWidgets(
      'shows the search bar on the ticket list screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Tickets');

        // The search bar on TicketListScreen uses a custom widget; verify
        // via its underlying TextField.
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'typing in the search bar filters tickets',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await tapNavTab(tester, 'Tickets');
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Enter a query that is unlikely to match any real ticket.
        await tester.enterText(
          find.byType(TextField),
          'zzzNonexistentQueryzzz',
        );
        await tester.pump();

        // Nothing should match — both sections should be empty.
        expect(find.text('Active'), findsNothing);
        expect(find.text('Resolved'), findsNothing);
      },
    );
  });

  // ── Create ticket — navigation ─────────────────────────────────────────────

  group('Create ticket — navigation', () {
    // Helper: navigate from ticket list to create ticket screen.
    Future<void> openCreateTicket(WidgetTester tester) async {
      await tapNavTab(tester, 'Tickets');
      await tester.tap(find.text('New Ticket'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    testWidgets(
      'tapping New Ticket opens the create ticket screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openCreateTicket(tester);

        // AppBar title of the create screen.
        expect(find.text('New Ticket'), findsOneWidget);
      },
    );

    testWidgets(
      'create ticket starts on step 1 — Ticket Info',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openCreateTicket(tester);

        // AppBar subtitle shows the current step title.
        expect(find.text('Ticket Info'), findsOneWidget);
      },
    );

    testWidgets(
      'create ticket step 1 shows the Subject field',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openCreateTicket(tester);

        expect(find.text('Subject'), findsOneWidget);
      },
    );

    testWidgets(
      'create ticket step 1 shows the Category field',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openCreateTicket(tester);

        expect(find.text('Category'), findsOneWidget);
      },
    );

    testWidgets(
      'back arrow from step 1 returns to the ticket list',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openCreateTicket(tester);

        // Tap the leading back arrow.
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Back on the ticket list — FAB is visible again.
        expect(find.text('New Ticket'), findsOneWidget);
        // Step subtitle is gone.
        expect(find.text('Ticket Info'), findsNothing);
      },
    );
  });
}
