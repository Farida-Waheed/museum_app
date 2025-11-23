import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_preferences.dart';
import '../screens/home/home_screen.dart';
import 'theme/light_theme.dart';
import 'theme/high_contrast.dart';

class MuseumApp extends StatelessWidget {
  const MuseumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesModel>(
      builder: (context, prefs, child) {
        return MaterialApp(
          title: 'Museum Guide',
          debugShowCheckedModeBanner: false,
          
          // Theme Logic
          theme: prefs.isHighContrast ? highContrastTheme : lightTheme,
          
          // Localization Logic
          locale: Locale(prefs.language),
          
          // Accessibility Logic (Font Scaling)
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(prefs.fontScale),
              ),
              child: Directionality(
                textDirection: prefs.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              ),
            );
          },
          
          home: const HomeScreen(),
        );
      },
    );
  }
}