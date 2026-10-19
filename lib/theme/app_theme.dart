import 'package:flutter/material.dart';

class AppTheme {
  static const lightBackground = Color(0xFFF7F8FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF1E88E5);
  static const lightText = Color(0xFF222A43);
  static const lightSecondary = Color(0xFF64748B);
  static const lightBorder = Color(0xFFE2E8F0);
  static const darkBackground = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
  static const darkPrimary = Color(0xFF6366F1);
  static const darkText = Color(0xFFF9FAFB);
  static const darkSecondary = Color(0xFF9CA3AF);
  static const darkBorder = Color(0xFF374151);

  static ThemeData light() => ThemeData(useMaterial3: true, brightness: Brightness.light, scaffoldBackgroundColor: lightBackground, colorScheme: ColorScheme.fromSeed(seedColor: lightPrimary, brightness: Brightness.light, surface: lightSurface), appBarTheme: const AppBarTheme(backgroundColor: lightBackground, foregroundColor: lightText, elevation: 0), cardTheme: const CardThemeData(color: lightSurface, elevation: 0), dividerColor: lightBorder);
  static ThemeData dark() => ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: darkBackground, colorScheme: ColorScheme.fromSeed(seedColor: darkPrimary, brightness: Brightness.dark, surface: darkSurface), appBarTheme: const AppBarTheme(backgroundColor: darkBackground, foregroundColor: darkText, elevation: 0), cardTheme: const CardThemeData(color: darkSurface, elevation: 0), dividerColor: darkBorder);
}
