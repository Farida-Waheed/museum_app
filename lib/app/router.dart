import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/settings/accessibility_screen.dart';
import '../screens/exhibits/exhibit_list.dart';
import '../screens/exhibits/exhibit_details.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/tour/tour_progress.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/language/language_screen.dart';
import '../screens/tour/live_tour_screen.dart';
import '../screens/tickets/ticket_screen.dart';
import '../screens/tickets/my_tickets_screen.dart';
import '../screens/tickets/qr_scanner_screen.dart';
import '../screens/ar/ar_screen.dart';
import '../screens/onboarding/onboarding_screen.dart'; 
import '../screens/intro/intro_screen.dart';

class AppRoutes {
  // --- Route Constants ---
  static const String intro = '/';
  static const String mainHome = '/home';
  static const String onboarding = '/onboarding'; // Fixed: Added this back
  static const String map = '/map';
  static const String exhibits = '/exhibits';
  static const String exhibitDetails = '/exhibit_details';
  static const String chat = '/chat';
  static const String quiz = '/quiz';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String progress = '/progress';
  static const String feedback = '/feedback';
  static const String language = '/language';
  static const String liveTour = '/live_tour';
  static const String tickets = '/tickets';
  static const String myTickets = '/my_tickets';
  static const String qrScan = '/qr_scan';
  static const String arView = '/ar_view';

  // --- Route Generator ---
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      intro: (context) => const IntroScreen(),
      mainHome: (context) => const HomeScreen(),
      onboarding: (context) => const OnboardingScreen(), // Fixed: Registered here
      map: (context) => const MapScreen(),
      exhibits: (context) => const ExhibitListScreen(),
      exhibitDetails: (context) => const ExhibitDetailScreen(),
      chat: (context) => const ChatScreen(),
      quiz: (context) => const QuizScreen(),
      settings: (context) => const AccessibilityScreen(),
      search: (context) => const SearchScreen(),
      progress: (context) => const TourProgressScreen(),
      feedback: (context) => const FeedbackScreen(),
      language: (context) => const LanguageScreen(),
      liveTour: (context) => const LiveTourScreen(),
      tickets: (context) => const TicketScreen(),
      myTickets: (context) => const MyTicketsScreen(),
      qrScan: (context) => const QrScannerScreen(),
      arView: (context) => const ArScreen(),
    };
  }
}