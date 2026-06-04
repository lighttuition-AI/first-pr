// ============================================================
// Somali Village — original hand-drawn art for the "Somali Village" skin.
// ------------------------------------------------------------
// All ORIGINAL shapes (not traced from any image): three cute little
// sisters with big eyes & dresses, an aqal Soomaali (dome hut), and a
// savanna acacia tree. Drawn with CustomPaint so they scale crisply.
// ============================================================
import 'package:flutter/material.dart';

// ------------------------------------------------------------
// A cute chibi "little sister": big eyes, smile, hoop earrings,
// a colourful dress, and one of a few hairstyles.
// ------------------------------------------------------------
class SomaliGirl extends StatelessWidget {
  final Color dress;
  final String hair; // 'afro' | 'puffs' | 'bun'
  final Color skinTone;
  final double size; // width; height is ~1.18×
  const SomaliGirl({
    super.key,
    required this.dress,
    this.hair = 'afro',
    this.skinTone = const Color(0xFFE3B083),
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size * 1.18,
        child: CustomPaint(painter: _GirlPainter(dress, hair, skinTone)),
      );
}

class _GirlPainter extends CustomPainter {
  final Color dress;
  final String hair;
  final Color skin;
  _GirlPainter(this.dress, this.hair, this.skin);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    double x(double f) => f * w;
    double y(double f) => f * h;
    Offset o(double fx, double fy) => Offset(x(fx), y(fy));

    const hairCol = Color(0xFF2B2320);
    final hairHi = Color.lerp(hairCol, Colors.white, .14)!;
    final skinShade = Color.lerp(skin, Colors.black, .12)!;
    final ink = const Color(0xFF2B2320);
    const gold = Color(0xFFF2C14E);
    final blush = const Color(0xFFE8867A).withValues(alpha: .5);
    final dressDeep = Color.lerp(dress, Colors.black, .18)!;

    final fill = Paint()..isAntiAlias = true;
    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // ---- Dress / body ----
    final body = Path()
      ..moveTo(x(.28), y(1.0))
      ..lineTo(x(.39), y(.72))
      ..lineTo(x(.61), y(.72))
      ..lineTo(x(.72), y(1.0))
      ..close();
    canvas.drawPath(body, fill..color = dress);
    // little collar
    canvas.drawPath(
      Path()
        ..moveTo(x(.42), y(.74))
        ..quadraticBezierTo(x(.5), y(.82), x(.58), y(.74)),
      Paint()
        ..color = dressDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round,
    );
    // neck
    canvas.drawRect(Rect.fromLTRB(x(.45), y(.64), x(.55), y(.76)), fill..color = skinShade);

    // ---- Hair (behind the face) ----
    void blob(double cx, double cy, double r, [Color? c]) =>
        canvas.drawCircle(o(cx, cy), r * w, fill..color = c ?? hairCol);
    switch (hair) {
      case 'puffs':
        blob(.27, .22, .19);
        blob(.73, .22, .19);
        blob(.5, .30, .26); // cap
      case 'bun':
        blob(.5, .12, .13);
        blob(.5, .32, .27);
      default: // afro — a cloud of curls
        for (final p in const [
          [.26, .30], [.30, .16], [.42, .10], [.5, .07], [.58, .10],
          [.70, .16], [.74, .30], [.30, .44], [.70, .44]
        ]) {
          blob(p[0], p[1], .13);
        }
        blob(.5, .28, .27);
    }

    // ---- Face ----
    canvas.drawCircle(o(.5, .42), .215 * w, fill..color = skin);
    // ears + gold hoop earrings
    canvas.drawCircle(o(.295, .44), .045 * w, fill..color = skin);
    canvas.drawCircle(o(.705, .44), .045 * w, fill..color = skin);
    final hoop = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;
    canvas.drawCircle(o(.295, .52), .035 * w, hoop);
    canvas.drawCircle(o(.705, .52), .035 * w, hoop);

    // a few front curls over the forehead (afro/puffs)
    if (hair != 'bun') {
      blob(.36, .26, .085, hairHi);
      blob(.5, .23, .09, hairHi);
      blob(.64, .26, .085, hairHi);
    }

    // ---- Face features (big cute eyes) ----
    void eye(double cx) {
      canvas.drawOval(Rect.fromCenter(center: o(cx, .42), width: .15 * w, height: .19 * w),
          fill..color = Colors.white);
      canvas.drawOval(Rect.fromCenter(center: o(cx, .42), width: .15 * w, height: .19 * w), line);
      canvas.drawCircle(o(cx, .44), .052 * w, fill..color = ink);
      canvas.drawCircle(o(cx + .018, .42), .018 * w, fill..color = Colors.white);
    }

    eye(.41);
    eye(.59);
    // brows
    canvas.drawPath(Path()..moveTo(x(.34), y(.33))..quadraticBezierTo(x(.41), y(.305), x(.48), y(.33)), line);
    canvas.drawPath(Path()..moveTo(x(.52), y(.33))..quadraticBezierTo(x(.59), y(.305), x(.66), y(.33)), line);
    // blush
    canvas.drawCircle(o(.35, .50), .035 * w, fill..color = blush);
    canvas.drawCircle(o(.65, .50), .035 * w, fill..color = blush);
    // nose
    canvas.drawCircle(o(.5, .49), .013 * w, fill..color = skinShade);
    // smile
    canvas.drawPath(
      Path()..moveTo(x(.43), y(.53))..quadraticBezierTo(x(.5), y(.60), x(.57), y(.53)),
      line..strokeWidth = w * 0.016,
    );
  }

