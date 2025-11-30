import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/router.dart';
import '../models/user_preferences.dart';

// --- ARABIC TRANSLATION MAP ---
const Map<String, String> _navLabelsAr = {
  "Home": "الرئيسية",
  "Map": "الخريطة",
  "Tour": "الجولة",
  "Tickets": "التذاكر",
  "Settings": "الإعدادات",
};

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    // Use app primary color from theme
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color unselected = Colors.grey.shade500;

    String getLabel(String key) => isArabic ? (_navLabelsAr[key] ?? key) : key;

    void handleTap(int index) {
      if (index == currentIndex) return; // already on this tab

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
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
        elevation: 0, // shadow handled by parent container
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: getLabel("Home"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: getLabel("Map"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timeline_outlined),
            activeIcon: const Icon(Icons.timeline),
            label: getLabel("Tour"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.confirmation_num_outlined),
            activeIcon: const Icon(Icons.confirmation_num),
            label: getLabel("Tickets"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: getLabel("Settings"),
          ),
        ],
      ),
    );
  }
}
