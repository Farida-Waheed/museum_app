import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

import '../models/user_preferences.dart';
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';
import 'theme/high_contrast.dart';
import 'router.dart';

class MuseumApp extends StatelessWidget {
  const MuseumApp({super.key});

  // Global navigator key for notification navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesModel>(
      builder: (context, prefs, child) {
        ThemeMode themeMode;
        switch (prefs.themeMode) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;
            break;
          default:
            themeMode = ThemeMode.system;
        }

        // Language-aware theme selection
        final ThemeData activeTheme = prefs.isHighContrast
            ? getHighContrastTheme(prefs.language)
            : getLightTheme(prefs.language);

        final ThemeData activeDarkTheme = prefs.isHighContrast
            ? getHighContrastTheme(prefs.language)
            : getDarkTheme(prefs.language);

        return MaterialApp(
          title: 'Museum Guide',
          debugShowCheckedModeBanner: false,
          navigatorKey: MuseumApp.navigatorKey,

          // 1. Theme Logic
          theme: activeTheme,
          darkTheme: activeDarkTheme,

          // 2. Localization
          locale: Locale(prefs.language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,

          // 3. Accessibility (Font Scaling)
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(prefs.fontScale)),
              child: child!,
            );
          },

          initialRoute: AppRoutes.intro,
          routes: AppRoutes.getRoutes(),
          themeMode: themeMode,
        );
      },
    );
  }
}
