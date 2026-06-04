// ============================================================
// HNL Learning — Skins ("Looks")
// ------------------------------------------------------------
// A *Skin* is one complete visual identity: palette + neutrals +
// corner radii + shadow language + type pairing + background.
// The design tokens in `tokens.dart` (C / R / Sh / AppText) read
// the [activeSkin], so swapping a skin reskins the whole app with
// no per-screen changes. Every "Look" the app ships lives here —
// this file is the single tidy home for all of them.
//
// Looks ship one at a time (each its own PR). `kReadySkins` is the
// ordered list the Settings → Look picker shows.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Parse a CSS-style hex string (#RRGGBB or #AARRGGBB) into a [Color].
Color hex(String h) {
  var s = h.replaceAll('#', '').trim();
  if (s.length == 6) s = 'FF$s';
  return Color(int.parse(s, radix: 16));
}

/// Fixed dark "ink" used for shadows and scrims — stays dark on every
/// skin (including dark looks) so drop-shadows and modal scrims read
/// correctly even when the *text* ink is light.
Color _sink(double o) => Color.fromRGBO(20, 26, 33, o);

// ------------------------------------------------------------
// Palette — the four world accents + brand.
// ------------------------------------------------------------
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
        'arabic' => const Color(0xFF6E5AC8), // distinct purple
        _ => brand,
      };

  Color worldDeep(String id) => switch (id) {
        'logic' => logicDeep,
        'galaxy' => galaxyDeep,
        'discovery' => discoveryDeep,
        'arabic' => const Color(0xFF4E3DA0),
        _ => brandDeep,
      };
}

/// Legacy palette map (kept so old saves referencing a palette name still
/// resolve). Skins carry their own palette; this is just a fallback table.
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
};

// ------------------------------------------------------------
// Shadow language — each level (sm/md/lg) maps to a list of shadows.
// Different skins build them differently (soft & lifted, hard sticker
// blocks, puffy clay, colored glow…).
// ------------------------------------------------------------
enum ShLevel { sm, md, lg }

/// Soft, diffuse, lifted shadows — the premium "floating card" feel.
List<BoxShadow> _softShadows(ShLevel l) => switch (l) {
      ShLevel.sm => [
          BoxShadow(color: _sink(.05), offset: const Offset(0, 2), blurRadius: 6),
          BoxShadow(color: _sink(.08), offset: const Offset(0, 10), blurRadius: 24),
        ],
      ShLevel.md => [
          BoxShadow(color: _sink(.06), offset: const Offset(0, 4), blurRadius: 12),
          BoxShadow(color: _sink(.12), offset: const Offset(0, 18), blurRadius: 40),
        ],
      ShLevel.lg => [
          BoxShadow(color: _sink(.05), offset: const Offset(0, 8), blurRadius: 18),
          BoxShadow(color: _sink(.16), offset: const Offset(0, 30), blurRadius: 64),
        ],
    };

/// The original prototype shadows — a flat solid "drop" + an ambient blur.
List<BoxShadow> _classicShadows(ShLevel l) => switch (l) {
      ShLevel.sm => [
          BoxShadow(color: _sink(.06), offset: const Offset(0, 4)),
          BoxShadow(color: _sink(.08), offset: const Offset(0, 6), blurRadius: 16),
        ],
      ShLevel.md => [
          BoxShadow(color: _sink(.07), offset: const Offset(0, 6)),
          BoxShadow(color: _sink(.12), offset: const Offset(0, 14), blurRadius: 30),
        ],
      ShLevel.lg => [
          BoxShadow(color: _sink(.06), offset: const Offset(0, 10)),
          BoxShadow(color: _sink(.16), offset: const Offset(0, 26), blurRadius: 50),
        ],
    };

// ------------------------------------------------------------
// Skin — one complete look.
// ------------------------------------------------------------
class Skin {
  final String id;
  final String label;
  final String tagline;

  final Palette palette;

  // Neutrals.
  final Color ink, inkSoft, muted, line, paper, card, cream, sun;

  // Corner radii (pill is always 999).
  final double rSm, rMd, rLg, rXl;

  // Type pairing (google_fonts keys: baloo | quicksand | fredoka | nunito).
  final String displayFont;
  final String bodyFont;

  // Surface treatment.
  final Border? cardBorder; // e.g. neubrutalism ink outline
  final double cardOpacity; // <1 for frosted-glass cards
  final bool blurCards; // true → frosted backdrop blur on cards

  /// Full-stage background painted behind every screen.
  final BoxDecoration appBackground;

  /// Light vs dark — drives system contrast choices.
  final Brightness brightness;

  final List<BoxShadow> Function(ShLevel) shadowFn;
  List<BoxShadow> shadow(ShLevel l) => shadowFn(l);

