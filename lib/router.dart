import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/form_screen.dart';
import 'screens/records_screen.dart';
import 'screens/sync_screen.dart';

final router = GoRouter(
  initialLocation: '/formulaire',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _NavShell(child: child),
      routes: [
        GoRoute(
          path: '/formulaire',
          builder: (_, __) => const FormScreen(),
        ),
        GoRoute(
          path: '/enregistrements',
          builder: (_, __) => const RecordsScreen(),
        ),
        GoRoute(
          path: '/transfert',
          builder: (_, __) => const SyncScreen(),
        ),
      ],
    ),
  ],
);

class _NavShell extends StatelessWidget {
  final Widget child;
  const _NavShell({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/enregistrements')) return 1;
    if (location.startsWith('/transfert'))       return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor:  const Color(0xFF1A1D27),
        indicatorColor:   const Color(0xFF3ECF8E).withValues(alpha: 0.15),
        selectedIndex:    _currentIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/formulaire');      break;
            case 1: context.go('/enregistrements'); break;
            case 2: context.go('/transfert');       break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon:           Icon(Icons.edit_note_outlined),
            selectedIcon:   Icon(Icons.edit_note, color: Color(0xFF3ECF8E)),
            label:          'Formulaire',
          ),
          NavigationDestination(
            icon:           Icon(Icons.folder_outlined),
            selectedIcon:   Icon(Icons.folder, color: Color(0xFF3ECF8E)),
            label:          'Enregistrés',
          ),
          NavigationDestination(
            icon:           Icon(Icons.cloud_upload_outlined),
            selectedIcon:   Icon(Icons.cloud_upload, color: Color(0xFF3ECF8E)),
            label:          'Transfert',
          ),
        ],
      ),
    );
  }
}
