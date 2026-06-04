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

import '../widgets/scene.dart';
import '../widgets/sea.dart';

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

/// Puffy "claymorphism" shadows — a soft light highlight (top-left) plus a
/// soft dark drop (bottom-right) makes surfaces look inflated and tactile.
List<BoxShadow> _clayShadows(ShLevel l) {
  final hi = Colors.white.withValues(alpha: .7);
  return switch (l) {
    ShLevel.sm => [
        BoxShadow(color: hi, offset: const Offset(-4, -4), blurRadius: 8),
        BoxShadow(color: _sink(.12), offset: const Offset(5, 8), blurRadius: 16),
      ],
    ShLevel.md => [
        BoxShadow(color: hi, offset: const Offset(-6, -6), blurRadius: 14),
        BoxShadow(color: _sink(.16), offset: const Offset(8, 13), blurRadius: 26),
      ],
    ShLevel.lg => [
        BoxShadow(color: hi, offset: const Offset(-9, -9), blurRadius: 20),
        BoxShadow(color: _sink(.20), offset: const Offset(12, 20), blurRadius: 40),
      ],
  };
}

/// Glassy shadows — a faint white top sheen (glass edge) + a soft, wide,
/// low-opacity drop so panels seem to float over translucent water.
List<BoxShadow> _glassShadows(ShLevel l) => switch (l) {
      ShLevel.sm => [
          BoxShadow(color: Colors.white.withValues(alpha: .5), offset: const Offset(0, -1), blurRadius: 2),
          BoxShadow(color: _sink(.10), offset: const Offset(0, 8), blurRadius: 22),
        ],
      ShLevel.md => [
          BoxShadow(color: Colors.white.withValues(alpha: .5), offset: const Offset(0, -1), blurRadius: 3),
          BoxShadow(color: _sink(.13), offset: const Offset(0, 16), blurRadius: 38),
        ],
      ShLevel.lg => [
          BoxShadow(color: Colors.white.withValues(alpha: .5), offset: const Offset(0, -2), blurRadius: 4),
          BoxShadow(color: _sink(.16), offset: const Offset(0, 28), blurRadius: 60),
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

  /// Optional ambient animated scene (floating characters) drawn behind the
  /// app's content. Null = no scene. See [FloatingScene].
  final Widget Function()? sceneBuilder;
  bool get hasScene => sceneBuilder != null;

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
    this.sceneBuilder,
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

/// LOOK 2 — "Jungle": soft claymorphism in jungle pastels, with monkeys &
/// bananas (plus a palm tree with monkeys on it) drifting behind the app.
const _junglePalette = Palette(
  brand: Color(0xFF5BB97D), // leaf green
  brandDeep: Color(0xFF3E9A60),
  brandSoft: Color(0xFFD9F0DD),
  logic: Color(0xFFFF8A5C), // mango
  logicDeep: Color(0xFFE76F43),
  galaxy: Color(0xFF6FB1E6), // sky
  galaxyDeep: Color(0xFF4E92C9),
  discovery: Color(0xFF5BB97D),
  discoveryDeep: Color(0xFF3E9A60),
);

Widget _jungleScene() => FloatingScene(
      sprites: [
        // Palm tree + monkeys "on the tree" (bottom-left).
        emojiSprite('🌴', size: 168, x: -0.012, y: 0.57, bob: 0, sway: 6, rotate: .015, period: 9),
        emojiSprite('🐒', size: 64, x: 0.045, y: 0.49, bob: 6, rotate: .05, period: 5, phase: .1),
        emojiSprite('🙈', size: 56, x: 0.10, y: 0.71, bob: 8, rotate: .04, period: 6, phase: .5),
        // Floating monkeys.
        emojiSprite('🐵', size: 62, x: 0.90, y: 0.15, bob: 18, sway: 10, rotate: .06, period: 7, phase: .2),
        emojiSprite('🐒', size: 50, x: 0.30, y: 0.09, bob: 16, rotate: .05, period: 6.5, phase: .7),
        emojiSprite('🙊', size: 48, x: 0.80, y: 0.80, bob: 14, sway: 8, rotate: .05, period: 6, phase: .35),
        // Floating bananas (gentle spin).
        emojiSprite('🍌', size: 46, x: 0.20, y: 0.24, bob: 16, rotate: .35, period: 5.5, phase: .15),
        emojiSprite('🍌', size: 40, x: 0.63, y: 0.10, bob: 14, rotate: .30, period: 6.2, phase: .6),
        emojiSprite('🍌', size: 52, x: 0.86, y: 0.42, bob: 18, rotate: .40, period: 5.0, phase: .9),
        emojiSprite('🍌', size: 38, x: 0.46, y: 0.80, bob: 13, rotate: .32, period: 6.8, phase: .25),
        emojiSprite('🍌', size: 44, x: 0.72, y: 0.62, bob: 15, rotate: .36, period: 5.7, phase: .45),
      ],
    );

final _jungle = Skin(
  id: 'jungle',
  label: 'Jungle',
  tagline: 'Monkeys, bananas & soft clay',
  palette: _junglePalette,
  ink: const Color(0xFF3B4A39),
  inkSoft: const Color(0xFF6A7A66),
  muted: const Color(0xFFA6B2A0),
  line: const Color(0xFFE4EBDC),
  paper: const Color(0xFFF1F6E8), // soft leaf cream
  card: const Color(0xFFFFFFFF),
  cream: const Color(0xFFFFF1CE),
  sun: const Color(0xFFFFC83D), // banana
  rSm: 22,
  rMd: 32,
  rLg: 46,
  rXl: 64,
  displayFont: 'baloo',
  bodyFont: 'nunito',
  appBackground: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE9F4D6), Color(0xFFF6F1DE)],
    ),
  ),
  shadow: _clayShadows,
  sceneBuilder: _jungleScene,
);

