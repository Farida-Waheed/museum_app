import 'package:flutter/material.dart';
import 'sizes.dart';
import 'colors.dart';

class AppTextStyles {
  static const String _fontFamily = 'Playfair Display';

  static TextStyle heroTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w900,
      fontSize: 34, // ~34-36px
      color: Colors.white,
      letterSpacing: 0.5,
    );
  }

  static TextStyle heroSubtitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16, // ~16px
      color: Colors.white70,
      height: 1.4,
    );
  }

  static TextStyle screenTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w900,
      fontSize: 26,
      color: Colors.white,
      letterSpacing: 0.5,
    );
  }

  static TextStyle sectionTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: AppColors.primaryGold,
      letterSpacing: 1.2,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 17,
      color: Colors.white,
    );
  }

  static TextStyle body(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: AppColors.neutralMedium,
      height: 1.4,
    );
  }

  static TextStyle helper(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 12.5,
      color: AppColors.helperText,
    );
  }

  static TextStyle button(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w900,
      fontSize: 14.5,
      color: AppColors.darkInk,
      letterSpacing: 0.5,
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
