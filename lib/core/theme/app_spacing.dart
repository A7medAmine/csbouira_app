// ---------------------------------------------------------------------------
// CS Bouira Design System — Spacing
// Source: design_reference/cs_bouira_core/DESIGN.md (YAML `spacing` section)
// ---------------------------------------------------------------------------

class AppSpacing {
  AppSpacing._();

  /// Base unit (4px) — all spacing values are multiples of this
  static const double unit = 4;

  /// Maximum content width for large screens
  static const double containerMax = 1280;

  // ── Gutters & Margins ─────────────────────────────────────────────────

  /// Page gutter (standard horizontal padding between content and screen edge)
  static const double gutter = 24;

  /// Side margins on mobile
  static const double marginMobile = 16;

  /// Side margins on desktop
  static const double marginDesktop = 32;

  // ── Vertical Stack Spacing ────────────────────────────────────────────

  /// Small vertical gap (8px)
  static const double stackSm = 8;

  /// Medium vertical gap (16px)
  static const double stackMd = 16;

  /// Large vertical gap (32px)
  static const double stackLg = 32;
}
