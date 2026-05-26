import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/tickets/presentation/ticket_list_screen.dart';
import '../features/tickets/presentation/create_ticket_screen.dart';
import '../features/announcements/presentation/announcements_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../shared/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/home',

  // ── Auth redirect ──────────────────────────────────────────────────────────
  redirect: (context, state) {
    final signedIn = FirebaseAuth.instance.currentUser != null;
    final onLoginPage = state.matchedLocation == '/login';

    if (!signedIn && !onLoginPage) return '/login';
    if (signedIn && onLoginPage) return '/home';
    return null;
  },

  routes: [
    // ── Unauthenticated ──────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ── Authenticated shell (bottom nav) ─────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        // Branch 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Branch 1 — Tickets
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tickets',
              builder: (context, state) => const TicketListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const CreateTicketScreen(),
                ),
              ],
            ),
          ],
        ),

        // Branch 2 — Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Standalone routes (keep accessible from within the app) ─────────────
    GoRoute(
      path: '/announcements',
      builder: (context, state) => const AnnouncementsScreen(),
    ),
  ],
);
