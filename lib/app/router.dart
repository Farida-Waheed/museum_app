import 'package:flutter/material.dart';

import '../screens/intro/intro_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/entry/entry_mode_screen.dart';

import '../screens/map/map_screen.dart';
import '../screens/exhibits/exhibit_list.dart';
import '../screens/exhibits/exhibit_details.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/search/search_screen.dart';

import '../screens/tour/tour_progress.dart';
import '../screens/tour/live_tour_screen.dart';
import '../screens/tour/visit_summary_screen.dart';
import '../screens/tour/tour_customization_screen.dart';
import '../screens/support/support_conversation_screen.dart';
import '../screens/support/support_inbox_screen.dart';

import '../screens/tickets/ticket_screen.dart';
import '../screens/tickets/my_tickets_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/tickets/qr_scanner_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

import '../screens/feedback/feedback_screen.dart';
import '../screens/settings/accessibility_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/project_info_screen.dart';
import '../screens/profile/memories_screen.dart';
import '../screens/planner/tour_planner_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/achievements/achievements_screen.dart';

class AppRoutes {
  static const String intro = '/';
  static const String mainHome = '/home';
  static const String onboarding = '/onboarding';
  static const String entryMode = '/entryMode';
  static const String login = '/login';
  static const String register = '/register';

  static const String map = '/map';
  static const String exhibits = '/exhibits'; // Added for consistency
  static const String exhibitDetails = '/exhibit_details';
  static const String chat = '/chat';
  static const String quiz = '/quiz';
  static const String search = '/search';
  static const String supportInbox = '/support_inbox';
  static const String supportConversation = '/support_conversation';

  static const String progress = '/progress';
  static const String liveTour = '/live_tour';
  static const String summary = '/summary';
  static const String tourCustomization = '/tour_customization';

  static const String tickets = '/tickets';
  static const String myTickets = '/my_tickets';
  static const String qrScan = '/qr_scan';

  static const String settings = '/settings';
  static const String accessibility = '/accessibility';
  static const String notificationSettings = '/notification_settings';
  static const String projectInfo = '/project_info';
  static const String feedback = '/feedback';

  static const String profile = '/profile';
  static const String memories = '/memories';
  static const String tourPlanner = '/tour-planner';
  static const String events = '/events';
  static const String achievements = '/achievements';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      intro: (context) => const IntroScreen(),
      onboarding: (context) => const OnboardingScreen(),
      entryMode: (context) => const EntryModeScreen(),
      mainHome: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),

      map: (context) => const MapScreen(),
      exhibits: (context) => const ExhibitListScreen(),
      exhibitDetails: (context) => const ExhibitDetailScreen(),
      chat: (context) => const ChatScreen(),
      quiz: (context) => const QuizScreen(),
      search: (context) => const SearchScreen(),
      supportInbox: (context) => const SupportInboxScreen(),
      supportConversation: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String? requestId;
        if (args is String) {
          requestId = args;
        } else if (args is Map<String, dynamic>) {
          requestId = args['requestId'] as String?;
        }
        return SupportConversationScreen(requestId: requestId);
      },

      progress: (context) => const TourProgressScreen(),
      liveTour: (context) => const LiveTourScreen(),
      summary: (context) => const VisitSummaryScreen(),
      tourCustomization: (context) => const TourCustomizationScreen(),

      tickets: (context) => const TicketScreen(),
      myTickets: (context) => const MyTicketsScreen(),
      qrScan: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final mode = args is QRScanMode ? args : QRScanMode.museumTicket;
        return QrScannerScreen(mode: mode);
      },

      settings: (context) => const AccessibilityScreen(),
      accessibility: (context) => const AccessibilityScreen(),
      notificationSettings: (context) => const NotificationSettingsScreen(),
      projectInfo: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final targetSection = args is String ? args : null;
        return ProjectInfoScreen(targetSection: targetSection);
      },
      feedback: (context) => const FeedbackScreen(),

      profile: (context) => const ProfileScreen(),
      memories: (context) => const MemoriesScreen(),
      tourPlanner: (context) => const TourPlannerScreen(),
      events: (context) => const EventsScreen(),
      achievements: (context) => const AchievementsScreen(),
    };
  }
}
