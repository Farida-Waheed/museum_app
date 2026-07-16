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
import 'accessibility/accessibility.dart';
import 'voice/voice.dart';
import 'voice/services/robot_speech_coordinator.dart';
import 'voice/integration/robot_mqtt_speech_link.dart';
import 'services/auth_service.dart';
import 'services/robot_mqtt_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/notification_trigger_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);

  final initialPrefs = await UserPreferencesModel.getInitialPrefs();

  // Resolve the accessibility profile before the first frame so the correct
  // text scale / contrast is applied immediately (no visual flash). The service
  // is offline-first: on first run of this module (no stored profile) we seed
  // from the legacy display preferences, so returning users keep their existing
  // text size and high-contrast choice — nothing is lost. Cloud reconciliation
  // for logged-in users happens reactively once AuthProvider restores a session.
  final accessibilityService = AccessibilityService(
    repository: FirebaseAccessibilityRepository(),
  );
  final legacyAccessibilitySeed = AccessibilityProfile(
    display: DisplaySettings(
      textScale: (initialPrefs['fontScale'] as double?) ?? 1.0,
      highContrast: (initialPrefs['isHighContrast'] as bool?) ?? false,
    ),
  );
  final initialAccessibility = await accessibilityService.loadInitial(
    legacyFallback: legacyAccessibilitySeed,
  );

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
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authService,
            preferences: context.read<UserPreferencesModel>(),
          ),
        ),
        // Accessibility source-of-truth (spec #6). Declared after AuthProvider
        // so it can read the current user; delegates all persistence to
        // AccessibilityService (spec #5 — no widget/controller touches Firebase)
        // and bridges display fields into UserPreferences so the existing
        // MaterialApp theming pipeline keeps working untouched. A proxy provider
        // keeps a single controller instance while depending on both
        // UserPreferences and Auth.
        ChangeNotifierProxyProvider2<UserPreferencesModel, AuthProvider,
            AccessibilityController>(
          create: (context) => AccessibilityController(
            preferences: context.read<UserPreferencesModel>(),
            auth: context.read<AuthProvider>(),
            service: accessibilityService,
            initialProfile: initialAccessibility.profile,
            initialCloudStale: initialAccessibility.cloudFailed,
          ),
          update: (_, __, ___, controller) => controller!,
        ),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => ExhibitProvider()),
        ChangeNotifierProvider(create: (_) => session.AppSessionProvider()),
        ChangeNotifierProvider(create: (_) => TourProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RobotMqttService()),
        // Voice Communication Engine (Phase 3). The whole app speaks and listens
        // ONLY through this controller — no widget touches a TTS/STT plugin. It
        // assembles the production engines behind their abstract interfaces
        // (FlutterTtsEngine / SpeechToTextRecognizer) and binds to the Phase-2
        // AccessibilityController so speech rate, verbosity, and auto-speak track
        // the visitor's profile automatically. A proxy keeps a single controller
        // instance while following the app locale from UserPreferences.
        ChangeNotifierProxyProvider2<AccessibilityController,
            UserPreferencesModel, VoiceController>(
          create: (context) {
            // Robot speech synchronization (Phase 3): observe the physical
            // robot's speaking state from the existing RobotMqttService so the
            // app and robot never talk over each other. Observation-only — no
            // new MQTT traffic, no change to robot navigation. Falls back to
            // silent no-op behavior if the robot never reports a speaking state.
            final coordinator = VoiceCoordinator(
              tts: FlutterTtsEngine(),
              recognizer: SpeechToTextRecognizer(),
              robot: RobotSpeechCoordinator(
                link: RobotMqttSpeechLink(context.read<RobotMqttService>()),
              ),
            );
            final controller = VoiceController(
              service: VoiceService(coordinator: coordinator),
              accessibility: context.read<AccessibilityController>(),
              initialLanguage: context.read<UserPreferencesModel>().language,
            );
            // Auto-voice AI answers: every assistant message added to the chat
            // is routed through the AI voice adapter, so AI responses become
            // speech without the chat UI touching the engine. The engine still
            // decides whether to actually speak (mute / profile / autoSpeak).
            context.read<ChatProvider>().onAssistantMessage =
                (message) => controller.ai.speakAnswer(
                      message.text,
                      language: controller.language,
                    );
            // Bring up the engines and apply the profile-derived config. Fire
            // and forget: initialize() is idempotent and degrades to a silent
            // experience if TTS is unavailable, so it never blocks startup.
            controller.initialize();
            return controller;
          },
          // Follow the app locale so spoken output switches with the UI language.
          update: (_, __, prefs, controller) =>
              controller!..setLanguageCode(prefs.language),
        ),
      ],
      child: const MuseumApp(),
    ),
  );
}
