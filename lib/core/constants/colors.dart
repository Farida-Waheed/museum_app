import 'package:flutter/material.dart';

class AppColors {
  // Brand Design System - Cinematic Dark
  static const Color primaryGold = Color(0xFFE6C068);
  static const Color darkInk = Color(0xFF1E1912);
  static const Color warmSurface = Color(0xFFF7F2E8);
  static const Color softSurface = Color(0xFFECE7DD);
  static const Color mutedText = Color(0xFF6B6358);
  static const Color alertRed = Color(0xFFE54848);

  // Cinematic Dark Theme Hierarchy - Refined for better surface separation
  static const Color cinematicBackground = Color(0xFF0F0F0F); // Base background
  static const Color cinematicSection = Color(
    0xFF1A1A1A,
  ); // Primary surface layer
  static const Color cinematicCard = Color(0xFF242424); // Standard card surface
  static const Color cinematicElevated = Color(
    0xFF2E2E2E,
  ); // Elevated cards/modals
  static const Color cinematicNav = Color(0xFF151515); // Navigation bar

  // Surface layer aliases for clarity
  static const Color surfaceBase = cinematicSection; // #1A1A1A
  static const Color surfaceStandard = cinematicCard; // #242424
  static const Color surfaceElevated = cinematicElevated; // #2E2E2E

  // Neutral Tones
  static const Color neutralLight = Color(0xFFC9C9C9);
  static const Color neutralMedium = Color(0xFFAAAAAA);
  static const Color neutralDark = Color(0xFF333333);

  // Aliases for easier migration
  static const Color darkBackground = cinematicBackground;
  static const Color darkSurface = cinematicCard;
  static const Color darkSurfaceSecondary = cinematicElevated;
  static const Color darkMutedText = Color(0xFF909090); // Improved readability
  static const Color darkDivider = Color(0xFF3A3A3A); // Improved visibility
  static const Color darkBorder = Color(0xFF383838); // Surface borders
  static const Color goldAccent = primaryGold; // Gold for CTAs/highlights only
  static const Color goldSubtle = Color(
    0xFF8B7D5F,
  ); // Muted gold for non-interactive use (rare)
  static const Color darkHeader = cinematicNav;

  static const Color primaryText = Color(
    0xFFFDFBF7,
  ); // Near-white for main text
  static const Color secondaryText = Color(
    0xFFB8B8B8,
  ); // Light gray for secondary labels
  static const Color helperText = Color(
    0xFF808080,
  ); // Medium gray for helper text

  // Mappings - Museum Theme
  static const Color headerBackground = warmSurface; // Light theme only
  static const Color cardBackground = softSurface; // Light theme only
  static const Color fabBackground = Color(0xFF2A2118);

  // NOTE: Gold (#E6C068) should ONLY be used for:
  // - Active button states
  // - Key status indicators
  // - Icon highlights (rare)
  // NOT for: body text, subtle borders, background tints

  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
