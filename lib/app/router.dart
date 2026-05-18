import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/tickets/presentation/ticket_list_screen.dart';
import '../features/tickets/presentation/create_ticket_screen.dart';
import '../features/announcements/presentation/announcements_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/tickets',
      builder: (context, state) => const TicketListScreen(),
    ),
    GoRoute(
      path: '/tickets/create',
      builder: (context, state) => const CreateTicketScreen(),
    ),
    GoRoute(
      path: '/announcements',
      builder: (context, state) => const AnnouncementsScreen(),
    ),
  ],
);