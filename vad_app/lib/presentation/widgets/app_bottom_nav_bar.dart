import 'package:flutter/material.dart';

import '../../core/app_color.dart';
import '../../core/app_text_styles.dart';

class AppBottomNavBar extends StatelessWidget {
  /// Índice del tab activo: 0=Inicio, 1=Historial, 2=Perfil
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 17),
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(
          top: BorderSide(color: AppColors.secondarySteel, width: 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Inicio',
            isActive: currentIndex == 0,
            onTap: () => _navegarA(context, 0),
          ),
          _NavItem(
            icon: Icons.build_outlined,
            activeIcon: Icons.build,
            label: 'Historial',
            isActive: currentIndex == 1,
            onTap: () => _navegarA(context, 1),
          ),
          _NavItem(
            icon: Icons.account_circle_outlined,
            activeIcon: Icons.account_circle,
            label: 'Perfil',
            isActive: currentIndex == 2,
            onTap: () => _navegarA(context, 2),
          ),
        ],
      ),
    );
  }

  void _navegarA(BuildContext context, int index) {
    // Si ya estamos en el tab activo, no hacemos nada
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      case 1:
        // Historial requiere un vehículo seleccionado primero
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Primero selecciona un vehículo para ver su historial',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      case 2:
        Navigator.pushNamed(context, '/profile');
    }
  }
}

// Widget para cada item

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryBlue : AppColors.secondarySteel;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? activeIcon : icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.navLabel.copyWith(color: color)),
        ],
      ),
    );
  }
}
