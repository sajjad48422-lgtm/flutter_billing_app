import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF2F2F7);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);

  static const TextTheme textTheme = TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Vazirmatn',
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(fontFamily: 'Vazirmatn'),
    bodySmall: TextStyle(fontFamily: 'Vazirmatn'),
    titleLarge: TextStyle(
      fontFamily: 'Vazirmatn',
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(fontFamily: 'Vazirmatn'),
    titleSmall: TextStyle(fontFamily: 'Vazirmatn'),
    labelLarge: TextStyle(
      fontFamily: 'Vazirmatn',
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(fontFamily: 'Vazirmatn'),
    labelSmall: TextStyle(fontFamily: 'Vazirmatn'),
    headlineLarge: TextStyle(fontFamily: 'Vazirmatn'),
    headlineMedium: TextStyle(
      fontFamily: 'Vazirmatn',
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(fontFamily: 'Vazirmatn'),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Vazirmatn',
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          color: Colors.grey[400],
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}