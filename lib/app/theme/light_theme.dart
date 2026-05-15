import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

ThemeData getLightTheme(String languageCode) {
  final bool isArabic = languageCode == 'ar';
  final String? bodyFont = isArabic
      ? GoogleFonts.notoSansArabic().fontFamily
      : GoogleFonts.inter().fontFamily;
  final String? headingFont = isArabic
      ? GoogleFonts.amiri().fontFamily
      : GoogleFonts.cinzel().fontFamily;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: bodyFont,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGold,
      secondary: AppColors.darkInk,
      surface: AppColors.softSurface,
      onSurface: AppColors.darkInk,
      error: AppColors.alertRed,
    ),

    scaffoldBackgroundColor: AppColors.warmSurface,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.warmSurface,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.darkInk),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: headingFont,
        color: AppColors.darkInk,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    cardTheme: const CardThemeData(
      color: AppColors.softSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.warmSurface,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.mutedText,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: headingFont,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.darkInk,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFont,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.darkInk,
      ),
      titleMedium: TextStyle(
        fontFamily: headingFont,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.darkInk,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        color: AppColors.darkInk,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        color: AppColors.mutedText,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE3E8F2),
      thickness: 1,
    ),
  );
}

final ThemeData lightTheme = getLightTheme('en');