  const Skin({
    required this.id,
    required this.label,
    required this.tagline,
    required this.palette,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.line,
    required this.paper,
    required this.card,
    required this.cream,
    required this.sun,
    required this.rSm,
    required this.rMd,
    required this.rLg,
    required this.rXl,
    required this.displayFont,
    required this.bodyFont,
    required this.appBackground,
    required List<BoxShadow> Function(ShLevel) shadow,
    this.cardBorder,
    this.cardOpacity = 1,
    this.blurCards = false,
    this.brightness = Brightness.light,
  }) : shadowFn = shadow;

  /// Swatches shown on the picker card.
  List<Color> get swatches => [palette.brand, palette.coral, palette.galaxy, sun];

  TextStyle _font(
    String key, {
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    final fn = switch (key) {
      'quicksand' => GoogleFonts.quicksand,
      'fredoka' => GoogleFonts.fredoka,
      'nunito' => GoogleFonts.nunito,
      _ => GoogleFonts.baloo2,
    };
    return fn(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle displayStyle({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) =>
      _font(displayFont,
          size: size, weight: weight, color: color, height: height, letterSpacing: letterSpacing);

  TextStyle bodyStyle({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
  }) =>
      _font(bodyFont, size: size, weight: weight, color: color, height: height);
}

// ============================================================
// The Looks.  Add a new Skin below and append its id to
// `kReadySkins` when it's polished + tested.
// ============================================================

/// Refined, brighter take on the meadow palette for the new default look.
const _sunshinePalette = Palette(
  brand: Color(0xFF12B981), // grass mint
  brandDeep: Color(0xFF0C9E6E),
  brandSoft: Color(0xFFCBF2E2),
  logic: Color(0xFFFF7A59), // warm coral
  logicDeep: Color(0xFFE85D3D),
  galaxy: Color(0xFF5B8DEF), // friendly sky blue
  galaxyDeep: Color(0xFF3F6FD8),
  discovery: Color(0xFF12B981),
  discoveryDeep: Color(0xFF0C9E6E),
);

/// LOOK 1 — "Sunshine": the polished, professional default. Warmer paper,
/// rounder cards, soft lifted shadows, brighter accents. Same friendly type.
final _sunshine = Skin(
  id: 'sunshine',
  label: 'Sunshine',
  tagline: 'Bright, polished & friendly',
  palette: _sunshinePalette,
  ink: const Color(0xFF273039),
  inkSoft: const Color(0xFF5E6C75),
  muted: const Color(0xFFA2AEB4),
  line: const Color(0xFFEDEFE9),
  paper: const Color(0xFFFCF8F1), // warm cream-white
  card: const Color(0xFFFFFFFF),
  cream: const Color(0xFFFFF3DE),
  sun: const Color(0xFFFFC23C),
  rSm: 18,
  rMd: 26,
  rLg: 38,
  rXl: 54,
  displayFont: 'baloo',
  bodyFont: 'nunito',
  appBackground: const BoxDecoration(color: Color(0xFFFCF8F1)),
  shadow: _softShadows,
);

/// "Classic": the original look, preserved 1:1 so the change is reversible
/// and the before/after is one tap apart.
final _classic = Skin(
  id: 'classic',
  label: 'Classic',
  tagline: 'The original look',
  palette: kPalettes['meadow']!,
  ink: const Color(0xFF2B3A43),
  inkSoft: const Color(0xFF5C6B73),
  muted: const Color(0xFF97A6AD),
  line: const Color(0xFFE7EDE9),
  paper: const Color(0xFFFFFDF7),
  card: const Color(0xFFFFFFFF),
  cream: const Color(0xFFFFF6E4),
  sun: const Color(0xFFFFC23C),
  rSm: 14,
  rMd: 22,
  rLg: 34,
  rXl: 48,
  displayFont: 'baloo',
  bodyFont: 'nunito',
  appBackground: const BoxDecoration(color: Color(0xFFFFFDF7)),
  shadow: _classicShadows,
);

/// All skins by id.
final Map<String, Skin> kSkins = {
  for (final s in [_sunshine, _classic]) s.id: s,
};

/// Ordered ids shown in the Settings → Look picker (the new default first).
const List<String> kReadySkins = ['sunshine', 'classic'];

const String kDefaultSkin = 'sunshine';

/// The currently-applied skin. The design tokens read this. Swap it via
/// [setActiveSkin] (AppState does this when the saved/selected look changes).
Skin activeSkin = kSkins[kDefaultSkin]!;

void setActiveSkin(String id) {
  activeSkin = kSkins[id] ?? kSkins[kDefaultSkin]!;
}
