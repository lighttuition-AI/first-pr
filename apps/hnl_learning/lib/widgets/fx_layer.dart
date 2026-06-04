// Celebration FX — falling/rotating confetti, bursting stars, and a
// floating "+N" score pop. Listens to FxController (ported from the
// celebrate() engine in js/ui.jsx). "big" vs "gentle" intensity.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

class FxLayer extends StatelessWidget {
  const FxLayer({super.key});
  @override
  Widget build(BuildContext context) {
    final fx = context.watch<FxController>();
    final brand = context.watch<AppState>().pal.brand;
    return IgnorePointer(
      child: Stack(
        children: [
          for (final b in fx.bursts)
            Positioned.fill(
              key: ValueKey(b.id),
              child: _Burst(score: b.score, intensity: b.intensity, brand: brand),
            ),
        ],
      ),
    );
  }
}

class _Confetti {
  final double left, dur, delay, size, rot;
  final bool round;
  final Color color;
  _Confetti(this.left, this.dur, this.delay, this.size, this.rot, this.round, this.color);
}

class _Star {
  final double dx, dy, rot, size, delay;
  final Color color;
  _Star(this.dx, this.dy, this.rot, this.size, this.delay, this.color);
}

class _Burst extends StatefulWidget {
  final int? score;
  final String intensity;
  final Color brand;
  const _Burst({this.score, required this.intensity, required this.brand});
  @override
  State<_Burst> createState() => _BurstState();
}

class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
  late final List<_Confetti> _conf;
  late final List<_Star> _stars;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    final gentle = widget.intensity == 'gentle';
    final confN = gentle ? 26 : 70;
    final starN = gentle ? 8 : 20;
    _conf = List.generate(confN, (_) {
      return _Confetti(
        _rng.nextDouble(),
        1.6 + _rng.nextDouble() * 1.2,
        _rng.nextDouble() * .35,
        12 + _rng.nextDouble() * 16,
        _rng.nextDouble() * 2 * math.pi,
        _rng.nextBool(),
        C.confetti[_rng.nextInt(C.confetti.length)],
      );
    });
    _stars = List.generate(starN, (_) {
      return _Star(
        (_rng.nextDouble() * 2 - 1) * (gentle ? 220 : 420),
        -(120 + _rng.nextDouble() * (gentle ? 200 : 360)),
        (_rng.nextDouble() * 2 - 1) * 2 * math.pi,
        18 + _rng.nextDouble() * 26,
        _rng.nextDouble() * .25,
        C.confetti[_rng.nextInt(C.confetti.length)],
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        painter: _BurstPainter(_c.value, _conf, _stars, widget.score, widget.brand),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double t; // 0..1 over 2.6s
  final List<_Confetti> conf;
  final List<_Star> stars;
  final int? score;
  final Color brand;
  _BurstPainter(this.t, this.conf, this.stars, this.score, this.brand);

  static const _life = 2.6;

  @override
  void paint(Canvas canvas, Size size) {
    final elapsed = t * _life;

    // Confetti falling from the top
    for (final c in conf) {
      final local = ((elapsed - c.delay) / c.dur).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = (-0.08 + (1.12 + 0.08) * local) * size.height;
      final x = c.left * size.width + math.sin(local * 6 + c.rot) * 24;
      final op = local > 0.85 ? (1 - (local - 0.85) / 0.15) : 1.0;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.rot + local * 8);
      final paint = Paint()..color = c.color.withValues(alpha: op.clamp(0, 1));
      if (c.round) {
        canvas.drawCircle(Offset.zero, c.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size),
            const Radius.circular(3),
          ),
          paint,
        );
      }
      canvas.restore();
    }

    // Stars bursting from ~(50%, 44%)
    final anchor = Offset(size.width * 0.5, size.height * 0.44);
    for (final st in stars) {
      final local = ((elapsed - st.delay) / 1.0).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final e = Curves.easeOut.transform(local);
      final pos = anchor + Offset(st.dx * e, st.dy * e);
      final op = local > 0.6 ? (1 - (local - 0.6) / 0.4) : 1.0;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(st.rot * local);
      _drawStar(canvas, st.size / 2, st.color.withValues(alpha: op.clamp(0, 1)));
      canvas.restore();
    }

    // "+N" score burst
    if (score != null) {
      final local = t.clamp(0.0, 1.0);
      final scale = local < 0.2 ? (local / 0.2) * 1.2 : 1.2;
      final rise = local > 0.5 ? (local - 0.5) / 0.5 * 80 : 0.0;
      final op = (local > 0.5 ? (1 - (local - 0.5) / 0.5) : 1.0).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: '+$score',
          style: AppText.display(
              size: 80, weight: FontWeight.w800, color: brand.withValues(alpha: op)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(size.width / 2, size.height * 0.4 - rise);
      canvas.scale(scale);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double r, Color color) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = -math.pi / 2 + i * 2 * math.pi / 5;
      final inner = outer + math.pi / 5;
      final o = Offset(math.cos(outer) * r, math.sin(outer) * r);
      final inr = Offset(math.cos(inner) * r * 0.45, math.sin(inner) * r * 0.45);
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
      path.lineTo(inr.dx, inr.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}
