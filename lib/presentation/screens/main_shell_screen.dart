import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShellScreen extends StatelessWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'Lapins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_friendly_outlined),
            activeIcon: Icon(Icons.child_friendly),
            label: 'Portées',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grass_outlined),
            activeIcon: Icon(Icons.grass),
            label: 'Aliments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'IA',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/lapins')) return 1;
    if (location.startsWith('/portees')) return 2;
    if (location.startsWith('/aliments')) return 3;
    if (location.startsWith('/ia')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/lapins');
        break;
      case 2:
        context.go('/portees');
        break;
      case 3:
        context.go('/aliments');
        break;
      case 4:
        context.go('/ia');
        break;
    }
  }
}
