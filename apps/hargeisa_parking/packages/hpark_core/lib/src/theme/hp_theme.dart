import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hp_colors.dart';
import 'hp_spacing.dart';

/// The single dark theme for the Hargeisa Parking ecosystem.
/// There is no light theme — the system is dark-first, always.
abstract final class HParkTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: HpColors.text,
      displayColor: HpColors.text,
    );

    const scheme = ColorScheme.dark(
      primary: HpColors.purple,
      onPrimary: HpColors.textOnAccent,
      secondary: HpColors.teal,
      onSecondary: HpColors.bg,
      surface: HpColors.surface,
      onSurface: HpColors.text,
      error: HpColors.danger,
      onError: HpColors.textOnAccent,
      outline: HpColors.border,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: HpColors.bg,
      canvasColor: HpColors.bg,
      textTheme: textTheme,
      primaryColor: HpColors.purple,
      dividerColor: HpColors.border,
      dividerTheme: const DividerThemeData(
        color: HpColors.border,
        thickness: 1,
        space: 1,
      ),
      splashColor: HpColors.purple.withValues(alpha: 0.12),
      highlightColor: HpColors.purple.withValues(alpha: 0.08),
      iconTheme: const IconThemeData(color: HpColors.text2, size: 20),
      appBarTheme: const AppBarTheme(
        backgroundColor: HpColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: HpColors.text),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.12)),
        radius: const Radius.circular(HpRadius.pill),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: HpColors.elevated,
          borderRadius: BorderRadius.circular(HpRadius.md),
          border: Border.all(color: HpColors.borderStrong),
        ),
        textStyle: const TextStyle(color: HpColors.text, fontSize: 12),
      ),
    );
  }

  /// Background gradient wash used on landing / auth surfaces
  /// (mirrors the launcher's radial purple + teal glow over the dark base).
  static const BoxDecoration backgroundWash = BoxDecoration(
    color: HpColors.bg,
    gradient: RadialGradient(
      center: Alignment(-0.7, -1.1),
      radius: 1.4,
      colors: [Color(0x247C6CF8), Color(0x00000000)],
      stops: [0.0, 0.65],
    ),
  );
}
