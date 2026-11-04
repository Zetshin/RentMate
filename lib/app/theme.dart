import 'package:flutter/material.dart';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121214),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF4ADE80),
    onPrimary: Color(0xFF052E16),
    surface: Color(0xFF202024),
    onSurface: Color(0xFFF5F5F4),
    error: Color(0xFFFCA5A5),
  ),
  fontFamilyFallback: const ['Noto Sans Thai', 'Thonburi', 'sans-serif'],
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF202024),
    hintStyle: const TextStyle(color: Color(0xFFB5B5BF)),
    contentPadding: const EdgeInsets.all(16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF66666F)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);
