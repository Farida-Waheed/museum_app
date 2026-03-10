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

    final surface = theme.colorScheme.surface;
    final shadowColor = theme.colorScheme.shadow.withOpacity(0.06);
    final unselected = theme.colorScheme.onSurface.withOpacity(0.4);

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
          route = AppRoutes.liveTour; // Updated to liveTour for better consistency
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
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: handleTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: primary,
            unselectedItemColor: unselected,
            showUnselectedLabels: true,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            elevation: 0,
            backgroundColor: Colors.transparent,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined, size: 22),
                activeIcon: const Icon(Icons.home_rounded, size: 24),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.map_outlined, size: 22),
                activeIcon: const Icon(Icons.map_rounded, size: 24),
                label: l10n.map,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.radio_button_checked_outlined, size: 22),
                activeIcon: const Icon(Icons.radio_button_checked_rounded, size: 24),
                label: l10n.tour,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.confirmation_number_outlined, size: 22),
                activeIcon: const Icon(Icons.confirmation_number_rounded, size: 24),
                label: l10n.tickets,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline, size: 22),
                activeIcon: const Icon(Icons.person_rounded, size: 24),
                label: l10n.profile, // Used profile instead of settings for bottom nav consistency with product rule
              ),
            ],
          ),
        ),
      ),
    );
  }
}
