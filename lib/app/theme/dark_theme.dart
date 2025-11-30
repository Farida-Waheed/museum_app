import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),

  scaffoldBackgroundColor: const Color(0xFF101215),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF181A1F),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  // 👇 FIXED: CardThemeData
  cardTheme: const CardThemeData(
    color: Color(0xFF181A1F),
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF181A1F),
    selectedItemColor: Colors.blueAccent,
    unselectedItemColor: Colors.white70,
    showUnselectedLabels: true,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white, height: 1.45),
    bodyMedium: TextStyle(color: Colors.white70, height: 1.4),
    titleLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
  ),
);
