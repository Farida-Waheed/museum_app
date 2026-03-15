import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'models/user_preferences.dart';
import 'models/exhibit_provider.dart';
import 'models/tour_provider.dart';
import 'models/chat_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);

  final initialPrefs = await UserPreferencesModel.getInitialPrefs();

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
