import 'package:flutter/material.dart';
import 'sizes.dart';
import 'colors.dart';

class AppTextStyles {
  static const String _fontFamily = 'Playfair Display';

  static TextStyle heroTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w300, // Light for editorial look
      fontSize: 44,
      color: Colors.white,
      letterSpacing: 1.5,
      height: 1.1,
    );
  }

  /// Specialized for Home Screen to have a bolder, more editorial feel
  /// without affecting the Intro screen.
  static TextStyle homeHeroTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700, // Bolder for high-end editorial feel
      fontSize: 42,
      color: Colors.white,
      letterSpacing: -0.5, // Tighter for premium look
      height: 1.1,
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

  static TextStyle homeHeroSubtitle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.white.withOpacity(0.85),
      height: 1.6,
      letterSpacing: 0.2,
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
      fontSize: 13,
      color: AppColors.primaryGold,
      letterSpacing: 1.8,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 19,
      color: Colors.white,
      letterSpacing: 0.2,
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
    return const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12.5,
      color: AppColors.helperText,
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
      fontWeight: FontWeight.w800,
      fontSize: 18,
      letterSpacing: 4.0, // More spaced for premium branding
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
