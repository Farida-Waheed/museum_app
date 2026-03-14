import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryGold,
    secondary: AppColors.darkInk,
    surface: AppColors.softSurface,
    onSurface: AppColors.darkInk,
    error: AppColors.alertRed,
  ),

  scaffoldBackgroundColor: AppColors.warmSurface,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.warmSurface,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.darkInk),
    centerTitle: true,
    titleTextStyle: TextStyle(
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

  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.darkInk,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),
    bodyLarge: TextStyle(fontSize: 14, color: AppColors.darkInk, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.mutedText),
  ),

  dividerTheme: const DividerThemeData(color: Color(0xFFE3E8F2), thickness: 1),
);
