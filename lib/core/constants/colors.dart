import 'package:flutter/material.dart';

class AppColors {
  // Global Design System
  static const Color primaryGold = Color(0xFFE6C068);
  static const Color darkInk = Color(0xFF1E1912);
  static const Color warmSurface = Color(0xFFF6F2EA);
  static const Color softSurface = Color(0xFFECE7DD);
  static const Color mutedText = Color(0xFF6B6358);
  static const Color alertRed = Color(0xFFE54848);

  // Legacy/Additional (Keeping some for compatibility if needed, but prioritizing above)
  static const Color darkBackground = Color(0xFF121212);
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
