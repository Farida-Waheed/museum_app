import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0F172A),
    primary: const Color(0xFF0F172A),
    secondary: const Color(0xFFD4AF37),
    surface: Colors.white,
    background: const Color(0xFFF8FAFC),
    brightness: Brightness.light,
  ),

  scaffoldBackgroundColor: const Color(0xFFF8FAFC),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black87),
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  // 👇 FIXED: use CardThemeData instead of CardTheme
  cardTheme: const CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87, height: 1.4),
    bodyMedium: TextStyle(color: Colors.black87, height: 1.35),
    titleLarge: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
  ),
);
