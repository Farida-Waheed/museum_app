import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryGold,
    secondary: AppColors.primaryGold,
    surface: AppColors.darkSurface,
    onSurface: Colors.white,
    error: AppColors.alertRed,
  ),

  scaffoldBackgroundColor: AppColors.darkBackground,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkHeader,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  cardTheme: const CardThemeData(
    color: AppColors.darkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkHeader,
    selectedItemColor: AppColors.primaryGold,
    unselectedItemColor: AppColors.darkMutedText,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.darkMutedText),
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
