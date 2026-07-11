import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:disconnect_mobile/features/home/widgets/quick_actions_section.dart';

// Wraps QuickActionsSection in a GoRouter tree so context.go() / context.push()
// calls in the widget don't throw. Stub routes for each navigation target are
// defined so we can verify navigation by checking what's now on screen.
Widget _wrapWithRouter({String initialLocation = '/'}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(
          body: SingleChildScrollView(child: QuickActionsSection()),
        ),
      ),
      GoRoute(
        path: '/tickets/create',
        builder: (_, _) => const Scaffold(body: Text('Create Ticket Screen')),
      ),
      GoRoute(
        path: '/profile/help',
        builder: (_, _) => const Scaffold(body: Text('Help Screen')),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

void main() {
  // ── QuickActionsSection ───────────────────────────────────────────────────
  // Sits on the home screen and provides one-tap access to the two most common
  // scholar actions: filing a new ticket and reaching out to HR. Both cards
  // must render and navigate to the correct screens.

  // ── Rendering ─────────────────────────────────────────────────────────────

  group('QuickActionsSection — rendering', () {
    // Both action cards must always be visible. If either disappears (e.g. due
    // to a conditional that was added by mistake), scholars lose a key shortcut.
    testWidgets('shows the New Ticket action card', (tester) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pumpAndSettle();
      expect(find.text('New Ticket'), findsOneWidget);
    });

    testWidgets('shows the Ask HR action card', (tester) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pumpAndSettle();
      expect(find.text('Ask HR'), findsOneWidget);
    });

    // The 'Quick actions' section heading labels the row so first-time users
    // understand what the cards do at a glance.
    testWidgets('shows the Quick actions section heading', (tester) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pumpAndSettle();
      expect(find.text('Quick actions'), findsOneWidget);
    });

    // Both action card icons must be rendered so the cards are visually
    // distinguishable even before the label text is read.
    testWidgets('renders the article icon for New Ticket', (tester) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.article_outlined), findsOneWidget);
    });

    testWidgets('renders the chat icon for Ask HR', (tester) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });
  });

  // ── Navigation ────────────────────────────────────────────────────────────

  group('QuickActionsSection — navigation', () {
    // Tapping New Ticket must navigate to /tickets/create so scholars can file
    // a support request without going through the bottom nav bar.
    testWidgets('tapping New Ticket navigates to the create-ticket screen',
        (tester) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Ticket'));
      await tester.pumpAndSettle();

      expect(find.text('Create Ticket Screen'), findsOneWidget);
    });

    // Tapping Ask HR must navigate to /profile/help so scholars can reach the
    // help & support page directly from the home screen.
    testWidgets('tapping Ask HR navigates to the help screen', (tester) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ask HR'));
      await tester.pumpAndSettle();

      expect(find.text('Help Screen'), findsOneWidget);
    });
  });
}
