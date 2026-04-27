import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF031635);
  static const primaryContainer = Color(0xFF1a2b4b);
  static const onPrimary = Color(0xFFffffff);

  static const surface = Color(0xFFf8f9fa);
  static const surfaceContainerLowest = Color(0xFFffffff);
  static const surfaceContainerLow = Color(0xFFf3f4f5);
  static const surfaceContainerHigh = Color(0xFFe7e8e9);
  static const surfaceContainerHighest = Color(0xFFe1e3e4);

  static const onSurface = Color(0xFF191c1d);
  static const onSurfaceVariant = Color(0xFF44474e);

  static const error = Color(0xFFba1a1a);
  static const errorContainer = Color(0xFFffdad6);
  static const onErrorContainer = Color(0xFF93000a);

  static const secondaryFixed = Color(0xFF6ffbbe);
  static const onSecondaryFixed = Color(0xFF002113);
  static const secondaryContainer = Color(0xFF6cf8bb);

  static const tertiaryFixed = Color(0xFFffddb8);
  static const onTertiaryFixed = Color(0xFF2a1700);
  static const tertiaryFixedDim = Color(0xFFffb95f);

  static const outlineVariant = Color(0xFFc5c6cf);
  static const outline = Color(0xFF75777f);

  static const onSecondaryContainer = Color(0xFF00714d);
  static const onPrimaryContainer = Color(0xFF8293b8);
  static const onTertiaryFixedVariant = Color(0xFF653e00);
  static const surfaceContainer = Color(0xFFedeeef);
  static const onSecondaryFixedVariant = Color(0xFF005236);
  static const primaryFixed = Color(0xFFd8e2ff);
  static const onPrimaryFixed = Color(0xFF081b3a);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        primaryContainer: AppColors.primaryContainer,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColors.primary),
        displayMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColors.primary),
        titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppColors.primary),
        titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
