import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/router.dart';
import '../models/user_preferences.dart'; // Adjust import path as necessary

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
    // Access UserPreferencesModel to check language
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    String getLabel(String key) => isArabic ? (_navLabelsAr[key] ?? key) : key;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            // Assuming AppRoutes.home is the correct main home route
            Navigator.pushNamed(context, AppRoutes.mainHome); 
            break;
          case 1:
            Navigator.pushNamed(context, AppRoutes.map);
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.progress);
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.tickets);
            break;
          case 4:
            Navigator.pushNamed(context, AppRoutes.settings);
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: getLabel("Home"),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.map),
          label: getLabel("Map"),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.timeline),
          label: getLabel("Tour"),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.confirmation_num),
          label: getLabel("Tickets"),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: getLabel("Settings"),
        ),
      ],
    );
  }
}