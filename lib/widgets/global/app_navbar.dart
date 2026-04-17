import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_styles.dart';

class AppNavbar extends StatelessWidget {
  final Widget child;
  const AppNavbar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: BottomAppBar(
        color:   AppColors.surface,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _NavItem(
              icon:     Icons.people_outline,
              iconSel:  Icons.people,
              label:    'Témoins',
              selected: location.startsWith('/list_temoin'),
              onTap:    () => context.go('/list_temoin'),
            ),
            // TODO : ajouter d'autres onglets ici
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData  icon;
  final IconData  iconSel;
  final String    label;
  final bool      selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconSel,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? iconSel : icon,
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize:   11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
