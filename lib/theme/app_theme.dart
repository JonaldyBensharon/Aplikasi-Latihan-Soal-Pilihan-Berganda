import 'package:flutter/material.dart';

class AppTheme {
  static const lightBackground = Color(0xFFF7F8FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF1E88E5);
  static const lightText = Color(0xFF222A43);
  static const lightSecondary = Color(0xFF64748B);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightCorrect = Color(0xFF15803D);
  static const lightWrong = Color(0xFFB91C1C);

  static const darkBackground = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
  static const darkPrimary = Color(0xFF6366F1);
  static const darkText = Color(0xFFF9FAFB);
  static const darkSecondary = Color(0xFF9CA3AF);
  static const darkBorder = Color(0xFF374151);
  static const darkCorrect = Color(0xFF4ADE80);
  static const darkWrong = Color(0xFFFF0000);


  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: lightPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary: lightPrimary,
      onPrimary: Colors.white,
      surface: lightSurface,
      onSurface: lightText,
      onSurfaceVariant: lightSecondary,
      outline: lightBorder,
      error: lightWrong,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: lightSurface, elevation: 0),
      dividerColor: lightBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        labelStyle: const TextStyle(color: lightSecondary),
        hintStyle: const TextStyle(color: lightSecondary),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: darkPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: darkPrimary,
      onPrimary: Colors.white,
      surface: darkSurface,
      onSurface: darkText,
      onSurfaceVariant: darkSecondary,
      outline: darkBorder,
      error: darkWrong,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: darkSurface, elevation: 0),
      dividerColor: darkBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        labelStyle: const TextStyle(color: darkSecondary),
        hintStyle: const TextStyle(color: darkSecondary),
      ),
    );
  }

  static Color correctColor(Brightness b) => b == Brightness.dark ? darkCorrect : lightCorrect;
  static Color wrongColor(Brightness b) => b == Brightness.dark ? darkWrong : lightWrong;

  // Penanda soal "sudah dijawab" memakai warna yang sama dengan "benar".
  static Color answeredColor(Brightness b) => correctColor(b);
}
