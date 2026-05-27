import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Vazirmatn',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Vazirmatn'),
        bodyMedium: TextStyle(fontFamily: 'Vazirmatn'),
        bodySmall: TextStyle(fontFamily: 'Vazirmatn'),
        titleLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(fontFamily: 'Vazirmatn'),
        titleSmall: TextStyle(fontFamily: 'Vazirmatn'),
        labelLarge: TextStyle(fontFamily: 'Vazirmatn'),
        labelMedium: TextStyle(fontFamily: 'Vazirmatn'),
        headlineMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        fontFamily: 'Vazirmatn',
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontFamily: 'Vazirmatn'),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(fontFamily: 'Vazirmatn'),
        hintStyle: TextStyle(fontFamily: 'Vazirmatn'),
      ),
      useMaterial3: true,
    );
  }
}
