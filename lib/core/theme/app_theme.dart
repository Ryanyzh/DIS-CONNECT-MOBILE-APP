import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF87EA5C);
  static const Color darkBlack = Color(0xFF0E0F0C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: darkBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: darkBlack,
      elevation: 0,
      centerTitle: false,
    ),
  );
}