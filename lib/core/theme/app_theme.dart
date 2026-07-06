import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBrand = Color(0xFF4C39F2);
  static const Color primaryDark  = Color(0xFF6A2FF3);
  static const Color primaryBg    = Color(0xFFF0ECFF);
  static const Color darkBlack    = Color(0xFF0E0F0C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBrand,
      primary: primaryBrand,
      secondary: darkBlack,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: darkBlack,
      elevation: 0,
      centerTitle: false,
    ),
    // Cursor and text selection use the brand purple
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primaryDark,
      selectionColor: Color(0xFFD6CCFF),
      selectionHandleColor: primaryDark,
    ),
    // All CircularProgressIndicators default to brand indigo
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryBrand,
    ),
  );
}