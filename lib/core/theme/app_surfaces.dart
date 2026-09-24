import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Page and card backgrounds used across the screens.
///
/// The dark values are the colors the screens used to hard-code, so dark
/// mode looks exactly as before; the light values follow the light palette.
@immutable
class AppSurfaces extends ThemeExtension<AppSurfaces> {
  /// Background of top-level pages (home, search, profile, …).
  final Color page;

  /// Background of browse pages and viewers.
  final Color shell;

  /// Cards and list tiles.
  final Color card;

  /// Border around [card].
  final Color cardBorder;

  /// Bottom sheets and dialogs.
  final Color sheet;

  /// Very subtle fill for secondary cards.
  final Color faint;

  const AppSurfaces({
    required this.page,
    required this.shell,
    required this.card,
    required this.cardBorder,
    required this.sheet,
    required this.faint,
  });

  static const dark = AppSurfaces(
    page: Color(0xFF0D0D14),
    shell: Color(0xFF111221),
    card: Color(0xFF15151F),
    cardBorder: Color(0xFF1A1A26),
    sheet: Color(0xFF1D1E2E),
    faint: Color(0x0D15151F),
  );

  static const light = AppSurfaces(
    page: AppColorsLight.background,
    shell: AppColorsLight.background,
    card: AppColorsLight.surface,
    cardBorder: Color(0xFFE3E5EC),
    sheet: AppColorsLight.surface,
    faint: Color(0xFFF0F2F6),
  );

  @override
  AppSurfaces copyWith({
    Color? page,
    Color? shell,
    Color? card,
    Color? cardBorder,
    Color? sheet,
    Color? faint,
  }) =>
      AppSurfaces(
        page: page ?? this.page,
        shell: shell ?? this.shell,
        card: card ?? this.card,
        cardBorder: cardBorder ?? this.cardBorder,
        sheet: sheet ?? this.sheet,
        faint: faint ?? this.faint,
      );

  @override
  AppSurfaces lerp(AppSurfaces? other, double t) {
    if (other == null) return this;
    return AppSurfaces(
      page: Color.lerp(page, other.page, t)!,
      shell: Color.lerp(shell, other.shell, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
    );
  }
}

extension AppSurfacesX on BuildContext {
  AppSurfaces get surfaces =>
      Theme.of(this).extension<AppSurfaces>() ?? AppSurfaces.dark;
}

extension AppSurfacesTheme on ThemeData {
  AppSurfaces get surfaces => extension<AppSurfaces>() ?? AppSurfaces.dark;
}
