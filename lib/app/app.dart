import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_preferences.dart';
import 'theme/light_theme.dart';
import 'theme/high_contrast.dart';
import 'router.dart'; // Import the router we created

class MuseumApp extends StatelessWidget {
  const MuseumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesModel>(
      builder: (context, prefs, child) {
        return MaterialApp(
          title: 'Museum Guide',
          debugShowCheckedModeBanner: false,
          
          // 1. Theme Logic
          theme: prefs.isHighContrast ? highContrastTheme : lightTheme,
          
          // 2. Localization Logic
          locale: Locale(prefs.language),
          
          // 3. Accessibility (Font Scaling)
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
          
          // 4. Navigation Routes
          initialRoute: AppRoutes.home,
          routes: AppRoutes.getRoutes(),
        );
      },
    );
  }
}