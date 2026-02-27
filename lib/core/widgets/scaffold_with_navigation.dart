import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupulse_ai/core/theme/app_theme.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  const ScaffoldWithNavigation({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavigation'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: AppColors.backgroundNavy,
          indicatorColor: AppColors.primaryBlue.withOpacity(0.2),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (int index) => _onTap(context, index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.primaryBlue),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon:
                  Icon(Icons.chat_bubble, color: AppColors.primaryBlue),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon:
                  Icon(Icons.assignment, color: AppColors.primaryBlue),
              label: 'Grading',
            ),
            NavigationDestination(
              icon: Icon(Icons.memory_outlined),
              selectedIcon: Icon(Icons.memory, color: AppColors.primaryBlue),
              label: 'Memory',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
