import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF5A54D4);
  static const Color accentColor = Color(0xFF00C9A7);
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF22223B);
  static const Color userBubble = Color(0xFF6C63FF);
  static const Color aiBubble = Color(0xFF1E2140);
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color dividerColor = Color(0xFF2E2E4A);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF00C9A7);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceDark,
        error: errorColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: textSecondary),
      ),
    );
  }
}
