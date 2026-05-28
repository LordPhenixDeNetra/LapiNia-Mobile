import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pets_outlined),
            selectedIcon: const Icon(Icons.pets),
            label: l10n.navLapins,
          ),
          NavigationDestination(
            icon: const Icon(Icons.child_friendly_outlined),
            selectedIcon: const Icon(Icons.child_friendly),
            label: l10n.navPortees,
          ),
          NavigationDestination(
            icon: const Icon(Icons.psychology_outlined),
            selectedIcon: const Icon(Icons.psychology),
            label: l10n.navIa,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.navPlus,
          ),
        ],
      ),
    );
  }
}
