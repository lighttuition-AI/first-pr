import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Typography helpers. Headings = Inter Tight, body = Inter, numbers/IDs =
/// JetBrains Mono (tabular figures). Returns ready-to-use [TextStyle]s.
class FCType {
  FCType._();

  static TextStyle heading({
    double size = 23,
    FontWeight weight = FontWeight.w800,
    Color color = FC.text,
    double letterSpacing = -0.02 * 23,
    double? height,
  }) =>
      GoogleFonts.interTight(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = FC.text,
    double? letterSpacing,
    double height = 1.5,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color color = FC.text,
    double letterSpacing = 0,
    double? height,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// 11px, weight 600, wide tracking, UPPERCASE, muted.
  static TextStyle eyebrow({Color color = FC.textMuted}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.14 * 11,
        color: color,
      );
}

ThemeData buildFcTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: FC.bg,
    canvasColor: FC.bg,
    colorScheme: const ColorScheme.dark(
      surface: FC.surface,
      primary: FC.purple,
      secondary: FC.teal,
      error: FC.danger,
      onPrimary: Colors.white,
      onSurface: FC.text,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: FC.text,
      displayColor: FC.text,
    ),
    splashFactory: InkRipple.splashFactory,
    splashColor: FC.purpleTint,
    highlightColor: Colors.transparent,
    dividerColor: FC.border,
  );
}
