import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hp_colors.dart';
import 'hp_spacing.dart';

/// Themes for the Hargeisa Parking ecosystem. Dark-first by heritage, but now
/// with a matching light appearance — pick via [HpThemeController].
abstract final class HParkTheme {
  static ThemeData get dark => _build(HpPalette.dark, ThemeData.dark(useMaterial3: true));
  static ThemeData get light => _build(HpPalette.light, ThemeData.light(useMaterial3: true));

  static ThemeData _build(HpPalette p, ThemeData base) {
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: p.text,
      displayColor: p.text,
    );

    final scheme = (p.isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
      primary: HpColors.purple,
      onPrimary: HpColors.textOnAccent,
      secondary: HpColors.teal,
      onSecondary: p.isDark ? p.bg : HpColors.textOnAccent,
      surface: p.surface,
      onSurface: p.text,
      error: HpColors.danger,
      onError: HpColors.textOnAccent,
      outline: p.border,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      textTheme: textTheme,
      primaryColor: HpColors.purple,
      dividerColor: p.border,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      splashColor: HpColors.purple.withValues(alpha: 0.12),
      highlightColor: HpColors.purple.withValues(alpha: 0.08),
      iconTheme: IconThemeData(color: p.text2, size: 20),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: p.text),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(p.scrim),
        radius: const Radius.circular(HpRadius.pill),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.elevated,
          borderRadius: BorderRadius.circular(HpRadius.md),
          border: Border.all(color: p.borderStrong),
        ),
        textStyle: TextStyle(color: p.text, fontSize: 12),
      ),
    );
  }

  /// Background gradient wash used on landing / auth surfaces (a soft brand glow
  /// over the active base). Appearance-aware, so call it at build time.
  static BoxDecoration get backgroundWash => BoxDecoration(
        color: HpColors.bg,
        gradient: RadialGradient(
          center: const Alignment(-0.7, -1.1),
          radius: 1.4,
          colors: [
            HpColors.purple.withValues(alpha: HpColors.isDark ? 0.14 : 0.08),
            const Color(0x00000000),
          ],
          stops: const [0.0, 0.65],
        ),
      );
}

/// Drives the app-wide appearance. A single shared instance ([hpTheme]) flips
/// [HpColors.palette] and rebuilds the MaterialApp; the choice persists per
/// device via shared_preferences. Default is dark (the original look).
class HpThemeController extends ChangeNotifier {
  static const _key = 'hp_dark';

  bool _dark = true;
  bool get isDark => _dark;
  ThemeMode get mode => _dark ? ThemeMode.dark : ThemeMode.light;

  void _apply() => HpColors.palette = _dark ? HpPalette.dark : HpPalette.light;

  /// Read the saved choice on startup. Call before runApp().
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dark = prefs.getBool(_key) ?? true;
    } catch (_) {
      _dark = true;
    }
    _apply();
  }

  /// User picked an appearance — apply, rebuild, and persist.
  Future<void> setDark(bool dark) async {
    if (_dark == dark) return;
    _dark = dark;
    _apply();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, dark);
    } catch (_) {/* non-fatal */}
  }

  void toggle() => setDark(!_dark);
}

/// Shared app-wide theme controller instance.
final HpThemeController hpTheme = HpThemeController();
