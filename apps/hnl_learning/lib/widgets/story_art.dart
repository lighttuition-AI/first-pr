// ============================================================
// Story art — original, animated CustomPaint characters & scenes for the
// Somali Story Library. All hand-drawn (no franchise IP), App-Store-safe.
//
// Cast so far:
//  • LibaaxLion (Libaax) — golden mane + BIG teeth (so kids learn lions have
//    those teeth), animated bob + roar.
//  • DawacoFox (Dawaco) — bright orange fur + a big beautiful bushy tail that
//    sways, clever eyes that blink.
// StorySceneArt composes them (with a savanna, a pit, a log) per scene id.
// ============================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'village.dart' show AcaciaTree;

// ------------------------------------------------------------
// Libaax the lion
// ------------------------------------------------------------
class LibaaxLion extends StatefulWidget {
  final double size;
  final bool roaring;
  const LibaaxLion({super.key, this.size = 240, this.roaring = true});
  @override
  State<LibaaxLion> createState() => _LibaaxLionState();
}

class _LibaaxLionState extends State<LibaaxLion> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(painter: _LionPainter(_c.value, widget.roaring)),
        ),
      );
}

class _LionPainter extends CustomPainter {
  final double t; // 0..1 bob phase
  final bool roaring;
  _LionPainter(this.t, this.roaring);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final bob = math.sin(t * math.pi * 2) * h * 0.012;
    canvas.translate(0, bob);
    double x(double f) => f * w;
    double y(double f) => f * h;

    const fur = Color(0xFFF4B24C);
    const furDark = Color(0xFFE2922F);
    const mane = Color(0xFFD9772A);
    const maneDark = Color(0xFFB85A1C);
    const muzzle = Color(0xFFFFE6C2);

