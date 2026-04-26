import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

ThemeData getDarkTheme(String languageCode) {
  final bool isArabic = languageCode == 'ar';
  final String? bodyFont = isArabic
      ? GoogleFonts.notoSansArabic().fontFamily
      : GoogleFonts.inter().fontFamily;
  final String? headingFont = isArabic
      ? GoogleFonts.amiri().fontFamily
      : 'Playfair Display';

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: bodyFont,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryGold,
      secondary: AppColors.primaryGold,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
      error: AppColors.alertRed,
    ),

    scaffoldBackgroundColor: AppColors.darkBackground,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkHeader,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: headingFont,
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    cardTheme: const CardThemeData(
      color: AppColors.cinematicCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cinematicNav,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.darkMutedText,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: headingFont,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFont,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: headingFont,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        color: Colors.white,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        color: AppColors.darkMutedText,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2A2118),
      foregroundColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.primaryGold, width: 1),
      ),
    ),
  );
}

// Keep legacy for backward compatibility if needed, but prefer getDarkTheme
final ThemeData darkTheme = getDarkTheme('en');
