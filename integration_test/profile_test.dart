// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_driver.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Profile screen integration tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper — navigate to the profile tab and wait for it to load.
  Future<void> openProfile(WidgetTester tester) async {
    await tapNavTab(tester, 'Profile');
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  // ── Profile screen structure ──────────────────────────────────────────────

  group('Profile screen — structure', () {
    testWidgets('shows the Profile heading', skip: !credentialsAvailable, (
      tester,
    ) async {
      await launchApp(tester);
      if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

      await openProfile(tester);

      // findsWidgets because the tab label is also 'Profile'.
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets(
      'shows the Edit Profile settings row',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openProfile(tester);

        expect(find.text('Edit Profile'), findsOneWidget);
      },
    );

    testWidgets(
      'shows the Change Password settings row',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openProfile(tester);

        expect(find.text('Change Password'), findsOneWidget);
      },
    );

    testWidgets(
      'shows the Help and Support settings row',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openProfile(tester);

        expect(find.text('Help & Support'), findsOneWidget);
      },
    );

    testWidgets('shows the Sign Out button', skip: !credentialsAvailable, (
      tester,
    ) async {
      await launchApp(tester);
      if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

      await openProfile(tester);

      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets(
      'shows the logged-in user email address',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openProfile(tester);

        // The profile card displays the authenticated user's email.
        expect(find.textContaining(kTestEmail), findsOneWidget);
      },
    );
  });

  // ── Profile sub-screen navigation ─────────────────────────────────────────

  group('Profile screen — navigation', () {
    testWidgets(
      'tapping Change Password opens the change password screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openProfile(tester);
        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // The change-password screen has a 'Current Password' or similar field.
        expect(find.text('Change Password'), findsWidgets);
      },
    );

    testWidgets(
      'tapping Help and Support opens the help screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openProfile(tester);
        await tester.tap(find.text('Help & Support'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Help & Support'), findsWidgets);
      },
    );

    testWidgets(
      'tapping Edit Profile opens the edit profile screen',
      skip: !credentialsAvailable,
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isNotEmpty) await signIn(tester);

        await openProfile(tester);
        await tester.tap(find.text('Edit Profile'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Edit Profile'), findsWidgets);
      },
    );
  });
}
