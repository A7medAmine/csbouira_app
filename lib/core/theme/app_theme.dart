import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

TextTheme _buildTextTheme(Locale locale) {
  final isArabic = locale.languageCode == 'ar';
  final bodyF = isArabic ? 'Cairo' : 'Inter';
  final displayF = isArabic ? 'Cairo' : 'Manrope';
  final monoF = isArabic ? 'Cairo' : 'JetBrainsMono';

  return TextTheme(
    displayLarge: TextStyle(
      fontFamily: displayF,
      fontSize: 48,
      fontWeight: FontWeight.w800,
      height: 56 / 48,
      letterSpacing: -0.02,
      fontVariations: const [FontVariation('wght', 800)],
    ),
    headlineLarge: TextStyle(
      fontFamily: displayF,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 36 / 28,
      letterSpacing: -0.01,
      fontVariations: const [FontVariation('wght', 700)],
    ),
    headlineMedium: TextStyle(
      fontFamily: displayF,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 28 / 20,
      fontVariations: const [FontVariation('wght', 600)],
    ),
    headlineSmall: TextStyle(
      fontFamily: displayF,
      fontVariations: const [FontVariation('wght', 500)],
    ),
    titleLarge: TextStyle(
      fontFamily: bodyF,
      fontVariations: const [FontVariation('wght', 400)],
    ),
    titleMedium: TextStyle(
      fontFamily: bodyF,
      fontVariations: const [FontVariation('wght', 500)],
    ),
    titleSmall: TextStyle(
      fontFamily: bodyF,
      fontVariations: const [FontVariation('wght', 500)],
    ),
    bodyLarge: TextStyle(
      fontFamily: bodyF,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      fontVariations: const [FontVariation('wght', 400)],
    ),
    bodyMedium: TextStyle(
      fontFamily: bodyF,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      fontVariations: const [FontVariation('wght', 400)],
    ),
    bodySmall: TextStyle(
      fontFamily: bodyF,
      fontVariations: const [FontVariation('wght', 400)],
    ),
    labelLarge: TextStyle(
      fontFamily: bodyF,
      fontVariations: const [FontVariation('wght', 500)],
    ),
    labelMedium: TextStyle(
      fontFamily: bodyF,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
      letterSpacing: 0.05,
      fontVariations: const [FontVariation('wght', 600)],
    ),
    labelSmall: TextStyle(
      fontFamily: monoF,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 18 / 13,
      fontVariations: const [FontVariation('wght', 400)],
    ),
  );
}

ThemeData _buildDarkTheme(Locale locale) {
  final colorScheme = ColorScheme.dark(
    surface: AppColorsDark.background,
    onSurface: AppColorsDark.onBackground,
    surfaceContainerHighest: AppColorsDark.surfaceVariant,
    onSurfaceVariant: AppColorsDark.onSurfaceVariant,
    surfaceTint: AppColorsDark.surfaceTint,
    primary: AppColorsDark.primary,
    onPrimary: AppColorsDark.onPrimary,
    primaryContainer: AppColorsDark.primaryContainer,
    onPrimaryContainer: AppColorsDark.onPrimaryContainer,
    inversePrimary: AppColorsDark.inversePrimary,
    secondary: AppColorsDark.secondary,
    onSecondary: AppColorsDark.onSecondary,
    secondaryContainer: AppColorsDark.secondaryContainer,
    onSecondaryContainer: AppColorsDark.onSecondaryContainer,
    tertiary: AppColorsDark.tertiary,
    onTertiary: AppColorsDark.onTertiary,
    tertiaryContainer: AppColorsDark.tertiaryContainer,
    onTertiaryContainer: AppColorsDark.onTertiaryContainer,
    error: AppColorsDark.error,
    onError: AppColorsDark.onError,
    errorContainer: AppColorsDark.errorContainer,
    onErrorContainer: AppColorsDark.onErrorContainer,
    outline: AppColorsDark.outline,
    outlineVariant: AppColorsDark.outlineVariant,
    inverseSurface: AppColorsDark.inverseSurface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: _buildTextTheme(locale).apply(
      bodyColor: AppColorsDark.onSurface,
      displayColor: AppColorsDark.onSurface,
    ),
    scaffoldBackgroundColor: AppColorsDark.background,
    cardTheme: CardTheme(
      color: AppColorsDark.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColorsDark.surfaceContainerHigh),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.primaryContainer,
        foregroundColor: AppColorsDark.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.stackMd,
          vertical: AppSpacing.stackSm,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.stackMd,
        vertical: AppSpacing.stackSm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.surfaceContainerHigh, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.surfaceContainerHigh, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.primaryContainer, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.error, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: AppColorsDark.primaryContainer.withAlpha(26),
      labelStyle: const TextStyle(color: AppColorsDark.primary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsDark.surface,
      foregroundColor: AppColorsDark.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _buildTextTheme(locale).headlineMedium?.copyWith(
        color: AppColorsDark.onSurface,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorsDark.surface,
      selectedItemColor: AppColorsDark.primary,
      unselectedItemColor: AppColorsDark.onSurfaceVariant,
    ),
    dividerTheme: DividerThemeData(
      color: AppColorsDark.outlineVariant,
      thickness: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColorsDark.primary,
      foregroundColor: AppColorsDark.onPrimary,
      shape: const CircleBorder(),
    ),
  );
}

ThemeData _buildLightTheme(Locale locale) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColorsLight.primary,
    brightness: Brightness.light,
    surface: AppColorsLight.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: _buildTextTheme(locale).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: AppColorsLight.background,
    cardTheme: CardTheme(
      color: AppColorsLight.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(77)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.stackMd,
          vertical: AppSpacing.stackSm,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.stackMd,
        vertical: AppSpacing.stackSm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: colorScheme.primary.withAlpha(26),
      labelStyle: TextStyle(color: colorScheme.primary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsLight.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorsLight.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: const CircleBorder(),
    ),
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light(Locale locale) => _buildLightTheme(locale);
  static ThemeData dark(Locale locale) => _buildDarkTheme(locale);
}
