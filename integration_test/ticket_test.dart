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
}
