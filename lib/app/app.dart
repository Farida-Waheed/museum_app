import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

import '../models/user_preferences.dart';
import 'theme/light_theme.dart';
import 'theme/high_contrast.dart';
import 'router.dart';

class MuseumApp extends StatelessWidget {
  const MuseumApp({super.key});

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
        return MaterialApp(
          title: 'Museum Guide',
          debugShowCheckedModeBanner: false,

          // 1. Theme Logic (High Contrast vs Light)
          theme: prefs.isHighContrast ? highContrastTheme : lightTheme,

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
