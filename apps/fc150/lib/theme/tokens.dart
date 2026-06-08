import 'package:flutter/material.dart';

/// FC150 design tokens — the Hargeisa Parking dark-first system fused with an
/// e-sports football-card aesthetic. Dark-first only; there is no light theme.
/// Hex/rgba values mirror the design handoff README exactly.
class FC {
  FC._();

  // ---- Color: the four-step dark stack (depth = layering, not shadow) ----
  static const bg = Color(0xFF0A0A0F); // app background
  static const surface = Color(0xFF141420); // cards / rows
  static const elevated = Color(0xFF1B1B2B); // sheets / popovers
  static const overlay = Color(0xFF21212F); // hover/input fill, steppers

  // ---- Brand ----
  static const purple = Color(0xFF7C6CF8); // primary
  static const purple600 = Color(0xFF6655F0); // pressed
  static const purple300 = Color(0xFFA99EFB); // links, active nav, ratings
  static const teal = Color(0xFF00D8D6); // secondary

  // ---- Semantic ----
  static const success = Color(0xFF00C853);
  static const warning = Color(0xFFFFB300);
  static const danger = Color(0xFFFF5252);

  // ---- Text ----
  static const text = Color(0xFFFFFFFF);
  static const text2 = Color(0xFFA0A0B8);
  static const textMuted = Color(0xFF7A7A90);

  // ---- Borders ----
  static const border = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const borderStrong = Color(0x24FFFFFF); // rgba(255,255,255,0.14)
  static const borderFocus = Color(0x8C7C6CF8); // rgba(124,108,248,0.55)

  // ---- Status tints (12–16% fills behind pill badges) ----
  static const purpleTint = Color(0x297C6CF8); // 0.16
  static const tealTint = Color(0x2400D8D6); // 0.14
  static const successTint = Color(0x2600C853); // 0.15
  static const warningTint = Color(0x26FFB300); // 0.15
  static const dangerTint = Color(0x26FF5252); // 0.15

  // ---- Accent gradient (135°, purple→teal) — used sparingly ----
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, teal],
  );

  // Soft variant used behind avatar initials.
  static const gradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x4D7C6CF8), Color(0x3300D8D6)],
  );

  static const tealButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D8D6), Color(0xFF00B6B4)],
  );

  // ---- Elevation = glow, not shadow ----
  // "0 0 0 1px ring" is modelled as a 0-blur, +1 spread shadow; the soft halo as
  // a blurred, negatively-spread shadow.
  static const glowPurpleSm = <BoxShadow>[
    BoxShadow(color: Color(0x597C6CF8), blurRadius: 0, spreadRadius: 1),
    BoxShadow(
        color: Color(0x667C6CF8),
        blurRadius: 16,
        spreadRadius: -6,
        offset: Offset(0, 4)),
  ];
  static const glowPurple = <BoxShadow>[
    BoxShadow(color: Color(0x667C6CF8), blurRadius: 0, spreadRadius: 1),
    BoxShadow(
        color: Color(0x737C6CF8),
        blurRadius: 30,
        spreadRadius: -8,
        offset: Offset(0, 8)),
  ];
  static const glowTeal = <BoxShadow>[
    BoxShadow(color: Color(0x6600D8D6), blurRadius: 0, spreadRadius: 1),
    BoxShadow(
        color: Color(0x6600D8D6),
        blurRadius: 30,
        spreadRadius: -8,
        offset: Offset(0, 8)),
  ];
  static const glowDanger = <BoxShadow>[
    BoxShadow(color: Color(0x66FF5252), blurRadius: 0, spreadRadius: 1),
    BoxShadow(
        color: Color(0x66FF5252),
        blurRadius: 30,
        spreadRadius: -8,
        offset: Offset(0, 8)),
  ];
  // Popovers are the one exception that may use a soft dark shadow.
  static const elevPopover = <BoxShadow>[
    BoxShadow(
        color: Color(0xB3000000),
        blurRadius: 24,
        spreadRadius: -8,
        offset: Offset(0, 12)),
  ];

  // ---- Radius ----
  static const rInput = 6.0;
  static const rButton = 8.0;
  static const rCard = 12.0;
  static const rPanel = 16.0;
  static const rSheet = 20.0;
  static const rHero = 24.0;
  static const rPlayerCard = 18.0;
  static const rPill = 999.0;

  // ---- Motion ----
  static const durFast = Duration(milliseconds: 120);
  static const durBase = Duration(milliseconds: 180);
  static const durSlow = Duration(milliseconds: 260);
  static const easeOut = Cubic(0.22, 1, 0.36, 1);

  /// Stat → colour mapping shared by cards, bars and tables.
  static Color statColor(int v) {
    if (v >= 85) return success;
    if (v >= 70) return teal;
    if (v >= 55) return warning;
    return danger;
  }
}
