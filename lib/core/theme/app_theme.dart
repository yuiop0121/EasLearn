import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color backgroundNavy = Color(0xFF1E293B); // Slate 800
  static const Color cardSurface =
      Color(0xFF1E293B); // Slate 800 with opacity usually

  // Accents
  static const Color primaryBlue = Color(0xFF3B82F6); // Blue 500
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan 500
  static const Color accentPurple = Color(0xFF8B5CF6); // Violet 500

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentCyan,
        surface: AppColors.backgroundNavy,
        background: AppColors.backgroundDark,
        onBackground: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      // cardTheme: CardTheme(
      //   color: AppColors.cardSurface.withOpacity(0.5),
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(24),
      //     side: BorderSide(
      //       color: Colors.white.withOpacity(0.1),
      //       width: 1,
      //     ),
      //   ),
      // ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),
    );
  }
}
