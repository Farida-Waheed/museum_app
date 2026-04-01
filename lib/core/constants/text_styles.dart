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
          fontWeight: FontWeight.w600,
          fontSize: 40,
          color: Colors.white,
          height: 1.1,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 44,
        color: Colors.white,
        letterSpacing: 1.2,
        height: 1.1,
      ),
    );
  }

  static TextStyle heroSubtitle(BuildContext context) {
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
        height: 1.5,
      ),
    );
  }

  static TextStyle screenTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 25,
          color: Colors.white,
          height: 1.25,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 25,
        color: Colors.white,
        letterSpacing: 0.5,
        height: 1.25,
      ),
    );
  }

  static TextStyle sectionTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.primaryGold,
          letterSpacing: 0.8,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.primaryGold,
        letterSpacing: 0.8,
      ),
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

  static TextStyle statNumber(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.white,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.white,
      ),
    );
  }

  static TextStyle helper(BuildContext context) {
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

  static TextStyle button(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.darkInk,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppColors.darkInk,
        letterSpacing: 0.3,
      ),
    );
  }

  static TextStyle brandTitle(BuildContext context, {bool isDark = true}) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: isDark ? Colors.white : AppColors.darkInk,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: 0.5,
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
          fontWeight: FontWeight.w700,
          fontSize: 30,
          color: Colors.white,
          height: 1.1,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 30,
        color: Colors.white,
        height: 1.1,
        letterSpacing: -0.5,
      ),
    );
  }

  /// Top Screen Titles (Museum Map, Live Tour, Profile, etc.)
  static TextStyle displayScreenTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
          height: 1.1,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
        height: 1.1,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Major Section Headings (EXHIBITS, DISCOVER ARTIFACTS, etc.)
  static TextStyle displaySectionTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.primaryGold,
          height: 1.1,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.primaryGold,
        height: 1.1,
        letterSpacing: 0.8,
      ),
    );
  }

  /// Artifact Names (Tutankhamun Mask, Rosetta Stone, etc.)
  static TextStyle displayArtifactTitle(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
          height: 1.1,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.white,
        height: 1.1,
      ),
    );
  }

  /// Large Titles within cards or sections
  static TextStyle titleLarge(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
          height: 1.1,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
        height: 1.1,
      ),
    );
  }

  /// Medium Titles within cards or list items
  static TextStyle titleMedium(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.amiri(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
          height: 1.1,
        ),
      );
    }
    return GoogleFonts.cinzel(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.white,
        height: 1.1,
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

  /// Secondary body text, card subtitles
  static TextStyle bodySecondary(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.white70,
          height: 1.4,
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
      ),
    );
  }

  /// Button labels
  static TextStyle buttonLabel(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 0.3,
      ),
    );
  }

  /// Bottom Navigation labels
  static TextStyle navLabel(BuildContext context) {
    if (_isArabic(context)) {
      return GoogleFonts.notoSansArabic(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      );
    }
    return GoogleFonts.inter(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
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
