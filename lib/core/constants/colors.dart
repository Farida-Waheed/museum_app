import 'package:flutter/material.dart';

class AppColors {
  // Brand Design System - Light
  static const Color primaryGold = Color(0xFFE6C068);
  static const Color darkInk = Color(0xFF1E1912);
  static const Color warmSurface = Color(0xFFF6F2EA);
  static const Color softSurface = Color(0xFFECE7DD);
  static const Color mutedText = Color(0xFF6B6358);
  static const Color alertRed = Color(0xFFE54848);

  // Brand Design System - Dark
  static const Color darkBackground = Color(0xFF12110F);
  static const Color darkSurface = Color(0xFF1E1912);
  static const Color darkSurfaceSecondary = Color(0xFF2A251D);
  static const Color darkMutedText = Color(0xFFB9B2A6);
  static const Color darkDivider = Color(0xFF2A251D);
  static const Color darkHeader = Color(0xFF1A1712);

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