    final cx = x(0.5);
    // Paws / lower body
    final body = Paint()..color = fur;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, y(0.86)), width: w * 0.52, height: h * 0.30), body);
    for (final px in [0.40, 0.60]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x(px), y(0.95)), width: w * 0.18, height: h * 0.12), Paint()..color = furDark);
    }

    // Mane — a spiky golden ring behind the head
    final maneC = Offset(cx, y(0.44));
    final spike = Paint()..color = maneDark;
    for (var i = 0; i < 14; i++) {
      final a = i / 14 * math.pi * 2;
      final tip = maneC + Offset(math.cos(a), math.sin(a)) * w * 0.40;
      final b1 = maneC + Offset(math.cos(a + 0.22), math.sin(a + 0.22)) * w * 0.26;
      final b2 = maneC + Offset(math.cos(a - 0.22), math.sin(a - 0.22)) * w * 0.26;
      canvas.drawPath(Path()..moveTo(b1.dx, b1.dy)..lineTo(tip.dx, tip.dy)..lineTo(b2.dx, b2.dy)..close(), spike);
    }
    canvas.drawCircle(maneC, w * 0.30, Paint()..color = mane);

    // Face
    canvas.drawCircle(maneC, w * 0.225, body);
    // Ears
    for (final ex in [-1, 1]) {
      final e = maneC + Offset(ex * w * 0.17, -h * 0.17);
      canvas.drawCircle(e, w * 0.055, body);
      canvas.drawCircle(e, w * 0.03, Paint()..color = furDark);
    }
    // Muzzle
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, y(0.52)), width: w * 0.28, height: h * 0.20), Paint()..color = muzzle);

    // Eyes (+ fierce brows)
    final eyeW = Paint()..color = Colors.white;
    final pupil = Paint()..color = const Color(0xFF2A2118);
    for (final ex in [-1, 1]) {
      final e = Offset(cx + ex * w * 0.105, y(0.40));
      canvas.drawOval(Rect.fromCenter(center: e, width: w * 0.10, height: h * 0.12), eyeW);
      canvas.drawCircle(e.translate(0, h * 0.008), w * 0.032, pupil);
      // brow
      final brow = Paint()
        ..color = maneDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx + ex * w * 0.05, y(0.32)), Offset(cx + ex * w * 0.16, y(0.345)), brow);
    }
    // Nose
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * 0.035, y(0.475))
        ..lineTo(cx + w * 0.035, y(0.475))
        ..lineTo(cx, y(0.51))
        ..close(),
      pupil,
    );

    // Mouth + BIG teeth
    final mouthC = Offset(cx, y(0.585));
    if (roaring) {
      final mouth = Rect.fromCenter(center: mouthC, width: w * 0.22, height: h * 0.17);
      canvas.drawOval(mouth, Paint()..color = const Color(0xFF8E2F2F));
      canvas.drawOval(Rect.fromCenter(center: mouthC.translate(0, h * 0.03), width: w * 0.14, height: h * 0.07), Paint()..color = const Color(0xFFE06A6A));
      // top fangs + teeth
      final tooth = Paint()..color = Colors.white;
      void fang(double fx, double scale) {
        final tx = cx + fx;
        canvas.drawPath(
          Path()
            ..moveTo(tx - w * 0.03 * scale, y(0.515))
            ..lineTo(tx + w * 0.03 * scale, y(0.515))
            ..lineTo(tx, y(0.515) + h * 0.07 * scale)
            ..close(),
          tooth,
        );
      }
      fang(-w * 0.085, 1.25); // big left fang
      fang(w * 0.085, 1.25); // big right fang
      fang(-w * 0.03, 0.8);
      fang(w * 0.03, 0.8);
      // bottom two teeth
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: mouthC.translate(-w * 0.03, h * 0.055), width: w * 0.03, height: h * 0.04), Radius.circular(w * 0.01)), tooth);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: mouthC.translate(w * 0.03, h * 0.055), width: w * 0.03, height: h * 0.04), Radius.circular(w * 0.01)), tooth);
    } else {
      // gentle smile
      final smile = Paint()
        ..color = const Color(0xFF7A4A28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round;
      final p = Path()
        ..moveTo(cx - w * 0.07, y(0.55))
        ..quadraticBezierTo(cx, y(0.60), cx + w * 0.07, y(0.55));
      canvas.drawPath(p, smile);
    }
  }

  @override
  bool shouldRepaint(covariant _LionPainter old) => old.t != t || old.roaring != roaring;
}

// ------------------------------------------------------------
// Dawaco the fox
// ------------------------------------------------------------
class DawacoFox extends StatefulWidget {
  final double size;
  const DawacoFox({super.key, this.size = 220});
  @override
  State<DawacoFox> createState() => _DawacoFoxState();
}

class _DawacoFoxState extends State<DawacoFox> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(painter: _FoxPainter(_c.value)),
        ),
      );
}

class _FoxPainter extends CustomPainter {
  final double t;
  _FoxPainter(this.t);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final bob = math.sin(t * math.pi * 2) * h * 0.012;
    final sway = math.sin(t * math.pi * 2) * 0.18; // tail sway radians
    double x(double f) => f * w;
    double y(double f) => f * h;

    const fur = Color(0xFFF47B2A);
    const furDeep = Color(0xFFE05E12);
    const cream = Color(0xFFFFF2DE);
    const dark = Color(0xFF3A2A1E);

