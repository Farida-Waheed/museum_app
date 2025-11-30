import 'package:flutter/material.dart';

final ThemeData highContrastTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  scaffoldBackgroundColor: Colors.black,

  colorScheme: const ColorScheme.dark(
    primary: Colors.yellow,
    secondary: Colors.white,
    surface: Colors.black,
    onSurface: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.yellow),
    titleTextStyle: TextStyle(
      color: Colors.yellow,
      fontSize: 24,
      fontWeight: FontWeight.w900,
    ),
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Colors.yellow,
      fontSize: 28,
      fontWeight: FontWeight.w900,
    ),
  ),

  iconTheme: const IconThemeData(
    color: Colors.yellow,
    size: 34,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);
