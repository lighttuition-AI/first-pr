// ============================================================
// HNL Learning — Design tokens
// ------------------------------------------------------------
// These tokens (C / R / Sh / AppText) are thin views over the
// [activeSkin] (see skins.dart). Swap the skin and the whole app
// reskins — colors, radii, shadows and type all follow. Pixel
// values are in the 1366 × 1024 logical canvas.
// ============================================================
import 'package:flutter/material.dart';

import 'skins.dart';
// Re-export so the rest of the app can keep importing just tokens.dart
// and still see Palette / Skin / hex / kSkins / activeSkin, etc.
export 'skins.dart';

/// Neutrals & fixed accents. The greys/paper/ink follow the active skin;
/// the confetti/star palette and the letterbox frame stay constant.
class C {
  // Skin-driven neutrals.
  static Color get ink => activeSkin.ink;
  static Color get inkSoft => activeSkin.inkSoft;
  static Color get muted => activeSkin.muted;
  static Color get line => activeSkin.line;
  static Color get paper => activeSkin.paper;
  static Color get card => activeSkin.card;
  static Color get cream => activeSkin.cream;
  static Color get sun => activeSkin.sun;

  // Constant frame + celebration palette (skin-independent).
  static const letterbox = Color(0xFF20262B);
  static const star = Color(0xFFFFD23F);
  static const conf1 = Color(0xFF6C5CE7);
  static const conf2 = Color(0xFF5C7CFA);
  static const conf3 = Color(0xFF4ECDC4);
  static const conf4 = Color(0xFFFF7A59);
  static const conf5 = Color(0xFFFFC23C);
  static const confetti = [conf1, conf2, conf3, conf4, conf5, star];

  /// Fixed dark "ink" for shadows & scrims — stays dark on every skin.
  static Color inkA(double o) => Color.fromRGBO(20, 26, 33, o);
}

/// Radii — follow the active skin (pill is always fully round).
class R {
  static double get sm => activeSkin.rSm;
  static double get md => activeSkin.rMd;
  static double get lg => activeSkin.rLg;
  static double get xl => activeSkin.rXl;
  static const pill = 999.0;
}

/// Shadows — the active skin defines the language (soft / classic / clay…).
class Sh {
  static List<BoxShadow> get sm => activeSkin.shadow(ShLevel.sm);
  static List<BoxShadow> get md => activeSkin.shadow(ShLevel.md);
  static List<BoxShadow> get lg => activeSkin.shadow(ShLevel.lg);
}

/// Stage geometry (iPad 12.9" landscape logical points).
const double kStageW = 1366;
const double kStageH = 1024;

/// Minimum touch target for 2–8 year-olds.
const double kTap = 72;

/// Type scale. Display & body fonts follow the active skin's pairing.
class AppText {
  static TextStyle display({
    double size = 30,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1.1,
    double? letterSpacing,
  }) =>
      activeSkin.displayStyle(
        size: size,
        weight: weight,
        color: color ?? C.ink,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle body({
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1.3,
  }) =>
      activeSkin.bodyStyle(
        size: size,
        weight: weight,
        color: color ?? C.ink,
        height: height,
      );

  static TextStyle get h1 => display(size: 72, weight: FontWeight.w800, height: 1.02);
  static TextStyle get h2 => display(size: 52, weight: FontWeight.w700, height: 1.05);
  static TextStyle get lead =>
      body(size: 30, weight: FontWeight.w600, color: C.inkSoft, height: 1.35);
  static TextStyle get kicker => display(
        size: 20,
        weight: FontWeight.w700,
        color: C.muted,
        letterSpacing: 2,
      );
  static TextStyle get bubble => display(size: 38, weight: FontWeight.w700);
}