    // ---- BIG bushy tail (behind, sways) ----
    canvas.save();
    canvas.translate(x(0.30), y(0.70));
    canvas.rotate(sway);
    final tail = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-w * 0.30, -h * 0.10, -w * 0.34, h * 0.18)
      ..quadraticBezierTo(-w * 0.30, h * 0.40, -w * 0.05, h * 0.30)
      ..quadraticBezierTo(-w * 0.06, h * 0.12, 0, 0)
      ..close();
    canvas.drawPath(tail, Paint()..color = fur);
    // cream tail tip
    canvas.drawOval(Rect.fromCenter(center: Offset(-w * 0.30, h * 0.30), width: w * 0.16, height: h * 0.16), Paint()..color = cream);
    canvas.restore();

    canvas.translate(0, bob);
    final cx = x(0.54);

    // ---- Body ----
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, y(0.74)), width: w * 0.40, height: h * 0.40), Paint()..color = fur);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, y(0.84)), width: w * 0.24, height: h * 0.22), Paint()..color = cream);
    // front paws
    for (final px in [-1, 1]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + px * w * 0.10, y(0.93)), width: w * 0.11, height: h * 0.09), Paint()..color = furDeep);
    }

    // ---- Head ----
    final hc = Offset(cx, y(0.40));
    // Ears (big pointy)
    for (final ex in [-1, 1]) {
      final base = hc + Offset(ex * w * 0.15, -h * 0.10);
      final tip = hc + Offset(ex * w * 0.22, -h * 0.34);
      final inner = hc + Offset(ex * w * 0.07, -h * 0.10);
      canvas.drawPath(Path()..moveTo(base.dx, base.dy)..lineTo(tip.dx, tip.dy)..lineTo(inner.dx, inner.dy)..close(), Paint()..color = fur);
      canvas.drawPath(Path()..moveTo(base.dx, base.dy)..lineTo(tip.dx * 0.96 + inner.dx * 0.04, tip.dy * 0.96 + inner.dy * 0.04)..lineTo(inner.dx, inner.dy)..close(), Paint()..color = dark);
    }
    canvas.drawCircle(hc, w * 0.20, Paint()..color = fur);
    // cream cheeks/muzzle
    canvas.drawPath(
      Path()
        ..moveTo(hc.dx - w * 0.17, hc.dy)
        ..quadraticBezierTo(hc.dx, hc.dy + h * 0.05, hc.dx, hc.dy + h * 0.20)
        ..quadraticBezierTo(hc.dx, hc.dy + h * 0.05, hc.dx + w * 0.17, hc.dy)
        ..quadraticBezierTo(hc.dx, hc.dy + h * 0.14, hc.dx - w * 0.17, hc.dy)
        ..close(),
      Paint()..color = cream,
    );
    // nose
    canvas.drawCircle(Offset(hc.dx, hc.dy + h * 0.135), w * 0.028, Paint()..color = dark);
    // clever eyes (blink) + smile
    final open = (math.sin(t * math.pi * 2) > -0.85);
    final eyeP = Paint()..color = dark;
    for (final ex in [-1, 1]) {
      final e = Offset(hc.dx + ex * w * 0.085, hc.dy - h * 0.01);
      if (open) {
        canvas.drawOval(Rect.fromCenter(center: e, width: w * 0.05, height: h * 0.06), eyeP);
        canvas.drawCircle(e.translate(w * 0.012, -h * 0.012), w * 0.013, Paint()..color = Colors.white);
      } else {
        canvas.drawLine(e.translate(-w * 0.03, 0), e.translate(w * 0.03, 0), Paint()..color = dark..strokeWidth = w * 0.012..strokeCap = StrokeCap.round);
      }
    }
    final smile = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(hc.dx - w * 0.05, hc.dy + h * 0.15)
        ..quadraticBezierTo(hc.dx, hc.dy + h * 0.19, hc.dx + w * 0.05, hc.dy + h * 0.15),
      smile,
    );
  }

  @override
  bool shouldRepaint(covariant _FoxPainter old) => old.t != t;
}

// ------------------------------------------------------------
// A pit (hunter's hole) — a dark oval hole with a sandy rim.
// ------------------------------------------------------------
class _PitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    canvas.drawOval(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF6E4A24));
    canvas.drawOval(Rect.fromLTWH(w * 0.08, h * 0.16, w * 0.84, h * 0.78), Paint()..color = const Color(0xFF3A2614));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ------------------------------------------------------------
