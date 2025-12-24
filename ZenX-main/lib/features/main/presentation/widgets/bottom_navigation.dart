import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';

/// Bottom navigation bar with 3 main tabs (Home, Workout, Profile)
class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(currentLocation),
      onTap: (index) => _onTap(context, index),
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      selectedLabelStyle: const TextStyle(
        fontSize: DesignTokens.labelSmall,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: DesignTokens.labelSmall,
        fontWeight: FontWeight.w400,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: DesignTokens.iconMedium), // 24dp
          activeIcon: Icon(Icons.home, size: DesignTokens.iconMedium),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center_outlined, size: DesignTokens.iconMedium), // 24dp
          activeIcon: Icon(Icons.fitness_center, size: DesignTokens.iconMedium),
          label: 'Workout',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: DesignTokens.iconMedium), // 24dp
          activeIcon: Icon(Icons.person, size: DesignTokens.iconMedium),
          label: 'Profile',
        ),
      ],
    );
  }

  int _getCurrentIndex(String path) {
    // Home tab: /home
    if (path == '/home' || path == '/' || path.isEmpty) return 0;
    
    // Workout tab: /workouts, /exercises, /analytics, /workouts/*
    if (path.startsWith('/workouts') || 
        path.startsWith('/exercises') || 
        path.startsWith('/analytics')) {
      return 1;
    }
    
    // Profile tab: /profile, /settings, etc.
    if (path.startsWith('/profile') || path.startsWith('/settings')) return 2;
    
    return 0; // Default to Home
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/workouts');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}

