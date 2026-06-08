import 'package:flutter/material.dart';

import '../theme/hp_colors.dart';
import '../theme/hp_spacing.dart';

enum HpButtonVariant { primary, secondary, danger, ghost }

enum HpButtonSize { sm, md, lg, xl }

/// Action control. Purple by default; gradient-fills with a glow on hover.
/// Use one primary per screen.
class HpButton extends StatefulWidget {
  const HpButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = HpButtonVariant.primary,
    this.size = HpButtonSize.md,
    this.icon,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final HpButtonVariant variant;
  final HpButtonSize size;
  final IconData? icon;
  final bool expand;
  final bool loading;

  @override
  State<HpButton> createState() => _HpButtonState();
}

class _HpButtonState extends State<HpButton> {
  bool _hover = false;
  bool _down = false;

  double get _height => switch (widget.size) {
        HpButtonSize.sm => HpSize.controlSm,
        HpButtonSize.md => HpSize.controlMd,
        HpButtonSize.lg => HpSize.controlLg,
        HpButtonSize.xl => HpSize.controlXl,
      };

  double get _fontSize => switch (widget.size) {
        HpButtonSize.sm => 13,
        HpButtonSize.md => 14,
        HpButtonSize.lg => 15,
        HpButtonSize.xl => 16,
      };

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final v = widget.variant;

    Color fg;
    Color bg;
    Gradient? gradient;
    Border? border;
    List<BoxShadow>? glow;

    switch (v) {
      case HpButtonVariant.primary:
        fg = HpColors.textOnAccent;
        bg = HpColors.purple;
        if (_hover && enabled) {
          gradient = HpColors.gradient;
          glow = [
            BoxShadow(
              color: HpColors.purple.withValues(alpha: 0.45),
              blurRadius: 24,
              spreadRadius: -6,
              offset: const Offset(0, 6),
            ),
          ];
        }
      case HpButtonVariant.secondary:
        fg = HpColors.text;
        bg = HpColors.overlay;
        border = Border.all(
          color: _hover && enabled ? HpColors.borderFocus : HpColors.borderStrong,
        );
      case HpButtonVariant.danger:
        fg = HpColors.textOnAccent;
        bg = HpColors.danger;
      case HpButtonVariant.ghost:
        fg = HpColors.text2;
        bg = _hover && enabled ? HpColors.overlay : Colors.transparent;
    }

    final child = widget.loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: _fontSize + 4, color: fg),
                const SizedBox(width: HpSpace.x2),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: fg,
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final btn = AnimatedScale(
      scale: _down && enabled ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: _height,
        padding: EdgeInsets.symmetric(
          horizontal: widget.size == HpButtonSize.sm ? HpSpace.x4 : HpSpace.x6,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gradient == null ? bg : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(HpRadius.md),
          border: border,
          boxShadow: glow,
        ),
        child: Opacity(opacity: enabled ? 1 : 0.45, child: child),
      ),
    );

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _down = false;
      }),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: widget.expand ? SizedBox(width: double.infinity, child: btn) : btn,
      ),
    );
  }
}
