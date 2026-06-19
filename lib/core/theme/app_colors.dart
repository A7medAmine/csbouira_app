import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// CS Bouira Design System — Colors
// Source: design_reference/cs_bouira_core/DESIGN.md
//
// The YAML frontmatter provides a full Material 3 dark palette.
// Light-mode values are not present in the export; the Brand & Style
// section describes them in prose (bg #F7F8FA, surface #FFFFFF,
// primary accent #1A6FFF). Those are used below as the seed for the
// light ColorScheme, with a comment noting they are not from the
// structured export.
// ---------------------------------------------------------------------------

// ── Dark palette (from YAML export) ────────────────────────────────────────

class AppColorsDark {
  AppColorsDark._();

  // Surface / Background
  static const Color background = Color(0xFF111221);
  static const Color surface = Color(0xFF111221);
  static const Color surfaceDim = Color(0xFF111221);
  static const Color surfaceBright = Color(0xFF373849);
  static const Color surfaceContainerLowest = Color(0xFF0c0d1c);
  static const Color surfaceContainerLow = Color(0xFF191a2a);
  static const Color surfaceContainer = Color(0xFF1d1e2e);
  static const Color surfaceContainerHigh = Color(0xFF282939);
  static const Color surfaceContainerHighest = Color(0xFF323344);
  static const Color surfaceVariant = Color(0xFF323344);

  // On-colors
  static const Color onBackground = Color(0xFFe1e0f6);
  static const Color onSurface = Color(0xFFe1e0f6);
  static const Color onSurfaceVariant = Color(0xFFc2c6d8);

  // Primary
  static const Color primary = Color(0xFFb2c5ff);
  static const Color onPrimary = Color(0xFF002c72);
  static const Color primaryContainer = Color(0xFF5a8cff);
  static const Color onPrimaryContainer = Color(0xFF002564);
  static const Color inversePrimary = Color(0xFF0056d1);

  // Secondary
  static const Color secondary = Color(0xFFc7c5d3);
  static const Color onSecondary = Color(0xFF302f3a);
  static const Color secondaryContainer = Color(0xFF494854);
  static const Color onSecondaryContainer = Color(0xFFb9b7c5);

  // Tertiary
  static const Color tertiary = Color(0xFFc7c5d5);
  static const Color onTertiary = Color(0xFF2f2f3c);
  static const Color tertiaryContainer = Color(0xFF918f9f);
  static const Color onTertiaryContainer = Color(0xFF292935);

  // Error
  static const Color error = Color(0xFFffb4ab);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000a);
  static const Color onErrorContainer = Color(0xFFffdad6);

  // Outline
  static const Color outline = Color(0xFF8c90a1);
  static const Color outlineVariant = Color(0xFF424655);

  // Fixed / Inverse
  static const Color primaryFixed = Color(0xFFdae2ff);
  static const Color primaryFixedDim = Color(0xFFb2c5ff);
  static const Color onPrimaryFixed = Color(0xFF001847);
  static const Color onPrimaryFixedVariant = Color(0xFF0040a0);
  static const Color secondaryFixed = Color(0xFFe4e1ef);
  static const Color secondaryFixedDim = Color(0xFFc7c5d3);
  static const Color onSecondaryFixed = Color(0xFF1b1b25);
  static const Color onSecondaryFixedVariant = Color(0xFF464651);
  static const Color tertiaryFixed = Color(0xFFe3e0f2);
  static const Color tertiaryFixedDim = Color(0xFFc7c5d5);
  static const Color onTertiaryFixed = Color(0xFF1a1a26);
  static const Color onTertiaryFixedVariant = Color(0xFF464553);
  static const Color inverseSurface = Color(0xFFe1e0f6);
  static const Color inverseOnSurface = Color(0xFF2e2f3f);

  // Surface tint
  static const Color surfaceTint = Color(0xFFb2c5ff);
}

// ── Light palette (from Brand & Style prose section) ──────────────────────
// NOTE: Only background, surface, and primary accent are specified in the
// prose. The remaining roles are derived from primary #1A6FFF via
// Material 3 seed. These are NOT from the structured YAML export.
class AppColorsLight {
  AppColorsLight._();

  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1A6FFF);
}

// ── High-level semantic tokens (used by both modes) ───────────────────────

class AppColors {
  AppColors._();

  /// Brand "Electric Blue" accent — used as light primary, container in dark.
  static const Color accentBlue = Color(0xFF1A6FFF);

  // Success / Error from Brand prose
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF1744);
}
