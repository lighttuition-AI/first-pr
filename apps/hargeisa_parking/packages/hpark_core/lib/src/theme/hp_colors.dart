import 'package:flutter/material.dart';

/// A set of surface/text/border colors for one appearance (dark or light).
/// The brand hues (purple/teal, status colors, tints, gradient) are the same in
/// both modes and live as constants on [HpColors]; only these tokens swap.
class HpPalette {
  const HpPalette({
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.elevated,
    required this.overlay,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.text2,
    required this.textMuted,
    required this.scrim,
  });

  final bool isDark;
  final Color bg; // app background
  final Color surface; // card / surface
  final Color elevated; // elevated surface / popover
  final Color overlay; // hover row / input fill
  final Color border; // hairline
  final Color borderStrong;
  final Color text; // primary text
  final Color text2; // secondary text
  final Color textMuted;
  final Color scrim; // translucent scrollbar/overlay tint

  /// The original dark-first palette ("Linear meets Stripe").
  static const dark = HpPalette(
    isDark: true,
    bg: Color(0xFF0A0A0F),
    surface: Color(0xFF141420),
    elevated: Color(0xFF1B1B2B),
    overlay: Color(0xFF21212F),
    border: Color(0x14FFFFFF), // white @ 0.08
    borderStrong: Color(0x24FFFFFF), // white @ 0.14
    text: Color(0xFFFFFFFF),
    text2: Color(0xFFA0A0B8),
    textMuted: Color(0xFF7A7A90),
    scrim: Color(0x1FFFFFFF),
  );

  /// Light appearance — soft off-white surfaces with the same brand accents.
  static const light = HpPalette(
    isDark: false,
    bg: Color(0xFFF4F5FA),
    surface: Color(0xFFFFFFFF),
    elevated: Color(0xFFFFFFFF),
    overlay: Color(0xFFEDEEF4),
    border: Color(0x14000000), // black @ 0.08
    borderStrong: Color(0x29000000), // black @ 0.16
    text: Color(0xFF14141F),
    text2: Color(0xFF4A4A5E),
    textMuted: Color(0xFF73738A),
    scrim: Color(0x14000000),
  );
}

/// Hargeisa Parking color tokens — now appearance-aware. Brand hues are constant
/// across modes; surface/text/border tokens resolve from the active [palette],
/// so flipping [palette] (via the theme controller) reskins every screen.
abstract final class HpColors {
  /// The active appearance. Driven by the app's theme controller / saved choice.
  static HpPalette palette = HpPalette.dark;

  static bool get isDark => palette.isDark;

  // ---- Brand (mode-independent) ----
  static const purple = Color(0xFF7C6CF8); // Primary — Electric Purple
  static const purple600 = Color(0xFF6655F0); // Pressed / deeper
  static const purple300 = Color(0xFFA99EFB); // Light accent / links
  static const teal = Color(0xFF00D8D6); // Secondary — Bright Teal
  static const teal600 = Color(0xFF00B6B4);

  // ---- Semantic status ----
  static const success = Color(0xFF00C853);
  static const warning = Color(0xFFFFB300);
  static const danger = Color(0xFFFF5252);
  static const info = teal;

  // ---- Surfaces (appearance-aware) ----
  static Color get bg => palette.bg;
  static Color get surface => palette.surface;
  static Color get elevated => palette.elevated;
  static Color get overlay => palette.overlay;

  // ---- Borders & lines (appearance-aware) ----
  static Color get border => palette.border;
  static Color get borderStrong => palette.borderStrong;
  static const borderFocus = Color(0x8C7C6CF8); // purple @ 0.55

  // ---- Text (appearance-aware) ----
  static Color get text => palette.text;
  static Color get text2 => palette.text2;
  static Color get textMuted => palette.textMuted;
  static const textOnAccent = Color(0xFFFFFFFF);

  /// Translucent scrim (scrollbars, faint overlays) — appearance-aware.
  static Color get scrim => palette.scrim;

  // ---- Map markers (operations) ----
  static const mapPaid = Color(0xFF00C853); // green — paid parking
  static const mapExpiring = Color(0xFFFFB300); // yellow — expiring soon
  static const mapViolation = Color(0xFFFF5252); // red — violation
  static const mapOfficer = Color(0xFF3D9DF6); // blue — officer
  static const mapRoute = Color(0xFF7C6CF8); // purple — patrol route

  // ---- Tints (status badge fills) ----
  static const purpleTint = Color(0x297C6CF8);
  static const tealTint = Color(0x2400D8D6);
  static const successTint = Color(0x2600C853);
  static const warningTint = Color(0x26FFB300);
  static const dangerTint = Color(0x26FF5252);
  static const blueTint = Color(0x263D9DF6);

  // ---- Accent gradient (135°, purple → teal) ----
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, teal],
  );

  static const gradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x2E7C6CF8), Color(0x2E00D8D6)],
  );
}