// Scene composition — picks characters/props by [art] id.
// ------------------------------------------------------------
class StorySceneArt extends StatelessWidget {
  final String art;
  const StorySceneArt({super.key, required this.art});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        final sun = Positioned(
          right: w * 0.06,
          top: h * 0.06,
          child: Container(
            width: w * 0.12,
            height: w * 0.12,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFE45C)),
          ),
        );
        final acacia = Positioned(left: w * 0.02, bottom: h * 0.16, child: AcaciaTree(size: w * 0.26));
        // Rolling ground hill
        final ground = Positioned(
          left: -w * 0.1,
          right: -w * 0.1,
          bottom: -h * 0.30,
          child: Container(
            height: h * 0.62,
            decoration: BoxDecoration(
              color: const Color(0xFFE7B569),
              borderRadius: BorderRadius.vertical(top: Radius.elliptical(w, h * 0.5)),
            ),
          ),
        );

        Widget pit({double scale = 1}) => Positioned(
              left: w * (0.5 - 0.22 * scale),
              bottom: h * 0.14,
              child: SizedBox(width: w * 0.44 * scale, height: h * 0.30 * scale, child: CustomPaint(painter: _PitPainter())),
            );

        final children = <Widget>[ground, sun];

        switch (art) {
          case 'lion-proud':
            children..add(acacia)..add(Positioned(bottom: h * 0.12, left: 0, right: 0, child: Center(child: LibaaxLion(size: h * 0.74))));
            break;
          case 'fox-appear':
            children
              ..add(Positioned(bottom: h * 0.16, right: w * 0.08, child: LibaaxLion(size: h * 0.46, roaring: false)))
              ..add(Positioned(bottom: h * 0.10, left: w * 0.10, child: DawacoFox(size: h * 0.66)));
            break;
          case 'lion-fall':
            children
              ..add(pit())
              ..add(Positioned(
                bottom: h * 0.34,
                left: w * 0.16,
                child: Transform.rotate(angle: 0.5, child: LibaaxLion(size: h * 0.5)),
              ));
            break;
          case 'lion-pit':
            // Lion down in the pit — only the top shows above the front rim.
            children
              ..add(Positioned(bottom: h * 0.02, left: 0, right: 0, child: Center(child: LibaaxLion(size: h * 0.56))))
              ..add(Positioned(
                left: w * 0.16,
                right: w * 0.16,
                bottom: 0,
                child: Container(
                  height: h * 0.30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6E4A24),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
                  ),
                ),
              ));
            break;
          case 'fox-log':
            children
              ..add(Positioned(bottom: h * 0.04, left: 0, right: 0, child: Center(child: LibaaxLion(size: h * 0.44, roaring: false))))
              ..add(Positioned(
                left: w * 0.16,
                right: w * 0.16,
                bottom: 0,
                child: Container(height: h * 0.26, decoration: const BoxDecoration(color: Color(0xFF6E4A24), borderRadius: BorderRadius.vertical(top: Radius.circular(80)))),
              ))
              // the log leaning into the pit
              ..add(Positioned(
                left: w * 0.30,
                bottom: h * 0.16,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    width: w * 0.42,
                    height: h * 0.10,
                    decoration: BoxDecoration(color: const Color(0xFF9B6A3C), borderRadius: BorderRadius.circular(40), border: Border.all(color: const Color(0xFF7A5230), width: 3)),
                  ),
                ),
              ))
              ..add(Positioned(bottom: h * 0.12, left: w * 0.04, child: DawacoFox(size: h * 0.56)));
            break;
          case 'friends':
            children
              ..add(acacia)
              ..add(Positioned(bottom: h * 0.12, left: w * 0.10, child: DawacoFox(size: h * 0.6)))
              ..add(Positioned(bottom: h * 0.12, right: w * 0.06, child: LibaaxLion(size: h * 0.66, roaring: false)));
            break;
          default:
            children.add(Positioned(bottom: h * 0.12, left: 0, right: 0, child: Center(child: LibaaxLion(size: h * 0.6))));
        }

        return Stack(clipBehavior: Clip.hardEdge, children: children);
      },
    );
  }
}
