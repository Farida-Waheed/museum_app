import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/settings/accessibility_screen.dart';
import '../screens/exhibits/exhibit_list.dart';
import '../screens/exhibits/exhibit_details.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/quiz/quiz_screen.dart';

class AppRoutes {
  // Route Constants
  static const String home = '/';
  static const String map = '/map';
  static const String exhibits = '/exhibits';
  static const String exhibitDetails = '/exhibit_details';
  static const String chat = '/chat';
  static const String quiz = '/quiz';
  static const String settings = '/settings';

  // Route Generator
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      map: (context) => const MapScreen(),
      exhibits: (context) => const ExhibitListScreen(),
      exhibitDetails: (context) => const ExhibitDetailScreen(),
      chat: (context) => const ChatScreen(),
      quiz: (context) => const QuizScreen(),
      settings: (context) => const AccessibilityScreen(),
    };
  }
}