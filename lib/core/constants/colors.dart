import 'package:flutter/material.dart';

class AppColors {
  // Brand Design System - Cinematic Dark (Requested Palette)
  static const Color primaryGold = Color(0xFFD4AF37); // Gold #D4AF37
  static const Color darkInk = Color(0xFF1E1912);
  static const Color warmSurface = Color(0xFFF6F2EA);
  static const Color softSurface = Color(0xFFECE7DD);
  static const Color mutedText = Color(0xFF6B6358);
  static const Color alertRed = Color(0xFFE54848);

  // Cinematic Dark Theme Hierarchy
  static const Color cinematicBackground = Color(0xFF0F0F0F); // #0F0F0F
  static const Color cinematicSection = Color(0xFF151515);    // #151515
  static const Color cinematicCard = Color(0xFF1E1E1E);       // #1E1E1E
  static const Color cinematicElevated = Color(0xFF262626);   // #262626
  static const Color cinematicNav = Color(0xFF141414);        // #141414

  // Neutral Tones (Refined)
  static const Color neutralLight = Color(0xFFC9C9C9);        // #C9C9C9
  static const Color neutralMedium = Color(0xFFAAAAAA);       // #AAAAAA
  static const Color neutralDark = Color(0xFF888888);         // #888888

  // Dark (Upgraded Palette - Aliases for easier migration)
  static const Color darkBackground = cinematicBackground;
  static const Color darkSurface = cinematicCard;
  static const Color darkSurfaceSecondary = cinematicElevated;
  static const Color darkMutedText = neutralMedium;
  static const Color darkDivider = Color(0xFF2E2E2E);
  static const Color darkHeader = cinematicNav;

  // Premium Helper Text
  static const Color helperText = Color(0x94FFFFFF); // rgba(255,255,255,0.58)

  // Utility colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Legacy/Theme Mappings
  static const Color primary = primaryGold;
  static const Color secondary = darkInk;
  static const Color background = warmSurface;
  static const Color surface = softSurface;
  static const Color error = alertRed;
  static const Color border = Color(0xFFE3E8F2);
}
