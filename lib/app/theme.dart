import 'package:flutter/material.dart';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121214),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF202024),
    foregroundColor: Color(0xFFF5F5F4),
    surfaceTintColor: Colors.transparent,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF202024),
    surfaceTintColor: Colors.transparent,
    indicatorColor: const Color(0xFF36363D),
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? const Color(0xFFFFFFFF)
            : const Color(0xFFB5B5BF),
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        color: states.contains(WidgetState.selected)
            ? const Color(0xFFFFFFFF)
            : const Color(0xFFB5B5BF),
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w700
            : FontWeight.w400,
      ),
    ),
  ),
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
