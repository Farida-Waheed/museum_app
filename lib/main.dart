import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'models/user_preferences.dart';
import 'models/exhibit_provider.dart';
import 'models/tour_provider.dart';
import 'models/chat_provider.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/notification_permission_service.dart';
import 'core/notifications/notification_trigger_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);

  final initialPrefs = await UserPreferencesModel.getInitialPrefs();

  // Initialize notification services
  final notificationService = NotificationService();
  final notificationTriggerService = NotificationTriggerService();
  final notificationPermissionService = NotificationPermissionService();

  await notificationService.initialize(
    onNotificationTapped: (payload) {
      // Get the navigator key from the app context
      // This will be handled by the NotificationPayloadRouter when context is available
      // For now, we'll defer this to the app's navigation system
    },
  );

  await notificationTriggerService.initialize();
  await notificationPermissionService.initialize();

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
        ChangeNotifierProvider(create: (_) => ExhibitProvider()),
        ChangeNotifierProvider(create: (_) => TourProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MuseumApp(),
    ),
  );
}
