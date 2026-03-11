import 'package:flutter/material.dart';

class AppColors {
  // Global Design System
  static const Color primaryGold = Color(0xFFE6C068);
  static const Color darkInk = Color(0xFF1E1912);
  static const Color warmSurface = Color(0xFFF7F2E8); // Updated to match Ivory/Sandstone spec
  static const Color softSurface = Color(0xFFECE7DD);
  static const Color mutedText = Color(0xFF6B6358);
  static const Color alertRed = Color(0xFFE54848);

  // Cinematic Dark Palette
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color cinematicCard = Color(0xFF1E1E1E);
  static const Color cinematicSection = Color(0xFF151515);
  static const Color cinematicElevated = Color(0xFF262626);
  static const Color cinematicNav = Color(0xFF141414);

  // Neutrals
  static const Color neutralDark = Color(0xFF333333);
  static const Color neutralMedium = Color(0xFF888888);
  static const Color neutralLight = Color(0xFFC9C9C9);

  // Legacy/Additional (Keeping some for compatibility if needed, but prioritizing above)
  static const Color darkSurface = Color(0xFF1E1912);
  static const Color darkSurfaceSecondary = Color(0xFF2D261E);
  static const Color darkHeader = Color(0xFF1E1912);
  static const Color darkMutedText = Color(0xFF6B6358);
  static const Color darkDivider = Color(0xFF2D261E);

  static const Color primaryText = Color(0xFFF5F1E8);
  static const Color secondaryText = Color(0xD1FFFFFF);
  static const Color helperText = Color(0x94FFFFFF);

  // Mappings for the requested components
  static const Color headerBackground = warmSurface;
  static const Color cardBackground = softSurface;
  static const Color fabBackground = Color(0xFF2A2118);

  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
