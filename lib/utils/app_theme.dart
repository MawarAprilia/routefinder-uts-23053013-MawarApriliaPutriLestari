import 'package:flutter/material.dart';

class AppTheme {
  static const Color navy = Color(0xFF172554);
  static const Color purple = Color(0xFF6D28D9);
  static const Color background = Color(0xFFF5F7FF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: purple,
      primary: navy,
      secondary: purple,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}