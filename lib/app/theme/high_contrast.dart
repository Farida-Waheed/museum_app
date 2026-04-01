import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData getHighContrastTheme(String languageCode) {
  final bool isArabic = languageCode == 'ar';
  final String? bodyFont = isArabic ? GoogleFonts.notoSansArabic().fontFamily : GoogleFonts.inter().fontFamily;
  final String? headingFont = isArabic ? GoogleFonts.amiri().fontFamily : 'Playfair Display';

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
    ),

    iconTheme: const IconThemeData(color: Colors.yellow, size: 34),

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
  );
}

final ThemeData highContrastTheme = getHighContrastTheme('en');
