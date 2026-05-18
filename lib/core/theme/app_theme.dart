import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF4361EE);
  static const primaryContainer = Color(0xFF1E284A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFD3E3FD);
  static const primaryFixed = Color(0xFF4361EE);
  static const onPrimaryFixed = Color(0xFFFFFFFF);

  static const background = Color(0xFF0A0C10);
  static const surface = Color(0xFF13161C);
  static const surfaceHighlight = Color(0xFF1C2028);
  static const surfaceContainer = Color(0xFF1C2028);
  static const surfaceContainerHigh = Color(0xFF282D38);
  static const surfaceContainerLow = Color(0xFF181C23);

  static const onBackground = Color(0xFFF1F3F5);
  static const onSurface = Color(0xFFD4D8E0);
  static const onSurfaceVariant = Color(0xFF8B93A4);

  static const error = Color(0xFFE63946);
  static const errorContainer = Color(0xFF410E0B);
  static const onErrorContainer = Color(0xFFF9DEDC);
  static const success = Color(0xFF2DC653);
  static const warning = Color(0xFFF4A261);

  static const accent1 = Color(0xFF7209B7);
  static const accent2 = Color(0xFF4CC9F0);

  static const secondaryContainer = Color(0xFF1A3B5C);
  static const onSecondaryContainer = Color(0xFFCBE6FF);
  static const secondaryFixed = Color(0xFF4CC9F0);
  static const onSecondaryFixed = Color(0xFF001F2A);
  static const onSecondaryFixedVariant = Color(0xFF004D68);

  static const tertiaryFixed = Color(0xFF7209B7);
  static const tertiaryFixedDim = Color(0xFF5A0794);
  static const onTertiaryFixed = Color(0xFFF2E7FE);
  static const onTertiaryFixedVariant = Color(0xFFD4B3FF);

  static const outline = Color(0xFF2C3240);
  static const outlineVariant = Color(0xFF1F232C);
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color background;
  final Color surface;
  final Color surfaceHighlight;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerLow;
  final Color onBackground;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color error;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color success;
  final Color warning;
  final Color accent1;
  final Color accent2;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;
  final Color outline;
  final Color outlineVariant;

  const AppColorsExtension({
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.background,
    required this.surface,
    required this.surfaceHighlight,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerLow,
    required this.onBackground,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.error,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.success,
    required this.warning,
    required this.accent1,
    required this.accent2,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.outline,
    required this.outlineVariant,
  });

  @override
  AppColorsExtension copyWith() => this;

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHighlight: Color.lerp(surfaceHighlight, other.surfaceHighlight, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      accent1: Color.lerp(accent1, other.accent1, t)!,
      accent2: Color.lerp(accent2, other.accent2, t)!,
      secondaryContainer: Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      onSecondaryContainer: Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t)!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      onSecondaryFixed: Color.lerp(onSecondaryFixed, other.onSecondaryFixed, t)!,
      onSecondaryFixedVariant: Color.lerp(onSecondaryFixedVariant, other.onSecondaryFixedVariant, t)!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
      tertiaryFixedDim: Color.lerp(tertiaryFixedDim, other.tertiaryFixedDim, t)!,
      onTertiaryFixed: Color.lerp(onTertiaryFixed, other.onTertiaryFixed, t)!,
      onTertiaryFixedVariant: Color.lerp(onTertiaryFixedVariant, other.onTertiaryFixedVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}

class AppTheme {
  static const darkColors = AppColorsExtension(
    primary: Color(0xFF4361EE),
    primaryContainer: Color(0xFF1E284A),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryContainer: Color(0xFFD3E3FD),
    primaryFixed: Color(0xFF4361EE),
    onPrimaryFixed: Color(0xFFFFFFFF),
    background: Color(0xFF0A0C10),
    surface: Color(0xFF13161C),
    surfaceHighlight: Color(0xFF1C2028),
    surfaceContainer: Color(0xFF1C2028),
    surfaceContainerHigh: Color(0xFF282D38),
    surfaceContainerLow: Color(0xFF181C23),
    onBackground: Color(0xFFF1F3F5),
    onSurface: Color(0xFFD4D8E0),
    onSurfaceVariant: Color(0xFF8B93A4),
    error: Color(0xFFE63946),
    errorContainer: Color(0xFF410E0B),
    onErrorContainer: Color(0xFFF9DEDC),
    success: Color(0xFF2DC653),
    warning: Color(0xFFF4A261),
    accent1: Color(0xFF7209B7),
    accent2: Color(0xFF4CC9F0),
    secondaryContainer: Color(0xFF1A3B5C),
    onSecondaryContainer: Color(0xFFCBE6FF),
    secondaryFixed: Color(0xFF4CC9F0),
    onSecondaryFixed: Color(0xFF001F2A),
    onSecondaryFixedVariant: Color(0xFF004D68),
    tertiaryFixed: Color(0xFF7209B7),
    tertiaryFixedDim: Color(0xFF5A0794),
    onTertiaryFixed: Color(0xFFF2E7FE),
    onTertiaryFixedVariant: Color(0xFFD4B3FF),
    outline: Color(0xFF2C3240),
    outlineVariant: Color(0xFF1F232C),
  );

  static const lightColors = AppColorsExtension(
    primary: Color(0xFF4361EE),
    primaryContainer: Color(0xFFE0E7FF),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryContainer: Color(0xFF0F172A),
    primaryFixed: Color(0xFF4361EE),
    onPrimaryFixed: Color(0xFFFFFFFF),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceHighlight: Color(0xFFF1F5F9),
    surfaceContainer: Color(0xFFF1F5F9),
    surfaceContainerHigh: Color(0xFFE2E8F0),
    surfaceContainerLow: Color(0xFFF8FAFC),
    onBackground: Color(0xFF0F172A),
    onSurface: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF64748B),
    error: Color(0xFFE63946),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410E0B),
    success: Color(0xFF2DC653),
    warning: Color(0xFFF4A261),
    accent1: Color(0xFF7209B7),
    accent2: Color(0xFF4CC9F0),
    secondaryContainer: Color(0xFFCBE6FF),
    onSecondaryContainer: Color(0xFF001F2A),
    secondaryFixed: Color(0xFF4CC9F0),
    onSecondaryFixed: Color(0xFF001F2A),
    onSecondaryFixedVariant: Color(0xFF004D68),
    tertiaryFixed: Color(0xFF7209B7),
    tertiaryFixedDim: Color(0xFF5A0794),
    onTertiaryFixed: Color(0xFFFFFFFF),
    onTertiaryFixedVariant: Color(0xFF3B0066),
    outline: Color(0xFFCBD5E1),
    outlineVariant: Color(0xFFE2E8F0),
  );

  static ThemeData get darkTheme {
    return _buildTheme(darkColors, Brightness.dark);
  }

  static ThemeData get lightTheme {
    return _buildTheme(lightColors, Brightness.light);
  }

  static ThemeData _buildTheme(AppColorsExtension colors, Brightness brightness) {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onBackground,
    );

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primaryContainer,
        secondary: colors.accent2,
        onSecondary: colors.onSurface,
        surface: colors.surface,
        onSurface: colors.onSurface,
        surfaceContainerHigh: colors.surfaceContainerHigh,
        error: colors.error,
        onError: colors.onPrimary,
      ),
      extensions: [colors],
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: colors.onBackground),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: colors.onBackground),
        headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: colors.onBackground),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: colors.onBackground),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: colors.onBackground),
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onBackground,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outlineVariant, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 8,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceHighlight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
      ),
    );
  }
}
