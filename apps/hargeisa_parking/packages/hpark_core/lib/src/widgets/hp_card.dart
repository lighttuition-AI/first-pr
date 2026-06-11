import 'package:flutter/material.dart';

import '../theme/hp_colors.dart';
import '../theme/hp_spacing.dart';

/// Primary surface — dark fill, 1px hairline border, 12px radius, no drop shadow.
/// When [onTap] is set the card lifts + gains a soft purple glow on hover/press.
class HpCard extends StatefulWidget {
  const HpCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(HpSpace.x5),
    this.onTap,
    this.radius = HpRadius.lg,
    this.color,
    this.borderColor,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final bool selected;

  @override
  State<HpCard> createState() => _HpCardState();
}

class _HpCardState extends State<HpCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final lifted = interactive && _hover;
    final border = widget.selected
        ? HpColors.borderFocus
        : (lifted ? HpColors.borderFocus : (widget.borderColor ?? HpColors.border));

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, lifted ? -2 : 0, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color ?? HpColors.surface,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: border, width: 1),
        boxShadow: (lifted || widget.selected)
            ? [
                BoxShadow(
                  color: HpColors.purple.withValues(alpha: 0.28),
                  blurRadius: 18,
                  spreadRadius: -6,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: widget.child,
    );

    if (!interactive) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(onTap: widget.onTap, child: content),
    );
  }
}
