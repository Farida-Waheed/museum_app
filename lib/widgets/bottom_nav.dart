import 'package:flutter/material.dart';
import '../app/router.dart';
import '../l10n/app_localizations.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    // Theme-safe colors (works for light/dark/high-contrast)
    final surface = theme.colorScheme.surface;
    final shadowColor = theme.colorScheme.shadow.withOpacity(0.10);
    final unselected = theme.colorScheme.onSurface.withOpacity(0.55);

    void handleTap(int index) {
      if (index == currentIndex) return;

      String route;
      switch (index) {
        case 0:
          route = AppRoutes.mainHome;
          break;
        case 1:
          route = AppRoutes.map;
          break;
        case 2:
          route = AppRoutes.progress;
          break;
        case 3:
          route = AppRoutes.tickets;
          break;
        case 4:
        default:
          route = AppRoutes.settings;
          break;
      }

      Navigator.pushReplacementNamed(context, route);
    }

    return Container(
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: handleTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
        unselectedItemColor: unselected,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 0,
        backgroundColor: surface,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: l10n.map,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timeline_outlined),
            activeIcon: const Icon(Icons.timeline),
            label: l10n.tour,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.confirmation_num_outlined),
            activeIcon: const Icon(Icons.confirmation_num),
            label: l10n.tickets,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
