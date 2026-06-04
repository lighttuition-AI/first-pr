// Planet collectible — drawn with CustomPaint (ported from the SVG
// Planet in js/ui.jsx). Optional continuous spin and faded/locked.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/image_service.dart';

class Planet extends StatefulWidget {
  final PlanetData data;
  final double size;
  final bool spin;
  final bool faded;
  const Planet({
    super.key,
    required this.data,
    this.size = 140,
    this.spin = false,
    this.faded = false,
  });

  @override
  State<Planet> createState() => _PlanetState();
}

class _PlanetState extends State<Planet> with SingleTickerProviderStateMixin {
  // Assigned in initState (not a lazy field initializer) so a non-spinning
  // planet still has a real controller to dispose — avoids creating a Ticker
  // during teardown, which touches a deactivated context.
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 9));
    if (widget.spin) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Uploaded custom planet picture takes over if present.
    final custom = context.watch<ImageService>().bytesFor('img-planet-${widget.data.id}');
    Widget art;
    if (custom != null) {
      art = ClipOval(
        child: Image.memory(custom, width: widget.size, height: widget.size, fit: BoxFit.cover),
      );
    } else {
      art = CustomPaint(
        size: Size.square(widget.size),
        painter: _PlanetPainter(widget.data),
      );
    }

    Widget result = Opacity(
      opacity: widget.faded ? .28 : 1,
      child: widget.faded
          ? ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0, //
                0.2126, 0.7152, 0.0722, 0, 0, //
                0.2126, 0.7152, 0.0722, 0, 0, //
                0, 0, 0, 1, 0,
              ]),
              child: art,
            )
          : art,
    );

    if (widget.spin && !widget.faded) {
      result = RotationTransition(turns: _c, child: result);
    }
    return SizedBox(width: widget.size, height: widget.size, child: result);
  }
}

class _PlanetPainter extends CustomPainter {
  final PlanetData d;
  _PlanetPainter(this.d);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.scale(s);
    const center = Offset(60, 60);
    const r = 40.0;

    // Ring (back) — a rotated full ellipse behind the body.
    if (d.ring && d.ringColor != null) {
      canvas.save();
      canvas.translate(60, 60);
      canvas.rotate(-18 * math.pi / 180);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = d.ringColor!.withValues(alpha: .9);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 112, height: 40), ringPaint);
      canvas.restore();
    }

    // Body
    final bodyRect = Rect.fromCircle(center: center, radius: r);
    final body = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.28, -0.36),
        radius: 0.95,
        colors: [Colors.white.withValues(alpha: .5), d.colorA, d.colorB],
        stops: const [0, .32, 1],
      ).createShader(bodyRect);
    canvas.drawCircle(center, r, body);

    // Surface dots (clipped to body)
    canvas.save();
    canvas.clipPath(Path()..addOval(bodyRect));
    final dots = Paint()..color = d.dots.withValues(alpha: .5);
    canvas.drawCircle(const Offset(44, 70), 9, dots);
    canvas.drawCircle(const Offset(74, 50), 6, dots);
    canvas.drawCircle(const Offset(66, 78), 5, dots);
    canvas.drawCircle(const Offset(50, 46), 4, dots);
    canvas.restore();

    // Specular highlight
    canvas.save();
    canvas.translate(48, 44);
    canvas.rotate(-24 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 24, height: 14),
      Paint()..color = Colors.white.withValues(alpha: .35),
    );
    canvas.restore();

    // Ring (front bottom arc)
    if (d.ring && d.ringColor != null) {
      canvas.save();
      canvas.translate(60, 60);
      canvas.rotate(-18 * math.pi / 180);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = d.ringColor!.withValues(alpha: .95);
      canvas.drawArc(
        Rect.fromCenter(center: Offset.zero, width: 112, height: 40),
        0, math.pi, false, ringPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter old) => old.d != d;
}
