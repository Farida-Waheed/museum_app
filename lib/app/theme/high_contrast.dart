import 'package:flutter/material.dart';

final ThemeData highContrastTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    primary: Colors.yellow,
    secondary: Colors.white,
    surface: Colors.black, // 'surface' now handles the background color
    onSurface: Colors.white,
    // background: Colors.black, <--- REMOVED THIS LINE
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
    titleLarge: TextStyle(color: Colors.yellow, fontWeight: FontWeight.w900, fontSize: 26),
  ),
  iconTheme: const IconThemeData(color: Colors.yellow, size: 32),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    iconTheme: IconThemeData(color: Colors.yellow),
    titleTextStyle: TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  ),
);