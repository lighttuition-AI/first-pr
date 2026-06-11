import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hp_colors.dart';

/// Typography tokens — Headings: Inter Tight · Body: Inter · Mono: JetBrains Mono.
/// Ported from the design system `tokens/typography.css`.
///
/// Type scale (px): 48 / 36 / 28 / 22 / 18 / 16 / 14 / 12. Min body 14, caption 12.
abstract final class HpType {
  // ---- Heading family: Inter Tight (tight tracking, line-height ~1.05) ----
  static TextStyle heading({
    required double size,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1.05,
  }) =>
      GoogleFonts.interTight(
        fontSize: size,
        fontWeight: weight,
        color: color ?? HpColors.text,
        height: height,
        letterSpacing: size * -0.02, // -0.02em
      );

  // ---- Body family: Inter ----
  static TextStyle body({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.5,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color ?? HpColors.text2,
        height: height,
      );

  // ---- Mono family: JetBrains Mono (tabular figures for IDs, plates, money) ----
  static TextStyle mono({
    required double size,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double letterSpacing = -0.01,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color ?? HpColors.text,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ---- Named heading steps ----
  static TextStyle get h1 => heading(size: 48, weight: FontWeight.w800);
  static TextStyle get h2 => heading(size: 36, weight: FontWeight.w700);
  static TextStyle get h3 => heading(size: 28, weight: FontWeight.w700);
  static TextStyle get h4 => heading(size: 22, weight: FontWeight.w700);

  // ---- Named body steps ----
  static TextStyle get bodyLg => body(size: 18);
  static TextStyle get bodyBase => body(size: 16);
  static TextStyle get bodySm => body(size: 14);
  static TextStyle get caption => body(size: 12, color: HpColors.textMuted);

  /// Tiny uppercase eyebrow / label with wide tracking.
  static TextStyle get eyebrow => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: HpColors.textMuted,
        letterSpacing: 1.6,
      );
}
