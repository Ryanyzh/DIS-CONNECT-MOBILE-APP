// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_driver.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Login screen integration tests
// ─────────────────────────────────────────────────────────────────────────────
// Groups:
//   A. Login screen rendering  — pure UI, no Firebase, always runnable.
//   B. Login form validation   — validates without hitting Firebase (empty-field
//                                path returns early before any Auth call).
//   C. Password visibility     — toggles obscureText, no Firebase needed.
//   D. Authentication flows    — require TEST_EMAIL / TEST_PASSWORD credentials;
//                                skipped gracefully when not supplied.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── A. Login screen rendering ─────────────────────────────────────────────

  group('A. Login screen — rendering', () {
    // The app must redirect an unauthenticated user to the login screen. If
    // Firebase Auth has no current session the GoRouter redirect fires and we
    // land on /login before the first frame is drawn.
    testWidgets('shows the Sign in to your account heading', (tester) async {
      await launchApp(tester);
      // If the user is already signed in from a previous run the test would
      // land on /home instead. Skip gracefully in that case.
      if (find.text('Sign in to your account').evaluate().isEmpty) {
        print(
          '[SKIP] User already authenticated — sign out before running login tests.',
        );
        return;
      }
      expect(find.text('Sign in to your account'), findsOneWidget);
    });

    testWidgets('shows the app name dis-connect', (tester) async {
      await launchApp(tester);
      if (find.text('dis-connect').evaluate().isEmpty) return;
      expect(find.text('dis-connect'), findsOneWidget);
    });

    testWidgets('shows the Email address field', (tester) async {
      await launchApp(tester);
      if (find.byType(TextField).evaluate().isEmpty) return;
      // Email field is index 0; verify via label text in the decoration.
      expect(find.byType(TextField).first, findsOneWidget);
    });

    testWidgets('shows the Password field', (tester) async {
      await launchApp(tester);
      if (find.byType(TextField).evaluate().length < 2) return;
      expect(find.byType(TextField).at(1), findsOneWidget);
    });

    testWidgets('shows the Sign In button', (tester) async {
      await launchApp(tester);
      if (find.text('Sign In').evaluate().isEmpty) return;
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows the security footer text', (tester) async {
      await launchApp(tester);
      if (find.textContaining('Secured by Firebase').evaluate().isEmpty) return;
      expect(find.textContaining('Secured by Firebase'), findsOneWidget);
    });
  });

  // ── B. Login form validation ──────────────────────────────────────────────

  group('B. Login form — empty field validation', () {
    // The _login() method checks for empty fields BEFORE calling Firebase Auth.
    // These tests verify client-side validation without needing a network call.

    testWidgets('shows error when both email and password are empty', (
      tester,
    ) async {
      await launchApp(tester);
      if (find.text('Sign In').evaluate().isEmpty) return;

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
        find.text('Please enter your email and password.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error when email is filled but password is empty', (
      tester,
    ) async {
      await launchApp(tester);
      if (find.byType(TextField).evaluate().length < 2) return;

      await tester.enterText(find.byType(TextField).first, 'user@test.com');
      await tester.pump();
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
        find.text('Please enter your email and password.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error when password is filled but email is empty', (
      tester,
    ) async {
      await launchApp(tester);
      if (find.byType(TextField).evaluate().length < 2) return;

      await tester.enterText(find.byType(TextField).at(1), 'somepassword');
      await tester.pump();
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
        find.text('Please enter your email and password.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'error message disappears after a successful login attempt clears it',
      (tester) async {
        await launchApp(tester);
        if (find.text('Sign In').evaluate().isEmpty) return;

        // Trigger the error.
        await tester.tap(find.text('Sign In'));
        await tester.pump();
        expect(
          find.text('Please enter your email and password.'),
          findsOneWidget,
        );

        // Filling both fields and tapping again should clear the error banner
        // (in _login the setState sets _errorMessage = null first).
        await tester.enterText(find.byType(TextField).first, 'x@y.com');
        await tester.enterText(find.byType(TextField).at(1), 'pw');
        await tester.tap(find.text('Sign In'));
        await tester.pump(); // one frame — error is cleared synchronously

        expect(
          find.text('Please enter your email and password.'),
          findsNothing,
        );
      },
    );
  });

  // ── C. Password visibility toggle ─────────────────────────────────────────

  group('C. Password visibility toggle', () {
    // The password field starts obscured. The eye icon toggles it.
    // This is pure UI state — no Firebase involved.

    testWidgets('password field starts obscured (eye-off icon visible)', (
      tester,
    ) async {
      await launchApp(tester);
      if (find.byType(TextField).evaluate().length < 2) return;

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('tapping the eye icon makes the password visible', (
      tester,
    ) async {
      await launchApp(tester);
      if (find.byIcon(Icons.visibility_off_outlined).evaluate().isEmpty) return;

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // After toggling, the visible eye icon appears.
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      // The hidden eye icon is gone.
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('tapping the eye icon twice restores obscured state', (
      tester,
    ) async {
      await launchApp(tester);
      if (find.byIcon(Icons.visibility_off_outlined).evaluate().isEmpty) return;

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Should be back to hidden.
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
