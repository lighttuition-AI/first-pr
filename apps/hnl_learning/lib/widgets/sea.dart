// ============================================================
// Sea creatures — original, hand-drawn cartoon shark + bubble.
// ------------------------------------------------------------
// Used by the "Ocean" skin's animated scene. These are ORIGINAL
// shapes (not based on any copyrighted character) — a friendly
// shark family in the colours of the well-known shark song
// (yellow / pink / blue / green / orange). App-Store-safe.
// ============================================================
import 'package:flutter/material.dart';

/// A cute cartoon shark facing right (flip horizontally to face left).
class Shark extends StatelessWidget {
  final Color color;

  /// Logical width; height is ~0.62× this.
  final double size;
  const Shark({super.key, required this.color, this.size = 90});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size * 0.62,
        child: CustomPaint(painter: _SharkPainter(color)),
      );
}

class _SharkPainter extends CustomPainter {
  final Color color;
  _SharkPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    double x(double f) => f * w;
    double y(double f) => f * h;
    Offset o(double fx, double fy) => Offset(x(fx), y(fy));

    final finShade = Color.lerp(color, Colors.black, .16)!;
    final outline = Color.lerp(color, Colors.black, .30)!;
    final bellyShade = Color.lerp(color, Colors.white, .55)!;

    final body = Paint()..color = color..isAntiAlias = true;
    final fin = Paint()..color = finShade..isAntiAlias = true;
    final belly = Paint()..color = bellyShade..isAntiAlias = true;
    final line = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.016
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Body (nose at right, tail at left).
    final bodyPath = Path()
      ..moveTo(x(.95), y(.50))
      ..cubicTo(x(.93), y(.18), x(.70), y(.15), x(.50), y(.20))
      ..cubicTo(x(.34), y(.24), x(.24), y(.26), x(.16), y(.30))
      ..lineTo(x(.02), y(.05))
      ..lineTo(x(.13), y(.50))
      ..lineTo(x(.02), y(.95))
      ..lineTo(x(.18), y(.70))
      ..cubicTo(x(.32), y(.81), x(.60), y(.87), x(.78), y(.78))
      ..cubicTo(x(.88), y(.72), x(.93), y(.62), x(.95), y(.50))
      ..close();

    // Pectoral fin (behind body).
    final pectoral = Path()
      ..moveTo(x(.56), y(.74))
      ..lineTo(x(.49), y(.97))
      ..lineTo(x(.66), y(.76))
      ..close();

    // Dorsal fin (on top of body).
    final dorsal = Path()
      ..moveTo(x(.52), y(.19))
      ..lineTo(x(.45), y(.00))
      ..lineTo(x(.35), y(.22))
      ..close();

    // Belly highlight.
    final bellyPath = Path()
      ..moveTo(x(.30), y(.72))
      ..cubicTo(x(.45), y(.84), x(.66), y(.85), x(.80), y(.76))
      ..cubicTo(x(.72), y(.70), x(.45), y(.66), x(.30), y(.72))
      ..close();

    canvas.drawPath(pectoral, fin);
    canvas.drawPath(pectoral, line);
    canvas.drawPath(bodyPath, body);
    canvas.drawPath(bellyPath, belly);
    canvas.drawPath(bodyPath, line);
    canvas.drawPath(dorsal, fin);
    canvas.drawPath(dorsal, line);

    // Gills.
    final gill = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final gx = .70 + i * 0.05;
      canvas.drawPath(
        Path()..moveTo(x(gx), y(.36))..quadraticBezierTo(x(gx - .02), y(.50), x(gx), y(.62)),
        gill,
      );
    }

    // Eye + smile.
    canvas.drawCircle(o(.80, .42), w * .062, Paint()..color = Colors.white);
    canvas.drawCircle(o(.80, .42), w * .062, line);
    canvas.drawCircle(o(.815, .43), w * .030, Paint()..color = const Color(0xFF1B2A33));
    canvas.drawPath(
      Path()..moveTo(x(.84), y(.56))..quadraticBezierTo(x(.90), y(.63), x(.945), y(.53)),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _SharkPainter old) => old.color != color;
}

/// A soft translucent bubble.
class Bubble extends StatelessWidget {
  final double size;
  const Bubble({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .28),
          border: Border.all(color: Colors.white.withValues(alpha: .6), width: 1.4),
        ),
        // Tiny glossy highlight.
        child: Align(
          alignment: const Alignment(-0.35, -0.35),
          child: FractionallySizedBox(
            widthFactor: 0.28,
            heightFactor: 0.28,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .85),
              ),
            ),
          ),
        ),
      );
}
