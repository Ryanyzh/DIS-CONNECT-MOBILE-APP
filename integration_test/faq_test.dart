// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_driver.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FAQ screen integration tests
// ─────────────────────────────────────────────────────────────────────────────
// The FAQ screen is accessible from the Home screen's quick-actions ("Ask HR"
// pushes /profile/help) or via /faqs. These tests navigate there via the
// home "Ask HR" card which routes to /profile/help — the FAQ standalone route
// is navigated to via the profile/help screen if one exists, or directly.
//
// NOTE: The router registers /faqs as a standalone GoRoute. These tests reach
// it by using the Home → Ask HR quick-action which goes to /profile/help.
// Adjust the navigation helper if your app's path to FAQs changes.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper — navigate to the FAQ screen via the Ask HR quick action on home.
  // Falls back to checking /profile/help which may embed FAQ content.
  Future<void> openFaqViaAskHr(WidgetTester tester) async {
    // Ensure we are on the home tab.
    await tapNavTab(tester, 'Home');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 'Ask HR' quick action pushes /profile/help.
    await tester.tap(find.text('Ask HR'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // ── Help & Support screen (reached via Ask HR) ────────────────────────────

  group('Help & Support screen (via Ask HR)', () {
    testWidgets(
      'tapping Ask HR from home opens the Help and Support screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openFaqViaAskHr(tester);

        expect(find.text('Help & Support'), findsOneWidget);
      },
    );

    testWidgets(
      'Help and Support screen has a back navigation button',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openFaqViaAskHr(tester);

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      },
    );

    testWidgets(
      'tapping back from Help and Support returns to the home screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openFaqViaAskHr(tester);
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('My Overview'), findsOneWidget);
      },
    );
  });
}
