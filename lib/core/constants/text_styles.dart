import 'package:flutter/material.dart';
import 'sizes.dart';
import 'colors.dart';

class AppTextStyles {
  static const String _fontFamily = 'Playfair Display';

  static TextStyle heroTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700, // Classic editorial weight
      fontSize: 44,
      color: Colors.white,
      letterSpacing: -1.0,
      height: 1.05,
    );
  }

  static TextStyle heroSubtitle(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: Colors.white70,
      height: 1.5,
    );
  }

  static TextStyle screenTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 26,
      color: Colors.white,
      letterSpacing: 0.5,
    );
  }

  static TextStyle sectionTitle(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 12,
      color: AppColors.primaryGold,
      letterSpacing: 3.5,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
    );
  }

  static TextStyle statNumber(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: Colors.white,
    );
  }

  static TextStyle body(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: AppColors.neutralMedium,
      height: 1.4,
    );
  }

  static TextStyle helper(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: Colors.white.withOpacity(0.5),
      letterSpacing: 0.2,
    );
  }

  static TextStyle button(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 14.5,
      color: AppColors.darkInk,
      letterSpacing: 1.0,
    );
  }

  // Brand specific
  static TextStyle brandTitle(BuildContext context, {bool isDark = true}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 18,
      letterSpacing: 5.0,
      color: isDark ? Colors.white : AppColors.darkInk,
    );
  }

  // Deprecated / Backwards compatibility
  static TextStyle headline(BuildContext context) => screenTitle(context);
  static TextStyle title(BuildContext context) => cardTitle(context);
  static TextStyle caption(BuildContext context) => helper(context);
}

class AppPadding {
  static const EdgeInsets page = EdgeInsets.all(AppSizes.md);
  static const EdgeInsets card = EdgeInsets.all(AppSizes.md);
}
