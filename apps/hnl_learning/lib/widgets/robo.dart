// Robo — the friendly monkey-scientist robot mascot.
// Rounded, chubby, lab goggles, waving. Ported from js/mascot.jsx.
// Poses: idle | wave | cheer | think | sleep. Auto-blinks 2–4s.
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

class Robo extends StatefulWidget {
  final double size;
  final String pose; // idle | wave | cheer | think | sleep
  const Robo({super.key, this.size = 220, this.pose = 'idle'});

  @override
  State<Robo> createState() => _RoboState();
}

class _RoboState extends State<Robo> with TickerProviderStateMixin {
  late final AnimationController _bob =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
  late final AnimationController _wave =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  bool _blink = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _scheduleBlink();
  }

  void _scheduleBlink() {
    final next = 2200 + math.Random().nextInt(2600);
    _blinkTimer = Timer(Duration(milliseconds: next), () {
      if (!mounted) return;
      setState(() => _blink = true);
      Timer(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() => _blink = false);
        _scheduleBlink();
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _bob.dispose();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    final pose = widget.pose;
    final cheering = pose == 'cheer';
    final moves = pose == 'idle' || pose == 'wave' || cheering;
    final wavePose = pose == 'wave' || cheering;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bob, _wave]),
        builder: (_, _) {
          final t = Curves.easeInOut.transform(_bob.value) * 2 - 1; // -1..1
          final bobY = moves ? (cheering ? -14.0 : -5.0) * ((t + 1) / 2) : 0.0;
          final waveSwing = (_wave.value * 2 - 1);
          double waveAngle = 0;
          if (wavePose) {
            waveAngle = (cheering ? 0.6 : 0.42) * waveSwing;
          } else if (pose == 'idle') {
            waveAngle = 0.12 * waveSwing;
          }
          return CustomPaint(
            painter: _RoboPainter(
              pose: pose,
              brand: pal.brand,
              brandDeep: pal.brandDeep,
              coral: pal.coral,
              galaxy: pal.galaxy,
              sun: C.sun,
              waveAngle: waveAngle,
              bobY: bobY,
              blink: _blink || pose == 'sleep',
            ),
          );
        },
      ),
    );
  }
}

class _RoboPainter extends CustomPainter {
  final String pose;
  final Color brand, brandDeep, coral, galaxy, sun;
  final double waveAngle, bobY;
  final bool blink;

  _RoboPainter({
    required this.pose,
    required this.brand,
    required this.brandDeep,
    required this.coral,
    required this.galaxy,
    required this.sun,
    required this.waveAngle,
    required this.bobY,
    required this.blink,
  });

  static const _headCream = Color(0xFFE7F3EC);
  static const _headLine = Color(0xFFCFE4D8);
  static const _ink = Color(0xFF2B3A43);
  static const _mouth = Color(0xFFC0552F);

  Paint _bodyShader(Rect r) => Paint()
    ..shader = RadialGradient(
      center: const Alignment(-0.24, -0.4),
      radius: 0.95,
      colors: [Colors.white.withValues(alpha: .55), brand, brandDeep],
      stops: const [0, .38, 1],
    ).createShader(r);

  Paint get _headShader => Paint()
    ..shader = const RadialGradient(
      center: Alignment(-0.24, -0.44),
      radius: 1.0,
      colors: [Color(0xFFFBFFF8), _headCream, _headLine],
      stops: [0, .6, 1],
    ).createShader(const Rect.fromLTWH(58, 36, 124, 108));

  Paint get _lensShader => Paint()
    ..shader = const RadialGradient(
      center: Alignment(-0.3, -0.4),
      radius: 0.9,
      colors: [Color(0xFFBFE9FF), Color(0xFF5BB8F5), Color(0xFF2C7BD6)],
      stops: [0, .55, 1],
    ).createShader(const Rect.fromLTWH(78, 62, 84, 44));

