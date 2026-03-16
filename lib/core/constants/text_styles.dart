import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sizes.dart';
import 'colors.dart';

/// Centralized Typography System for Horus-Bot
///
/// This system uses a two-font approach:
/// 1. CINZEL: Museum/Editorial Serif for Display and Headings.
/// 2. INTER: Clean UI Sans-Serif for Body, UI, and Information.
///
/// NOTE: The legacy styles using 'Playfair Display' are preserved
/// EXCLUSIVELY for the Intro and Onboarding screens.
class AppTextStyles {
  // --- LEGACY TYPOGRAPHY (Intro & Onboarding ONLY) ---
  // DO NOT USE for main app screens.
  static const String _legacyFont = 'Playfair Display';

  static TextStyle heroTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _legacyFont,
      fontWeight: FontWeight.w300,
      fontSize: 44,
      color: Colors.white,
      letterSpacing: 1.5,
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

  static TextStyle screenTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: _legacyFont,
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
      letterSpacing: 2.0,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 19,
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

  static TextStyle brandTitle(BuildContext context, {bool isDark = true}) {
    return TextStyle(
      fontFamily: _legacyFont,
      fontWeight: FontWeight.w900,
      fontSize: 20,
      letterSpacing: 2.0,
      color: isDark ? Colors.white : AppColors.darkInk,
    );
  }

  // --- NEW TYPOGRAPHY SYSTEM (Main App) ---

  // Arabic Fallback Strategy:
  // We use Playfair Display and generic serif as fallbacks for Cinzel
  // to maintain high-quality rendering for Arabic characters.
  static const List<String> _serifFallback = ['Playfair Display', 'serif'];

  // 1. DISPLAY STYLES (Cinzel)

  /// Home Hero: "Explore Egypt With Horus-Bot"
  static TextStyle displayHero(BuildContext context) => GoogleFonts.cinzel(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 42,
          color: Colors.white,
          height: 1.05,
          letterSpacing: -0.5,
          fontFamilyFallback: _serifFallback,
        ),
      );

  /// Top Screen Titles (Museum Map, Live Tour, Profile, etc.)
  static TextStyle displayScreenTitle(BuildContext context) => GoogleFonts.cinzel(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          color: Colors.white,
          letterSpacing: 0.5,
          fontFamilyFallback: _serifFallback,
        ),
      );

  /// Major Section Headings (EXHIBITS, DISCOVER ARTIFACTS, etc.)
  static TextStyle displaySectionTitle(BuildContext context) => GoogleFonts.cinzel(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
          color: AppColors.primaryGold,
          letterSpacing: 2.0,
          fontFamilyFallback: _serifFallback,
        ),
      );

  /// Large Titles within cards or sections
  static TextStyle titleLarge(BuildContext context) => GoogleFonts.cinzel(
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
          fontFamilyFallback: _serifFallback,
        ),
      );

  /// Medium Titles within cards or list items
  static TextStyle titleMedium(BuildContext context) => GoogleFonts.cinzel(
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: Colors.white,
          fontFamilyFallback: _serifFallback,
        ),
      );

  // 2. BODY & UI STYLES (Inter)

  /// Primary body text, descriptions, informational paragraphs
  static TextStyle bodyPrimary(BuildContext context) => GoogleFonts.inter(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: AppColors.neutralMedium,
          height: 1.5,
          fontFamilyFallback: _serifFallback,
        ),
      );

  /// Secondary body text, card subtitles
  static TextStyle bodySecondary(BuildContext context) => GoogleFonts.inter(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.white70,
          height: 1.4,
          fontFamilyFallback: _serifFallback,
        ),
      );

  /// Metadata, small details, timestamps
  static TextStyle metadata(BuildContext context) => GoogleFonts.inter(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: AppColors.helperText,
          letterSpacing: 0.5,
          fontFamilyFallback: _serifFallback,
        ),
      );

  /// Button labels
  static TextStyle buttonLabel(BuildContext context) => GoogleFonts.inter(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14.5,
          letterSpacing: 1.0,
          fontFamilyFallback: _serifFallback,
        ),
      );

  /// Bottom Navigation labels
  static TextStyle navLabel(BuildContext context) => GoogleFonts.inter(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.5,
          fontFamilyFallback: _serifFallback,
        ),
      );

  /// Captions, helper labels, settings rows
  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: AppColors.helperText,
          fontFamilyFallback: _serifFallback,
        ),
      );
}

class AppPadding {
  static const EdgeInsets page = EdgeInsets.all(AppSizes.md);
  static const EdgeInsets card = EdgeInsets.all(AppSizes.md);
}
