import 'package:go_router/go_router.dart';
import 'screens/form_screen.dart';
import 'screens/sync_screen.dart';

final router = GoRouter(
  initialLocation: '/formulaire',
  routes: [
    GoRoute(
      path: '/formulaire',
      builder: (_, __) => const FormScreen(),
    ),
    GoRoute(
      path: '/transfert',
      builder: (_, __) => const SyncScreen(),
    ),
  ],
);
