import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

ThemeData getHighContrastTheme(String languageCode) {
  final bool isArabic = languageCode == 'ar';
  final String? bodyFont = isArabic
      ? GoogleFonts.notoSansArabic().fontFamily
      : GoogleFonts.inter().fontFamily;
  final String? headingFont = isArabic
      ? GoogleFonts.amiri().fontFamily
      : GoogleFonts.cinzel().fontFamily;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: bodyFont,

    scaffoldBackgroundColor: Colors.black,

    colorScheme: const ColorScheme.dark(
      primary: Colors.yellow,
      secondary: Colors.white,
      surface: Colors.black,
      onSurface: Colors.white,
      error: AppColors.alertRed,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.yellow),
      titleTextStyle: TextStyle(
        fontFamily: headingFont,
        color: Colors.yellow,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: headingFont,
        color: Colors.yellow,
        fontSize: 32,
        fontWeight: FontWeight.w900,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFont,
        color: Colors.yellow,
        fontSize: 26,
        fontWeight: FontWeight.w900,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFont,
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontFamily: headingFont,
        color: Colors.yellow,
        fontSize: 28,
        fontWeight: FontWeight.w900,
      ),
      titleMedium: TextStyle(
        fontFamily: headingFont,
        color: Colors.yellow,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.yellow, size: 34),
    cardTheme: CardThemeData(
      color: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.yellow, width: 1.4),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Colors.yellow, thickness: 1.2),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.yellow,
      unselectedItemColor: Colors.white,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        textStyle: TextStyle(
          fontFamily: bodyFont,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.yellow,
        side: const BorderSide(color: Colors.yellow, width: 1.4),
        textStyle: TextStyle(
          fontFamily: bodyFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.yellow,
        textStyle: TextStyle(
          fontFamily: bodyFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? Colors.black : Colors.white,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.yellow
            : Colors.white24,
      ),
    ),
  );
}

final ThemeData highContrastTheme = getHighContrastTheme('en');
