import 'package:flutter/material.dart';

import '../screens/intro/intro_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';

import '../screens/map/map_screen.dart';
import '../screens/exhibits/exhibit_list.dart';
import '../screens/exhibits/exhibit_details.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/search/search_screen.dart';

import '../screens/tour/tour_progress.dart';
import '../screens/tour/live_tour_screen.dart';

import '../screens/tickets/ticket_screen.dart';
import '../screens/tickets/my_tickets_screen.dart';
import '../screens/tickets/qr_scanner_screen.dart';

import '../screens/feedback/feedback_screen.dart';
import '../screens/language/language_screen.dart';
import '../screens/settings/accessibility_screen.dart';
import '../screens/ar/ar_screen.dart';

import '../screens/profile/profile_screen.dart';
// import '../screens/planner/tour_planner_screen.dart';
// import '../screens/events/events_screen.dart';
// import '../screens/achievements/achievements_screen.dart';

class AppRoutes {
  static const String intro = '/';
  static const String mainHome = '/home';
  static const String onboarding = '/onboarding';

  static const String map = '/map';
  static const String exhibits = '/exhibits';
  static const String exhibitDetails = '/exhibit_details';
  static const String chat = '/chat';
  static const String quiz = '/quiz';
  static const String search = '/search';

  static const String progress = '/progress';
  static const String liveTour = '/live_tour';

  static const String tickets = '/tickets';
  static const String myTickets = '/my_tickets';
  static const String qrScan = '/qr_scan';

  static const String settings = '/settings';
  static const String accessibility = '/accessibility';
  static const String feedback = '/feedback';
  static const String language = '/language';
  static const String arView = '/ar_view';

  static const String profile = '/profile';
  static const String tourPlanner = '/tour-planner';
  static const String events = '/events';
  static const String achievements = '/achievements';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      intro: (context) => const IntroScreen(),
      onboarding: (context) => const OnboardingScreen(),
      mainHome: (context) => const HomeScreen(),

      map: (context) => const MapScreen(),
      exhibits: (context) => const ExhibitListScreen(),
      exhibitDetails: (context) => const ExhibitDetailScreen(),
      chat: (context) => const ChatScreen(),
      quiz: (context) => const QuizScreen(),
      search: (context) => const SearchScreen(),

      progress: (context) => const TourProgressScreen(),
      liveTour: (context) => const LiveTourScreen(),

      tickets: (context) => const TicketScreen(),
      myTickets: (context) => const MyTicketsScreen(),
      qrScan: (context) => const QrScannerScreen(),

      settings: (context) => const AccessibilityScreen(),
      accessibility: (context) => const AccessibilityScreen(),
      feedback: (context) => const FeedbackScreen(),
      language: (context) => const LanguageScreen(),
      arView: (context) => const ArScreen(),

      // IMPORTANT: no const here (avoids constructor mismatch forever)
      profile: (context) => const ProfileScreen(),
      // tourPlanner: (context) => TourPlannerScreen(),
      // events: (context) => EventsScreen(),
      // achievements: (context) => AchievementsScreen(),
    };
  }
}