/// LOOK 3 — "Ocean": a glassy underwater world with an ORIGINAL shark family
/// (small→large, in the shark-song colours) swimming around + rising bubbles.
const _oceanPalette = Palette(
  brand: Color(0xFF12A7C4), // teal
  brandDeep: Color(0xFF0E8AA3),
  brandSoft: Color(0xFFCBEEF4),
  logic: Color(0xFFFF7E8B), // coral
  logicDeep: Color(0xFFE85F6E),
  galaxy: Color(0xFF4F8DF0), // deep blue
  galaxyDeep: Color(0xFF3A6FD0),
  discovery: Color(0xFF12A7C4),
  discoveryDeep: Color(0xFF0E8AA3),
);

Widget _oceanScene() => FloatingScene(
      sprites: const [
        // Rising bubbles (behind the sharks).
        Sprite(child: Bubble(size: 16), x: .15, y: .90, driftY: -.050, sway: 10, period: 4.0, phase: .1),
        Sprite(child: Bubble(size: 22), x: .42, y: .96, driftY: -.040, sway: 14, period: 5.0, phase: .5),
        Sprite(child: Bubble(size: 12), x: .63, y: .88, driftY: -.060, sway: 8, period: 3.5, phase: .3),
        Sprite(child: Bubble(size: 18), x: .83, y: .97, driftY: -.045, sway: 12, period: 4.5, phase: .8),
        Sprite(child: Bubble(size: 14), x: .92, y: .85, driftY: -.055, sway: 9, period: 4.0, phase: .2),
        Sprite(child: Bubble(size: 20), x: .30, y: .92, driftY: -.038, sway: 13, period: 5.5, phase: .65),
        // The shark family (small → large), swimming + facing their direction.
        Sprite(child: Shark(color: Color(0xFFFFC83D), size: 72), x: .25, y: .46, drift: .030, faceDrift: true, bob: 10, period: 5.0), // baby — yellow
        Sprite(child: Shark(color: Color(0xFFFF6FA5), size: 108), x: .82, y: .15, drift: -.020, faceDrift: true, bob: 8, period: 7.0), // mummy — pink
        Sprite(child: Shark(color: Color(0xFF3F86E0), size: 132), x: .08, y: .30, drift: .022, faceDrift: true, bob: 7, period: 7.5), // daddy — blue
        Sprite(child: Shark(color: Color(0xFF49B36B), size: 120), x: .55, y: .76, drift: .016, faceDrift: true, bob: 6, period: 8.0), // grandma — green
        Sprite(child: Shark(color: Color(0xFFFF9A3D), size: 150), x: .72, y: .60, drift: -.014, faceDrift: true, bob: 7, period: 8.5), // grandpa — orange
      ],
    );

final _ocean = Skin(
  id: 'ocean',
  label: 'Ocean',
  tagline: 'Shark family in glassy water',
  palette: _oceanPalette,
  ink: const Color(0xFF143641),
  inkSoft: const Color(0xFF3E5A66),
  muted: const Color(0xFF89A6AF),
  line: const Color(0xFFD7E9EE),
  paper: const Color(0xFFE2F4F8), // pale aqua
  card: const Color(0xFFFFFFFF),
  cream: const Color(0xFFFFF3D6),
  sun: const Color(0xFFFFD25E),
  rSm: 20,
  rMd: 30,
  rLg: 42,
  rXl: 58,
  displayFont: 'quicksand',
  bodyFont: 'nunito',
  appBackground: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFBCE9F5), Color(0xFF86D2E8), Color(0xFF46AFD0)],
    ),
  ),
  shadow: _glassShadows,
  sceneBuilder: _oceanScene,
);

/// All skins by id.
final Map<String, Skin> kSkins = {
  for (final s in [_sunshine, _classic, _jungle, _ocean]) s.id: s,
};

/// Ordered ids shown in the Settings → Look picker (the new default first).
const List<String> kReadySkins = ['sunshine', 'jungle', 'ocean', 'classic'];

const String kDefaultSkin = 'sunshine';

/// The currently-applied skin. The design tokens read this. Swap it via
/// [setActiveSkin] (AppState does this when the saved/selected look changes).
Skin activeSkin = kSkins[kDefaultSkin]!;

void setActiveSkin(String id) {
  activeSkin = kSkins[id] ?? kSkins[kDefaultSkin]!;
}
