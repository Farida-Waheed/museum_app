import 'package:flutter/material.dart';

class AppColors {
  static const Color baseBlack = Color(0xFF050505);
  static const Color warmBlack = Color(0xFF0B0906);
  static const Color panelDark = Color(0xFF1A1814);
  static const Color panelGlassBase = Color(0xFF1E1D1A);
  static const Color backgroundBase = warmBlack;
  static const Color warmTop = Color(0xFF1A1309);
  static const Color deepBlack = Color(0xFF000000);

  static const Color primaryGold = Color(0xFFC9A24A);
  static const Color darkGold = Color(0xFFB88A2E);
  static const Color softGold = primaryGold;
  static const Color mutedGoldBorder = Color(0xFF8C6A2F);
  static const Color bronzeShadow = Color(0xFF7A5925);

  static const Color whiteTitle = Color(0xFFF5F1E8);
  static const Color bodyText = Color(0xFFB8B2A6);
  static const Color mutedText = Color(0xFFB8B2A6);
  static const Color disabledText = Color(0xFF5E5A54);
  static const Color darkInk = Color(0xFF12100C);
  static const Color alertRed = Color(0xFFE54848);

  static const Color warmSurface = Color(0xFFF7F2E8);
  static const Color softSurface = Color(0xFFECE7DD);
  static const Color helperText = mutedText;

  static const Color cardGlassBase = panelGlassBase;
  static const Color secondaryCardBase = Color(0xFF24211C);
  static const Color glassWhite = Color(0x1FFFFFFF);

  static const Color cinematicBackground = backgroundBase;
  static const Color cinematicSection = panelDark;
  static const Color cinematicCard = panelGlassBase;
  static const Color cinematicElevated = Color(0xFF24211C);
  static const Color cinematicNav = Color(0xFF14110D);

  static const Color surfaceBase = cinematicSection;
  static const Color surfaceStandard = cinematicCard;
  static const Color surfaceElevated = cinematicElevated;

  static const Color neutralLight = bodyText;
  static const Color neutralMedium = bodyText;
  static const Color neutralDark = disabledText;

  static const Color darkBackground = cinematicBackground;
  static const Color darkSurface = cinematicCard;
  static const Color darkSurfaceSecondary = cinematicElevated;
  static const Color darkMutedText = mutedText;
  static const Color darkDivider = Color(0xFF312922);
  static const Color darkBorder = Color(0xFF3F3426);
  static const Color goldAccent = primaryGold;
  static const Color goldSubtle = softGold;
  static const Color darkHeader = Color(0xFF16120E);

  static const Color primaryText = whiteTitle;
  static const Color secondaryText = bodyText;
  static const Color headerBackground = warmSurface;
  static const Color cardBackground = softSurface;
  static const Color fabBackground = Color(0xFF2A2118);

  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static Color cardGlass([double opacity = 0.72]) =>
      cardGlassBase.withValues(alpha: opacity);

  static Color secondaryGlass([double opacity = 0.62]) =>
      secondaryCardBase.withValues(alpha: opacity);

  static Color goldBorder([double opacity = 0.22]) =>
      mutedGoldBorder.withValues(alpha: opacity);

  static Color softGlow([double opacity = 0.10]) =>
      primaryGold.withValues(alpha: opacity);

  static Color bronzeGlow([double opacity = 0.08]) =>
      bronzeShadow.withValues(alpha: opacity);
}

class AppSpacing {
  static const double screenHorizontal = 24;
  static const double screenHorizontalCompact = 20;
  static const double cardPadding = 22;
  static const double cardPaddingCompact = 20;
  static const double sectionGap = 32;
  static const double cardGap = 18;
  static const double titleSubtitleGap = 10;
  static const double buttonHeight = 50;
  static const double iconCircle = 52;
}

class AppGradients {
  static const LinearGradient premiumGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGold, AppColors.darkGold],
  );

  static const LinearGradient screenBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.warmTop, AppColors.backgroundBase, AppColors.deepBlack],
  );

  static RadialGradient ambientGlow({
    Alignment center = const Alignment(0, -0.2),
    double opacity = 0.14,
  }) {
    return RadialGradient(
      center: center,
      radius: 0.95,
      colors: [
        AppColors.primaryGold.withValues(alpha: opacity),
        Colors.transparent,
      ],
    );
  }

  static const LinearGradient heroImageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x92000000),
      Color(0x52000000),
      Color(0xDA040404),
      Color(0xFF050505),
    ],
    stops: [0.0, 0.28, 0.76, 1.0],
  );

  static const LinearGradient onboardingOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x8C000000), Color(0x26000000), Color(0xDB000000)],
    stops: [0.0, 0.42, 1.0],
  );
}

class AppDecorations {
  static BoxDecoration cinematicBackground({
    Alignment glowCenter = const Alignment(0, -0.7),
  }) {
    return BoxDecoration(
      gradient: AppGradients.screenBackground,
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryGold.withValues(alpha: 0.04),
          blurRadius: 120,
          spreadRadius: 12,
        ),
      ],
    );
  }

  static BoxDecoration premiumGlassCard({
    double radius = 28,
    bool highlighted = false,
    double opacity = 0.72,
  }) {
    return BoxDecoration(
      color: AppColors.cardGlass(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.goldBorder(highlighted ? 0.22 : 0.18),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.40),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: AppColors.bronzeGlow(highlighted ? 0.10 : 0.08),
          blurRadius: 30,
        ),
        if (highlighted)
          BoxShadow(
            color: AppColors.softGlow(0.12),
            blurRadius: 26,
            spreadRadius: 1,
          ),
      ],
    );
  }

  static BoxDecoration secondaryGlassCard({
    double radius = 24,
    double opacity = 0.62,
  }) {
    return BoxDecoration(
      color: AppColors.secondaryGlass(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.goldBorder(0.14), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
        BoxShadow(color: AppColors.bronzeGlow(0.05), blurRadius: 22),
      ],
    );
  }

  static ButtonStyle primaryButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkGold,
      foregroundColor: AppColors.darkInk,
      elevation: 0,
      minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    );
  }

  static ButtonStyle secondaryButton() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryGold,
      minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
      side: BorderSide(color: AppColors.goldBorder(0.5), width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      backgroundColor: AppColors.cardGlass(0.38),
    );
  }

  static ButtonStyle disabledButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondaryGlass(0.55),
      foregroundColor: AppColors.disabledText,
      elevation: 0,
      minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
