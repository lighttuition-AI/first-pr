// Small shared widgets: counter chips, progress dots, kicker, press feedback.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

/// Wraps any tappable surface (islands, cards, chips) with a gentle press-in
/// scale — the tactile "it responded!" feedback young children rely on. Mirrors
/// the squish on [KidButton]/[IconCircle] for surfaces that aren't buttons.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  const Pressable({super.key, required this.child, this.onTap, this.pressedScale = 0.95});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  void _set(bool v) {
    if (widget.onTap != null && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class HnlChip extends StatelessWidget {
  final String icon;
  final String value;
  final VoidCallback? onTap;
  const HnlChip({super.key, required this.icon, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(R.pill),
        boxShadow: Sh.sm,
        border: activeSkin.cardBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          Text(value, style: AppText.display(size: 30, weight: FontWeight.w800)),
        ],
      ),
    );
    if (onTap == null) return chip;
    return Pressable(onTap: onTap, pressedScale: 0.92, child: chip);
  }
}

class ProgressDots extends StatelessWidget {
  final int total;
  final int index;
  const ProgressDots({super.key, required this.total, required this.index});

  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final now = i == index;
        final done = i < index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: now ? 22 : 14,
          height: now ? 22 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: now || done ? pal.brand : C.line,
            boxShadow: now
                ? [BoxShadow(color: pal.brand.withValues(alpha: .35), blurRadius: 12, spreadRadius: 2)]
                : null,
          ),
        );
      }),
    );
  }
}

class Kicker extends StatelessWidget {
  final String text;
  const Kicker(this.text, {super.key});
  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppText.kicker);
}
