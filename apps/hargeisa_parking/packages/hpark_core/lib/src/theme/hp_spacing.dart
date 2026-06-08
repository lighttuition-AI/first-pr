/// Spacing, radius & sizing tokens — 8px base grid (4px half-steps).
/// Ported from the design system `tokens/spacing.css`.
abstract final class HpSpace {
  static const double x0 = 0;
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;
  static const double x20 = 80;
  static const double x24 = 96;
}

/// Corner radii.
abstract final class HpRadius {
  static const double sm = 6; // inputs, tags
  static const double md = 8; // buttons
  static const double lg = 12; // cards
  static const double xl = 16; // large panels / sheets
  static const double xxl = 24; // hero surfaces
  static const double pill = 999; // pills, avatars
}

/// Touch / control sizing (≥44px hit targets) and fixed layout metrics.
abstract final class HpSize {
  static const double controlSm = 36;
  static const double controlMd = 44; // default — meets mobile minimum
  static const double controlLg = 52;
  static const double controlXl = 60; // primary mobile actions

  static const double sidebar = 248;
  static const double bottomNav = 72;
  static const double topbar = 64;
  static const double container = 1200;
}
