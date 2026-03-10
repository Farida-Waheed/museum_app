import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF1E5AA8); // museum blue
  static const Color secondary = Color(0xFF00A6B6); // teal accent
  static const Color highlight = Color(0xFFD4AF37); // gold

  // Neutrals (fallbacks; prefer Theme colors in widgets)
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE3E8F2);

  // Text fallbacks
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  static const Color disabled = Color(0xFFCBD5E1);
}
