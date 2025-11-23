import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/settings/accessibility_screen.dart';
import '../screens/exhibits/exhibit_list.dart';
import '../screens/exhibits/exhibit_details.dart'; // Import details

class AppRoutes {
  static const String home = '/';
  static const String map = '/map';
  static const String exhibits = '/exhibits';
  static const String exhibitDetails = '/exhibit_details'; // New Route
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      map: (context) => const MapScreen(),
      exhibits: (context) => const ExhibitListScreen(),
      exhibitDetails: (context) => const ExhibitDetailScreen(), // Add this line
      settings: (context) => const AccessibilityScreen(),
    };
  }
}