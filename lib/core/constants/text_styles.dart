import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sizes.dart';
import 'colors.dart';

/// Centralized Typography System for Horus-Bot
///
/// This system uses a language-aware approach:
/// - English: Headings (Cinzel/Playfair), Body/UI (Inter)
/// - Arabic: Headings (Amiri), Body/UI (Noto Sans Arabic)
class AppTextStyles {
  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  // --- LEGACY TYPOGRAPHY (Intro & Onboarding ONLY) ---
  // Preservation of Playfair Display for English as per requirements.

  static TextStyle heroTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 40,
          color: Colors.white,
          height: 1.1,
        ),
      );
    }
    return const TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w300,
      fontSize: 44,
      color: Colors.white,
      letterSpacing: 1.5,
      height: 1.1,
    );
  }

  static TextStyle heroSubtitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: Colors.white70,
          height: 1.5,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: Colors.white70,
        height: 1.5,
      ),
    );
  }

  static TextStyle screenTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          color: Colors.white,
        ),
      );
    }
    return const TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w700,
      fontSize: 26,
      color: Colors.white,
      letterSpacing: 0.5,
    );
  }

  static TextStyle sectionTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
          color: AppColors.primaryGold,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 13,
        color: AppColors.primaryGold,
        letterSpacing: 2.0,
      ),
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 19,
          color: Colors.white,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 19,
        color: Colors.white,
      ),
    );
  }

  static TextStyle statNumber(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.white,
      ),
    );
  }

  static TextStyle body(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.neutralMedium,
          height: 1.4,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: AppColors.neutralMedium,
        height: 1.4,
      ),
    );
  }

  static TextStyle helper(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12.5,
          color: AppColors.helperText,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12.5,
        color: AppColors.helperText,
      ),
    );
  }

  static TextStyle button(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14.5,
          color: AppColors.darkInk,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 14.5,
        color: AppColors.darkInk,
        letterSpacing: 1.0,
      ),
    );
  }

  static TextStyle brandTitle(BuildContext context, {bool isDark = true}) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: isDark ? Colors.white : AppColors.darkInk,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 20,
        letterSpacing: 2.0,
        color: isDark ? Colors.white : AppColors.darkInk,
      ),
    );
  }

  // --- NEW TYPOGRAPHY SYSTEM (Main App) ---

  // 1. DISPLAY STYLES (Cinzel/Playfair for EN, Amiri for AR)

  /// Home Hero: "Explore Egypt With Horus-Bot"
  static TextStyle displayHero(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 40,
          color: Colors.white,
          height: 1.1,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 42,
        color: Colors.white,
        height: 1.05,
        letterSpacing: -0.5,
      ),
    );
  }

  /// Top Screen Titles (Museum Map, Live Tour, Profile, etc.)
  static TextStyle displayScreenTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.white,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Major Section Headings (EXHIBITS, DISCOVER ARTIFACTS, etc.)
  static TextStyle displaySectionTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16,
          color: AppColors.primaryGold,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 13,
        color: AppColors.primaryGold,
        letterSpacing: 2.0,
      ),
    );
  }

  /// Artifact Names (Tutankhamun Mask, Rosetta Stone, etc.)
  static TextStyle displayArtifactTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

  /// Large Titles within cards or sections
  static TextStyle titleLarge(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    );
  }

  /// Medium Titles within cards or list items
  static TextStyle titleMedium(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 19,
          color: Colors.white,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: Colors.white,
      ),
    );
  }

  // 2. BODY & UI STYLES (Inter for EN, Noto Sans Arabic for AR)

  /// Primary body text, descriptions, informational paragraphs
  static TextStyle bodyPrimary(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: AppColors.neutralMedium,
          height: 1.6,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 15,
        color: AppColors.neutralMedium,
        height: 1.5,
      ),
    );
  }

  /// Secondary body text, card subtitles
  static TextStyle bodySecondary(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.white70,
          height: 1.5,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.white70,
        height: 1.4,
      ),
    );
  }

  /// Metadata, small details, timestamps
  static TextStyle metadata(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: AppColors.helperText,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: AppColors.helperText,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Button labels
  static TextStyle buttonLabel(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14.5,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 14.5,
        letterSpacing: 1.0,
      ),
    );
  }

  /// Bottom Navigation labels
  static TextStyle navLabel(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Captions, helper labels, settings rows
  static TextStyle caption(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: AppColors.helperText,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: AppColors.helperText,
      ),
    );
  }
}

class AppPadding {
  static const EdgeInsets page = EdgeInsets.all(AppSizes.md);
  static const EdgeInsets card = EdgeInsets.all(AppSizes.md);
}
