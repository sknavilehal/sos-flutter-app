import 'package:flutter/material.dart';

/// App theme configuration
class AppTheme {
  // Design Token Colors
  static const Color primaryBlack = Color(0xFF000000); // Primary headings, buttons
  static const Color neutralGrey = Color(0xFF9CA3AF); // Secondary text, microcopy
  static const Color pureWhite = Color(0xFFFFFFFF); // Background, button text
  static const Color accentRed = Color(0xFFEF4444); // SOS button, active status
  
  // Status Colors
  static const Color errorColor = Color(0xFFEF4444); // Error states
  static const Color successColor = Color(0xFF10B981); // Success states
  
  // Legacy color mappings for compatibility
  static const Color primaryColor = accentRed;
  static const Color backgroundColor = pureWhite;
  static const Color surfaceColor = pureWhite;
  static const Color textPrimary = primaryBlack;
  static const Color textSecondary = neutralGrey;
  static const Color textLight = pureWhite;

  /// Light theme configuration
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textLight,
      elevation: 2,
      centerTitle: true,
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: backgroundColor,
    ),
    
    // Card Theme
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );

  /// Dark theme configuration (for future use)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
  );
}