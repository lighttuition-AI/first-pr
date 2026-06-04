// ============================================================
// Comic burst — a spiky "POW!/ZAP!" star for the Crayon Pop look.
// Original art (no franchise) — a bold outlined starburst with a
// short word, in the neubrutalist comic spirit.
// ============================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ComicBurst extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  const ComicBurst({super.key, required this.text, required this.color, this.size = 90});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _BurstPainter(color),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(size * 0.20),
              child: FittedBox(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B2330),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _BurstPainter extends CustomPainter {
  final Color color;
  _BurstPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final outer = s.width / 2;
    final inner = outer * 0.66;
    const points = 12;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = math.pi * i / points - math.pi / 2;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1B2330)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width * 0.04
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.color != color;
}
