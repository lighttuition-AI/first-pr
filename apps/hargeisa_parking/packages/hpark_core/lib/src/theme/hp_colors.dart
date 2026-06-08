import 'package:flutter/material.dart';

/// Hargeisa Parking color tokens — dark-first civic-tech palette.
/// Ported from the design system `tokens/colors.css`. "Linear meets Stripe."
abstract final class HpColors {
  // ---- Brand ----
  static const purple = Color(0xFF7C6CF8); // Primary — Electric Purple
  static const purple600 = Color(0xFF6655F0); // Pressed / deeper
  static const purple300 = Color(0xFFA99EFB); // Light accent / links on dark
  static const teal = Color(0xFF00D8D6); // Secondary — Bright Teal
  static const teal600 = Color(0xFF00B6B4);

  // ---- Semantic status ----
  static const success = Color(0xFF00C853);
  static const warning = Color(0xFFFFB300);
  static const danger = Color(0xFFFF5252);
  static const info = teal;

  // ---- Surfaces (dark stack — depth via layering, not shadow) ----
  static const bg = Color(0xFF0A0A0F); // App background
  static const surface = Color(0xFF141420); // Card / surface
  static const elevated = Color(0xFF1B1B2B); // Elevated surface / popover
  static const overlay = Color(0xFF21212F); // Hover row / input fill

  // ---- Borders & lines (hairlines) ----
  static const border = Color(0x14FFFFFF); // white @ 0.08
  static const borderStrong = Color(0x24FFFFFF); // white @ 0.14
  static const borderFocus = Color(0x8C7C6CF8); // purple @ 0.55

  // ---- Text ----
  static const text = Color(0xFFFFFFFF);
  static const text2 = Color(0xFFA0A0B8);
  static const textMuted = Color(0xFF7A7A90);
  static const textOnAccent = Color(0xFFFFFFFF);

  // ---- Map markers (operations) ----
  static const mapPaid = Color(0xFF00C853); // green — paid parking
  static const mapExpiring = Color(0xFFFFB300); // yellow — expiring soon
  static const mapViolation = Color(0xFFFF5252); // red — violation
  static const mapOfficer = Color(0xFF3D9DF6); // blue — officer
  static const mapRoute = Color(0xFF7C6CF8); // purple — patrol route

  // ---- Tints (status badge fills, 12–16% on dark) ----
  static const purpleTint = Color(0x297C6CF8); // 0.16
  static const tealTint = Color(0x2400D8D6); // 0.14
  static const successTint = Color(0x2600C853); // 0.15
  static const warningTint = Color(0x26FFB300); // 0.15
  static const dangerTint = Color(0x26FF5252); // 0.15
  static const blueTint = Color(0x263D9DF6); // 0.15

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
