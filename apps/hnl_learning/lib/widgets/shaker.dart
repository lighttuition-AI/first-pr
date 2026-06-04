// Wrap a widget and call `.currentState?.shake()` (via a GlobalKey)
// to play the wrong-answer left-right shake (~0.5s).
import 'dart:math' as math;
import 'package:flutter/material.dart';

class Shaker extends StatefulWidget {
  final Widget child;
  const Shaker({super.key, required this.child});
  @override
  ShakerState createState() => ShakerState();
}

class ShakerState extends State<Shaker> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  void shake() => _c.forward(from: 0);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final v = _c.value;
        final dx = v == 0 ? 0.0 : math.sin(v * math.pi * 5) * 18 * (1 - v);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