  Paint get _goggle => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFFFFD96B), sun],
    ).createShader(const Rect.fromLTWH(56, 74, 128, 16));

  RRect _rr(double x, double y, double w, double h, double r) =>
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 240;
    canvas.scale(s);

    // shadow (stays put while the body bobs)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 222), width: 124, height: 24),
      Paint()..color = _ink.withValues(alpha: .13),
    );

    canvas.translate(0, bobY);

    final deep = Paint()..color = brandDeep;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = brandDeep;

    // waving arm (behind body)
    canvas.save();
    canvas.translate(176, 150);
    canvas.rotate(waveAngle);
    canvas.translate(-176, -150);
    canvas.drawRRect(_rr(168, 96, 26, 64, 13), deep);
    canvas.drawCircle(const Offset(181, 92), 20, _bodyShader(const Rect.fromLTWH(161, 72, 40, 40)));
    canvas.drawCircle(const Offset(181, 92), 20, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = brandDeep);
    canvas.restore();

    // left arm
    canvas.drawRRect(_rr(46, 120, 26, 60, 13), deep);
    canvas.drawCircle(const Offset(59, 182), 19, _bodyShader(const Rect.fromLTWH(40, 163, 38, 38)));

    // body
    canvas.drawRRect(_rr(70, 118, 100, 92, 40), _bodyShader(const Rect.fromLTWH(70, 118, 100, 92)));
    canvas.drawRRect(_rr(70, 118, 100, 92, 40), stroke);

    // chest panel
    canvas.drawRRect(_rr(92, 140, 56, 46, 16), Paint()..color = Colors.white.withValues(alpha: .92));
    canvas.drawCircle(const Offset(110, 163), 6.5, Paint()..color = coral);
    canvas.drawCircle(const Offset(130, 163), 6.5, Paint()..color = galaxy);
    canvas.drawRRect(_rr(103, 174, 34, 6, 3), Paint()..color = C.line);

    // legs
    canvas.drawRRect(_rr(92, 202, 22, 22, 10), deep);
    canvas.drawRRect(_rr(126, 202, 22, 22, 10), deep);

    // monkey ears
    final earStroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = _headLine;
    for (final cx in [52.0, 188.0]) {
      canvas.drawCircle(Offset(cx, 74), 24, _headShader);
      canvas.drawCircle(Offset(cx, 74), 24, earStroke);
      canvas.drawCircle(Offset(cx, 74), 12, Paint()..color = const Color(0xFFE7CDB6));
    }

    // antenna
    canvas.drawLine(const Offset(120, 26), const Offset(120, 44),
        Paint()..color = brandDeep..strokeWidth = 5..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(120, 20), 9, Paint()..color = coral);

    // head
    canvas.drawRRect(_rr(58, 36, 124, 108, 52), _headShader);
    canvas.drawRRect(_rr(58, 36, 124, 108, 52),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..color = _headLine);

    // muzzle
    canvas.drawOval(Rect.fromCenter(center: const Offset(120, 110), width: 80, height: 60),
        Paint()..color = const Color(0xFFF6E7D6));

    // goggles strap
    canvas.drawRRect(_rr(56, 74, 128, 16, 8), _goggle..color = _goggle.color.withValues(alpha: .9));

    // goggle lenses (eyes)
    final lensRing = Paint()..style = PaintingStyle.stroke..strokeWidth = 6..shader = _goggle.shader;
    for (final cx in [100.0, 140.0]) {
      canvas.drawCircle(Offset(cx, 84), 22, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(cx, 84), 22, lensRing);
    }

    final think = pose == 'think';
    if (blink) {
      final lid = Paint()..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round..color = _ink;
      canvas.drawPath(Path()..moveTo(90, 84)..quadraticBezierTo(100, 91, 110, 84), lid);
      canvas.drawPath(Path()..moveTo(130, 84)..quadraticBezierTo(140, 91, 150, 84), lid);
    } else {
      final lx = think ? 106.0 : 100.0, rx = think ? 146.0 : 140.0;
      canvas.drawCircle(Offset(lx, 84), 11, _lensShader);
      canvas.drawCircle(Offset(rx, 84), 11, _lensShader);
      final hi = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(think ? 110 : 104, 80), 3.4, hi);
      canvas.drawCircle(Offset(think ? 150 : 144, 80), 3.4, hi);
    }

    // nose
    canvas.drawOval(Rect.fromCenter(center: const Offset(120, 106), width: 14, height: 10),
        Paint()..color = const Color(0xFFC89B76));

    // mouth
    final mouthPaint = Paint()..color = _mouth;
    if (pose == 'cheer') {
      final p = Path()
        ..moveTo(104, 118)
        ..quadraticBezierTo(120, 140, 136, 118)
        ..quadraticBezierTo(120, 128, 104, 118)
        ..close();
      canvas.drawPath(p, mouthPaint);
    } else if (think) {
      canvas.drawCircle(const Offset(120, 120), 5, mouthPaint);
    } else {
      canvas.drawPath(
        Path()..moveTo(106, 116)..quadraticBezierTo(120, 130, 134, 116),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round..color = _mouth,
      );
    }

    // cheeks
    final cheek = Paint()..color = coral.withValues(alpha: .28);
    canvas.drawCircle(const Offset(86, 112), 7, cheek);
    canvas.drawCircle(const Offset(154, 112), 7, cheek);
  }

  @override
  bool shouldRepaint(covariant _RoboPainter old) =>
      old.waveAngle != waveAngle || old.bobY != bobY || old.blink != blink || old.pose != pose || old.brand != brand;
}
