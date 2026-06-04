// The chunky, tactile "kid-safe" button. A solid color drop-shadow
// + soft ambient shadow; on press it translates down ~5px and the
// solid drop collapses (a satisfying squish). Mirrors `.btn` CSS.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

enum BtnVariant { brand, coral, ghost }

class KidButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool large;
  final bool small;
  final BtnVariant variant;
  final bool danger;

  const KidButton({
    super.key,
    required this.child,
    this.onTap,
    this.large = false,
    this.small = false,
    this.variant = BtnVariant.brand,
    this.danger = false,
  });

  @override
  State<KidButton> createState() => _KidButtonState();
}

class _KidButtonState extends State<KidButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    final enabled = widget.onTap != null;
    final ghost = widget.variant == BtnVariant.ghost;

    Color bg, deep, fg;
    switch (widget.variant) {
      case BtnVariant.brand:
        bg = pal.brand;
        deep = pal.brandDeep;
        fg = Colors.white;
      case BtnVariant.coral:
        bg = pal.coral;
        deep = pal.logicDeep;
        fg = Colors.white;
      case BtnVariant.ghost:
        bg = C.card;
        deep = C.line;
        fg = widget.danger ? const Color(0xFFE0573D) : C.ink;
    }

    final double minH = widget.large
        ? 92
        : widget.small
            ? 56
            : kTap;
    final double padH = widget.large ? 64 : (widget.small ? 24 : 40);
    final double fontSize = widget.large ? 36 : (widget.small ? 24 : 30);
    final double dropH = _down ? 2 : 7;

    final shadows = <BoxShadow>[
      if (!ghost) ...[
        BoxShadow(color: deep, offset: Offset(0, dropH)),
        BoxShadow(
          color: deep.withValues(alpha: .32),
          offset: Offset(0, _down ? 6 : 12),
          blurRadius: _down ? 12 : 22,
        ),
      ] else
        ...Sh.sm,
    ];

    Widget body = AnimatedContainer(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      constraints: BoxConstraints(minHeight: minH),
      padding: EdgeInsets.symmetric(horizontal: padH),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(R.pill),
        boxShadow: shadows,
        border: ghost ? Border.all(color: C.line, width: 3) : activeSkin.cardBorder,
      ),
      child: DefaultTextStyle(
        style: AppText.display(size: fontSize, weight: FontWeight.w700, color: fg),
        child: IconTheme(
          data: IconThemeData(color: fg, size: fontSize),
          child: Center(widthFactor: 1, child: widget.child),
        ),
      ),
    );

    if (!enabled) {
      body = Opacity(
        opacity: .55,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.5, 0.3, 0.2, 0, 0, //
            0.3, 0.5, 0.2, 0, 0, //
            0.2, 0.3, 0.5, 0, 0, //
            0, 0, 0, 1, 0,
          ]),
          child: body,
        ),
      );
    }

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: widget.onTap,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        offset: Offset(0, _down ? 0.06 : 0),
        child: body,
      ),
    );
  }
}

/// Round white icon button (back / close).
class IconCircle extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  const IconCircle(this.icon, {super.key, this.onTap, this.size = kTap});

  @override
  State<IconCircle> createState() => _IconCircleState();
}

class _IconCircleState extends State<IconCircle> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.92 : 1,
        duration: const Duration(milliseconds: 110),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: C.card,
            shape: BoxShape.circle,
            boxShadow: Sh.sm,
            border: activeSkin.cardBorder,
          ),
          child: Icon(widget.icon, color: C.ink, size: widget.size * 0.46),
        ),
      ),
    );
  }
}
