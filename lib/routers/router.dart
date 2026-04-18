import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/list_temoin_screen.dart';
import '../notifications_screens/notification_addtemoin_screen.dart';
import '../widgets/global/app_navbar.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path:    '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppNavbar(child: child),
      routes: [
        GoRoute(
          path:    '/list_temoin',
          builder: (_, __) => const ListTemoinScreen(),
        ),
        GoRoute(
          path: '/notification_add_temoin',
          builder: (context, state) {
            final extra   = state.extra as Map<String, dynamic>;
            final success = extra['success'] as bool;
            final message = extra['message'] as String?;
            return NotificationAddTemoinScreen(
              success:      success,
              errorMessage: message,
            );
          },
        ),
      ],
    ),
  ],
);
