// ---------------------------------------------------------------------------
// CS Bouira Design System — Border Radius
// Source: design_reference/cs_bouira_core/DESIGN.md (YAML `rounded` section)
//
// All values from the structured export. The Brand prose mentions "20px for
// cards (rounded-xl)" but the YAML defines xl as 1.5rem = 24px at 16px base.
// We use the YAML values here and note the 4px discrepancy.
// ---------------------------------------------------------------------------

class AppRadius {
  AppRadius._();

  /// 4px — Small elements (tags, small indicators)
  static const double sm = 4;

  /// 8px — Default (not explicitly mapped to a component in the prose)
  static const double default_ = 8;

  /// 12px — Buttons, input fields (matches Brand "12px radius")
  static const double md = 12;

  /// 16px — Large containers (matches Brand "cards use generous radius")
  /// NOTE: Brand prose says 20px for cards, but YAML lg = 1rem = 16px.
  /// Using YAML value as primary source; flagging 4px ambiguity.
  static const double lg = 16;

  /// 24px — Extra-large containers (YAML xl = 1.5rem = 24px)
  /// NOTE: Brand prose says cards use "rounded-xl (20px)". The YAML defines
  /// xl as 1.5rem which evaluates to 24px at 16px/base rem. Unclear which
  /// is authoritative; exporting the YAML value here.
  static const double xl = 24;

  /// 9999px — Pill shape for chips, FABs, tags
  static const double full = 9999;
}
