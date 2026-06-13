import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

ThemeData getLightTheme(String languageCode) {
  final bool isArabic = languageCode == 'ar';
  final String? bodyFont = isArabic
      ? 'HorusArabic'
      : GoogleFonts.inter().fontFamily;
  final String? headingFont = isArabic
      ? 'HorusArabic'
      : GoogleFonts.cinzel().fontFamily;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: bodyFont,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGold,
      secondary: AppColors.darkGold,
      surface: AppColors.websiteLightCard,
      onSurface: AppColors.websiteLightForeground,
      error: AppColors.alertRed,
    ),

    scaffoldBackgroundColor: AppColors.websiteLightBackground,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.websiteLightBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.websiteLightForeground),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: headingFont,
        color: AppColors.websiteLightForeground,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    cardTheme: const CardThemeData(
      color: AppColors.websiteLightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: Color(0x1FD4C9BA), width: 1),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.websiteLightBackground,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.websiteLightMutedForeground,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: headingFont,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.websiteLightForeground,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFont,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.websiteLightForeground,
      ),
      titleMedium: TextStyle(
        fontFamily: headingFont,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.websiteLightForeground,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        color: AppColors.websiteLightMutedForeground,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        color: AppColors.websiteLightMutedForeground,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.websiteLightBorder,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.websiteLightCard,
      labelStyle: TextStyle(
        fontFamily: bodyFont,
        color: AppColors.websiteLightMutedForeground,
      ),
      hintStyle: TextStyle(
        fontFamily: bodyFont,
        color: AppColors.websiteLightMutedForeground,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x268C6A2F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.2),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.websiteLightPopover,
      contentTextStyle: TextStyle(color: AppColors.darkInk),
      actionTextColor: AppColors.primaryGold,
    ),
  );
}

final ThemeData lightTheme = getLightTheme('en');
