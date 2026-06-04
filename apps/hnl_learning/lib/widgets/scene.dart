// ============================================================
// FloatingScene — ambient animated "characters" for a skin.
// ------------------------------------------------------------
// A skin can provide a scene of drifting sprites (emoji or any
// widget — e.g. painted sharks) that gently bob, sway, rotate, or
// swim across the stage. It sits behind the app's content and never
// catches taps (wrapped in IgnorePointer), so it's pure ambience.
// Motion is slow + low-amplitude on purpose: delightful, not noisy.
// ============================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// One animated character in a [FloatingScene].
class Sprite {
  /// What to draw (commonly an emoji `Text`, or a painted widget).
  final Widget child;

  /// Base position as a fraction of the stage (0..1, top-left origin).
  final double x, y;

  /// Vertical bob / horizontal sway amplitude in logical px.
  final double bob, sway;

  /// Rotation amplitude in radians (gentle wobble).
  final double rotate;

  /// Seconds for one full motion cycle, and a 0..1 phase offset so
  /// sprites don't all move in lock-step.
  final double period, phase;

  final double opacity;

  /// Horizontal drift in stage-fractions per second (signed). Non-zero
  /// makes the sprite "swim" across and wrap around (used for fish/sharks).
  final double drift;

  /// Flip horizontally to face the drift direction (right→left swimmers).
  final bool faceDrift;

  const Sprite({
    required this.child,
    required this.x,
    required this.y,
    this.bob = 12,
    this.sway = 0,
    this.rotate = 0,
    this.period = 6,
    this.phase = 0,
    this.opacity = 1,
    this.drift = 0,
    this.faceDrift = false,
  });
}

/// Convenience: an emoji sprite.
Sprite emojiSprite(
  String emoji, {
  required double size,
  required double x,
  required double y,
  double bob = 12,
  double sway = 0,
  double rotate = 0,
  double period = 6,
  double phase = 0,
  double opacity = 1,
  double drift = 0,
  bool faceDrift = false,
}) =>
    Sprite(
      child: Text(emoji, style: TextStyle(fontSize: size)),
      x: x,
      y: y,
      bob: bob,
      sway: sway,
      rotate: rotate,
      period: period,
      phase: phase,
      opacity: opacity,
      drift: drift,
      faceDrift: faceDrift,
    );

class FloatingScene extends StatefulWidget {
  final List<Sprite> sprites;

  /// Length of the master clock. Long so drift/wrap looks continuous.
  final Duration loop;
  const FloatingScene({super.key, required this.sprites, this.loop = const Duration(seconds: 90)});

  @override
  State<FloatingScene> createState() => _FloatingSceneState();
}

class _FloatingSceneState extends State<FloatingScene> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.loop)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loopSecs = widget.loop.inMilliseconds / 1000.0;
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth, h = box.maxHeight;
          return AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value * loopSecs; // elapsed seconds in the loop
              return Stack(
                clipBehavior: Clip.none,
                children: [for (final s in widget.sprites) _placed(s, t, w, h)],
              );
            },
          );
        },
      ),
    );
  }

  Widget _placed(Sprite s, double t, double w, double h) {
    final theta = 2 * math.pi * (t / s.period + s.phase);
    final dy = s.bob * math.sin(theta);
    final dx = s.sway * math.cos(theta);
    final rot = s.rotate * math.sin(theta);

    // Base horizontal position, with optional continuous drift + wrap. The
    // [-0.12, 1.12] band lets sprites glide on/off the edges smoothly.
    double xf = s.x;
    if (s.drift != 0) {
      xf = ((s.x + s.drift * t) % 1.24);
      if (xf < 0) xf += 1.24;
      xf -= 0.12;
    }
    final left = xf * w + dx;
    final top = s.y * h + dy;

    Widget child = s.child;
    if (s.faceDrift && s.drift < 0) {
      child = Transform.flip(flipX: true, child: child);
    }
    if (rot != 0) child = Transform.rotate(angle: rot, child: child);
    if (s.opacity < 1) child = Opacity(opacity: s.opacity, child: child);

    return Positioned(left: left, top: top, child: child);
  }
}
