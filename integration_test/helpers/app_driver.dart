// Shared helpers for all integration tests.
//
// HOW TO RUN INTEGRATION TESTS
// ─────────────────────────────
// 1. Create a real Scholar user in Firebase Auth for testing.
//    Never use a real user's credentials — use a dedicated test account.
//
// 2. Start the app on a connected device / simulator, then run:
//
//      flutter test integration_test/ \
//        --dart-define=TEST_EMAIL=testscholar@example.com \
//        --dart-define=TEST_PASSWORD=yourTestPassword
//
// 3. For a single test file:
//
//      flutter test integration_test/login_test.dart \
//        --dart-define=TEST_EMAIL=... \
//        --dart-define=TEST_PASSWORD=...

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/main.dart' as app;

// Credentials injected at compile time via --dart-define so they are never
// committed to source control.
const kTestEmail    = String.fromEnvironment('TEST_EMAIL',    defaultValue: '');
const kTestPassword = String.fromEnvironment('TEST_PASSWORD', defaultValue: '');

// Returns true when test credentials have been provided.
bool get credentialsAvailable =>
    kTestEmail.isNotEmpty && kTestPassword.isNotEmpty;

// Skip message shown when credentials are missing.
const kSkipNoCredentials =
    'Skipped — supply TEST_EMAIL and TEST_PASSWORD via --dart-define';

// ─────────────────────────────────────────────────────────────────────────────
// App lifecycle
// ─────────────────────────────────────────────────────────────────────────────

/// Boots the full DisConnect app and waits for the first frame to stabilise.
/// The GoRouter redirect will land the user on /login if unauthenticated, or
/// /home if they still have an active Firebase session from a previous run.
Future<void> launchApp(WidgetTester tester) async {
  app.main();
  // Allow Firebase.initializeApp() + GoRouter redirect + first build to settle.
  await tester.pumpAndSettle(const Duration(seconds: 6));
}

// ─────────────────────────────────────────────────────────────────────────────
// Authentication helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Signs in using the login screen UI.
/// Assumes the login screen is currently displayed.
Future<void> signIn(
  WidgetTester tester, {
  String email    = kTestEmail,
  String password = kTestPassword,
}) async {
  // The login screen renders exactly two TextFields in document order:
  // index 0 = Email address, index 1 = Password.
  final fields = find.byType(TextField);

  await tester.tap(fields.first);
  await tester.enterText(fields.first, email);
  await tester.pump();

  await tester.tap(fields.at(1));
  await tester.enterText(fields.at(1), password);
  await tester.pump();

  // 'Sign In' is the GradientButton label (different case from the heading
  // "Sign in to your account", so the finder is unambiguous).
  await tester.tap(find.text('Sign In'));

  // Firebase Auth round-trip + GoRouter redirect to /home.
  await tester.pumpAndSettle(const Duration(seconds: 10));
}

/// Signs the current user out via the Profile tab's Sign Out button, then
/// waits for the app to return to the login screen.
Future<void> signOut(WidgetTester tester) async {
  await tapNavTab(tester, 'Profile');

  // Scroll to the bottom to make Sign Out visible.
  await tester.drag(find.byType(SingleChildScrollView).last, const Offset(0, -600));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Sign Out'));
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Taps a bottom navigation tab by its label text.
Future<void> tapNavTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

/// Pumps the widget tree for [seconds] seconds in 100 ms increments.
/// Use this instead of pumpAndSettle when the screen has an ongoing
/// animation (e.g. pull-to-refresh spinner) that never fully settles.
Future<void> pumpSeconds(WidgetTester tester, int seconds) async {
  for (int i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
