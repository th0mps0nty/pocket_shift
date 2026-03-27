import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../utils/platform_utils.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final useCupertino = isCupertinoPlatform(Theme.of(context).platform);
    final colors = context.ps;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: useCupertino
          ? CupertinoTabBar(
              currentIndex: navigationShell.currentIndex,
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveColor: colors.navBarInactive,
              backgroundColor: colors.navBarSurface,
              onTap: (index) {
                navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.money_dollar_circle), label: 'Today'),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.time), label: 'History'),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
              ],
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.paid_outlined),
                      selectedIcon: Icon(Icons.paid_rounded),
                      label: 'Today',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: 'History',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.tune_outlined),
                      selectedIcon: Icon(Icons.tune),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
