import 'package:flutter/material.dart';

class AppColors {
  // Brand Design System - Cinematic Dark
  static const Color primaryGold = Color(0xFFE6C068);
  static const Color darkInk = Color(0xFF1E1912);
  static const Color warmSurface = Color(0xFFF7F2E8);
  static const Color softSurface = Color(0xFFECE7DD);
  static const Color mutedText = Color(0xFF6B6358);
  static const Color alertRed = Color(0xFFE54848);

  // Cinematic Dark Theme Hierarchy
  static const Color cinematicBackground = Color(0xFF0F0F0F);
  static const Color cinematicSection = Color(0xFF151515);
  static const Color cinematicCard = Color(0xFF1E1E1E);
  static const Color cinematicElevated = Color(0xFF262626);
  static const Color cinematicNav = Color(0xFF141414);

  // Neutral Tones
  static const Color neutralLight = Color(0xFFC9C9C9);
  static const Color neutralMedium = Color(0xFFAAAAAA);
  static const Color neutralDark = Color(0xFF333333);

  // Aliases for easier migration
  static const Color darkBackground = cinematicBackground;
  static const Color darkSurface = cinematicCard;
  static const Color darkSurfaceSecondary = cinematicElevated;
  static const Color darkMutedText = neutralMedium;
  static const Color darkDivider = Color(0xFF2E2E2E);
  static const Color darkHeader = cinematicNav;

  static const Color primaryText = Color(0xFFF5F1E8);
  static const Color secondaryText = Color(0xD1FFFFFF);
  static const Color helperText = Color(0x94FFFFFF);

  // Mappings
  static const Color headerBackground = warmSurface;
  static const Color cardBackground = softSurface;
  static const Color fabBackground = Color(0xFF2A2118);

  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