  @override
  bool shouldRepaint(covariant _GirlPainter old) =>
      old.dress != dress || old.hair != hair || old.skin != skin;
}

// ------------------------------------------------------------
// Aqal Soomaali — a domed nomadic hut with woven bands + a doorway.
// ------------------------------------------------------------
class AqalHut extends StatelessWidget {
  final double size; // width; height ~0.85×
  const AqalHut({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size * 0.85,
        child: CustomPaint(painter: _HutPainter()),
      );
}

class _HutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    double x(double f) => f * w;
    double y(double f) => f * h;

    const straw = Color(0xFFCBA46A);
    const strawDeep = Color(0xFFB0894E);
    const red = Color(0xFFC4452F);
    const cream = Color(0xFFF2E4C4);
    const ink = Color(0xFF5A4427);

    // Dome silhouette (flat bottom, rounded top).
    final dome = Path()
      ..moveTo(x(.06), y(1.0))
      ..lineTo(x(.06), y(.52))
      ..cubicTo(x(.06), y(.04), x(.94), y(.04), x(.94), y(.52))
      ..lineTo(x(.94), y(1.0))
      ..close();
    canvas.drawPath(dome, Paint()..color = straw..isAntiAlias = true);

    // Woven bands — clip to the dome, draw a few coloured arcs.
    canvas.save();
    canvas.clipPath(dome);
    final bands = [strawDeep, red, cream, red, strawDeep];
    for (var i = 0; i < bands.length; i++) {
      final yy = .30 + i * 0.135;
      canvas.drawPath(
        Path()..moveTo(x(0), y(yy))..quadraticBezierTo(x(.5), y(yy - .06), x(1), y(yy)),
        Paint()
          ..color = bands[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = h * 0.055
          ..isAntiAlias = true,
      );
    }
    canvas.restore();

    // Outline.
    canvas.drawPath(
      dome,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..isAntiAlias = true,
    );

    // Doorway (arched opening with a little curtain).
    final door = Path()
      ..moveTo(x(.40), y(1.0))
      ..lineTo(x(.40), y(.72))
      ..cubicTo(x(.40), y(.55), x(.60), y(.55), x(.60), y(.72))
      ..lineTo(x(.60), y(1.0))
      ..close();
    canvas.drawPath(door, Paint()..color = ink..isAntiAlias = true);
    canvas.drawPath(
      Path()
        ..moveTo(x(.40), y(.72))
        ..lineTo(x(.50), y(.86))
        ..lineTo(x(.60), y(.72)),
      Paint()
        ..color = cream
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ------------------------------------------------------------
// Acacia — the flat-topped "umbrella" tree of the savanna.
// ------------------------------------------------------------
class AcaciaTree extends StatelessWidget {
  final double size; // width; height ~1.0×
  const AcaciaTree({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _AcaciaPainter()),
      );
}

class _AcaciaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    double x(double f) => f * w;
    double y(double f) => f * h;

    const trunk = Color(0xFF7A5232);
    const trunkDeep = Color(0xFF5E3E26);
    const leaf = Color(0xFF6FA844);
    const leafDeep = Color(0xFF4F8A33);

    // Trunk with a couple of upward branches.
    final t = Paint()
      ..color = trunk
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(Path()..moveTo(x(.5), y(1.0))..lineTo(x(.5), y(.5)), t);
    canvas.drawPath(Path()..moveTo(x(.5), y(.6))..lineTo(x(.28), y(.42)), t..strokeWidth = w * 0.04);
    canvas.drawPath(Path()..moveTo(x(.5), y(.58))..lineTo(x(.72), y(.42)), t);
    canvas.drawPath(Path()..moveTo(x(.5), y(.66))..lineTo(x(.5), y(.5)), Paint()
      ..color = trunkDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round);

    // Flat, wide umbrella canopy (two layers for depth).
    canvas.drawOval(
        Rect.fromCenter(center: o(w, h, .5, .40), width: w * 0.96, height: h * 0.30),
        Paint()..color = leafDeep..isAntiAlias = true);
    canvas.drawOval(
        Rect.fromCenter(center: o(w, h, .5, .35), width: w * 0.90, height: h * 0.24),
        Paint()..color = leaf..isAntiAlias = true);
    // a couple of lighter clumps on top
    canvas.drawOval(
        Rect.fromCenter(center: o(w, h, .36, .31), width: w * 0.34, height: h * 0.16),
        Paint()..color = Color.lerp(leaf, Colors.white, .12)!);
    canvas.drawOval(
        Rect.fromCenter(center: o(w, h, .64, .31), width: w * 0.34, height: h * 0.16),
        Paint()..color = Color.lerp(leaf, Colors.white, .12)!);
  }

  Offset o(double w, double h, double fx, double fy) => Offset(fx * w, fy * h);

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
