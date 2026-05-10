import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'models/user_preferences.dart';
import 'models/exhibit_provider.dart';
import 'models/tour_provider.dart';
import 'models/chat_provider.dart';
import 'models/app_session_provider.dart' as session;
import 'models/auth_provider.dart';
import 'models/ticket_provider.dart';
import 'services/auth_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/notification_trigger_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);

  final initialPrefs = await UserPreferencesModel.getInitialPrefs();

  // Initialize notification services
  final notificationService = NotificationService();
  final notificationTriggerService = NotificationTriggerService();
  await notificationService.initialize(
    onNotificationTapped: (payload) {
      // Get the navigator key from the app context
      // This will be handled by the NotificationPayloadRouter when context is available
      // For now, we'll defer this to the app's navigation system
    },
  );

  await notificationTriggerService.initialize();

  // Initialize auth service
  final authService = await AuthService.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserPreferencesModel(
            initialLanguage: initialPrefs['language'],
            initialOnboardingCompleted: initialPrefs['hasCompletedOnboarding'],
            initialIsHighContrast: initialPrefs['isHighContrast'],
            initialFontScale: initialPrefs['fontScale'],
            initialThemeMode: initialPrefs['themeMode'],
            initialHasSeenPermissionsPrompt:
                initialPrefs['hasSeenPermissionsPrompt'],
            initialHasSeenLocationPrompt: initialPrefs['hasSeenLocationPrompt'],
            initialHasSeenNotificationPermissionPrompt:
                initialPrefs['hasSeenNotificationPermissionPrompt'],
            initialNotificationsEnabled: initialPrefs['notificationsEnabled'],
            skipLoad: true,
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => ExhibitProvider()),
        ChangeNotifierProvider(create: (_) => session.AppSessionProvider()),
        ChangeNotifierProvider(create: (_) => TourProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MuseumApp(),
    ),
  );
}
