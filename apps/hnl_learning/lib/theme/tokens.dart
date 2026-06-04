// ============================================================
// HNL Learning — Design tokens
// Fresh-meadow palette · rounded kid-safe UI · audio-first.
// Ported 1:1 from the prototype's styles.css design system.
// All pixel values are in the 1366 × 1024 logical canvas.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Parse a CSS-style hex string (#RRGGBB or #AARRGGBB) into a [Color].
Color hex(String h) {
  var s = h.replaceAll('#', '').trim();
  if (s.length == 6) s = 'FF$s';
  return Color(int.parse(s, radix: 16));
}

/// A swappable brand palette (Meadow / Cosmic / Candy — see Tweaks).
class Palette {
  final Color brand, brandDeep, brandSoft;
  final Color logic, logicDeep, galaxy, galaxyDeep, discovery, discoveryDeep;
  const Palette({
    required this.brand,
    required this.brandDeep,
    required this.brandSoft,
    required this.logic,
    required this.logicDeep,
    required this.galaxy,
    required this.galaxyDeep,
    required this.discovery,
    required this.discoveryDeep,
  });

  Color get coral => logic;

  /// World accent by world id.
  Color world(String id) => switch (id) {
        'logic' => logic,
        'galaxy' => galaxy,
        'discovery' => discovery,
        _ => brand,
      };

  Color worldDeep(String id) => switch (id) {
        'logic' => logicDeep,
        'galaxy' => galaxyDeep,
        'discovery' => discoveryDeep,
        _ => brandDeep,
      };
}

const Map<String, Palette> kPalettes = {
  'meadow': Palette(
    brand: Color(0xFF15B886),
    brandDeep: Color(0xFF0E9E73),
    brandSoft: Color(0xFFC9F0E0),
    logic: Color(0xFFFF7A59),
    logicDeep: Color(0xFFE85D3D),
    galaxy: Color(0xFF5C7CFA),
    galaxyDeep: Color(0xFF3F5FD8),
    discovery: Color(0xFF15B886),
    discoveryDeep: Color(0xFF0E9E73),
  ),
  'cosmic': Palette(
    brand: Color(0xFF6C5CE7),
    brandDeep: Color(0xFF5346C0),
    brandSoft: Color(0xFFDBD6FF),
    logic: Color(0xFFFF9F43),
    logicDeep: Color(0xFFE8842A),
    galaxy: Color(0xFF22B8D6),
    galaxyDeep: Color(0xFF1893AD),
    discovery: Color(0xFF6C5CE7),
    discoveryDeep: Color(0xFF5346C0),
  ),
  'candy': Palette(
    brand: Color(0xFFFF6B9D),
    brandDeep: Color(0xFFE8497F),
    brandSoft: Color(0xFFFFD8E5),
    logic: Color(0xFFFFC23C),
    logicDeep: Color(0xFFE0A21F),
    galaxy: Color(0xFF4ECDC4),
    galaxyDeep: Color(0xFF33ABA2),
    discovery: Color(0xFFFF6B9D),
    discoveryDeep: Color(0xFFE8497F),
  ),
};

/// Constant neutrals & accents (palette-independent).
class C {
  static const ink = Color(0xFF2B3A43);
  static const inkSoft = Color(0xFF5C6B73);
  static const muted = Color(0xFF97A6AD);
  static const line = Color(0xFFE7EDE9);
  static const paper = Color(0xFFFFFDF7);
  static const card = Color(0xFFFFFFFF);
  static const cream = Color(0xFFFFF6E4);
  static const sun = Color(0xFFFFC23C);
  static const letterbox = Color(0xFF20262B);

  // Confetti / reward star palette
  static const star = Color(0xFFFFD23F);
  static const conf1 = Color(0xFF6C5CE7);
  static const conf2 = Color(0xFF5C7CFA);
  static const conf3 = Color(0xFF4ECDC4);
  static const conf4 = Color(0xFFFF7A59);
  static const conf5 = Color(0xFFFFC23C);

  static const confetti = [conf1, conf2, conf3, conf4, conf5, star];

  static Color inkA(double o) => Color.fromRGBO(43, 58, 67, o);
}

/// Radii — generous, kid-safe.
class R {
  static const sm = 14.0;
  static const md = 22.0;
  static const lg = 34.0;
  static const xl = 48.0;
  static const pill = 999.0;
}

/// Soft, lifted shadows (a flat color "drop" + an ambient blur).
class Sh {
  static List<BoxShadow> get sm => [
        BoxShadow(color: C.inkA(.06), offset: const Offset(0, 4)),
        BoxShadow(color: C.inkA(.08), offset: const Offset(0, 6), blurRadius: 16),
      ];
  static List<BoxShadow> get md => [
        BoxShadow(color: C.inkA(.07), offset: const Offset(0, 6)),
        BoxShadow(color: C.inkA(.12), offset: const Offset(0, 14), blurRadius: 30),
      ];
  static List<BoxShadow> get lg => [
        BoxShadow(color: C.inkA(.06), offset: const Offset(0, 10)),
        BoxShadow(color: C.inkA(.16), offset: const Offset(0, 26), blurRadius: 50),
      ];
}

/// Stage geometry (iPad 12.9" landscape logical points).
const double kStageW = 1366;
const double kStageH = 1024;

/// Minimum touch target for 2–8 year-olds.
const double kTap = 72;

/// Type scale (display = Baloo 2, body = Nunito).
class AppText {
  static TextStyle display({
    double size = 30,
    FontWeight weight = FontWeight.w700,
    Color color = C.ink,
    double height = 1.1,
    double? letterSpacing,
    bool quicksand = false,
  }) {
    final fn = quicksand ? GoogleFonts.quicksand : GoogleFonts.baloo2;
    return fn(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color color = C.ink,
    double height = 1.3,
  }) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle h1 = display(size: 72, weight: FontWeight.w800, height: 1.02);
  static TextStyle h2 = display(size: 52, weight: FontWeight.w700, height: 1.05);
  static TextStyle lead =
      body(size: 30, weight: FontWeight.w600, color: C.inkSoft, height: 1.35);
  static TextStyle kicker = display(
    size: 20,
    weight: FontWeight.w700,
    color: C.muted,
    letterSpacing: 2,
  );
  static TextStyle bubble = display(size: 38, weight: FontWeight.w700);
}
