// ============================================================
// Somali Village — original hand-drawn art for the "Somali Village" skin.
// ------------------------------------------------------------
// All ORIGINAL shapes (not traced from any image): three cute little
// sisters (round faces, big dreamy eyes, bridal/wedding-style gowns), an
// aqal Soomaali (dome hut), and a savanna acacia tree.
// ============================================================
import 'package:flutter/material.dart';

// ------------------------------------------------------------
// A cute chibi "little sister": round face, big dreamy eyes, a flower
// crown + soft veil, and a flowing wedding-style gown in [dress].
// ------------------------------------------------------------
class SomaliGirl extends StatelessWidget {
  final Color dress; // gown colour (gold / pink / purple…)
  final String hair; // 'afro' | 'puffs' | 'bun'
  final Color skinTone;
  final double size; // width; height is ~1.4×
  const SomaliGirl({
    super.key,
    required this.dress,
    this.hair = 'afro',
    this.skinTone = const Color(0xFFE8B98C),
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size * 1.4,
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
    final skinShade = Color.lerp(skin, Colors.black, .12)!;
    final gown = dress;
    final gownHi = Color.lerp(gown, Colors.white, .28)!;
    final gownDeep = Color.lerp(gown, Colors.black, .16)!;
    const ivory = Color(0xFFFBF7EF);
    final veilCol = Colors.white.withValues(alpha: .5);
    const gold = Color(0xFFF2C14E);
    final blush = const Color(0xFFEE8E8E).withValues(alpha: .55);
    const ink = Color(0xFF3A2A22);
    const iris = Color(0xFF4A3326);

    final f = Paint()..isAntiAlias = true;
    Paint sp(Color c, double sw) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    void blob(double cx, double cy, double r, [Color? c]) =>
        canvas.drawCircle(o(cx, cy), r * w, f..color = c ?? hairCol);

    // ---- Veil (bridal, behind everything) ----
    canvas.drawPath(
      Path()
        ..moveTo(x(.5), y(.05))
        ..quadraticBezierTo(x(.00), y(.34), x(.13), y(.95))
        ..lineTo(x(.87), y(.95))
        ..quadraticBezierTo(x(1.0), y(.34), x(.5), y(.05))
        ..close(),
      f..color = veilCol,
    );

    // ---- Gown (wedding-style A-line) ----
    canvas.drawPath(
      Path()
        ..moveTo(x(.40), y(.62))
        ..lineTo(x(.15), y(.99))
        ..lineTo(x(.85), y(.99))
        ..lineTo(x(.60), y(.62))
        ..close(),
      f..color = gown,
    );
    // side shading for depth
    canvas.drawPath(
      Path()
        ..moveTo(x(.40), y(.62))
        ..lineTo(x(.15), y(.99))
        ..lineTo(x(.37), y(.99))
        ..lineTo(x(.48), y(.62))
        ..close(),
      f..color = gownDeep.withValues(alpha: .30),
    );
    // bodice + puff sleeves
    canvas.drawPath(
      Path()
        ..moveTo(x(.41), y(.50))
        ..lineTo(x(.40), y(.63))
        ..lineTo(x(.60), y(.63))
        ..lineTo(x(.59), y(.50))
        ..close(),
      f..color = gown,
    );
    canvas.drawCircle(o(.36, .53), .078 * w, f..color = gownHi);
    canvas.drawCircle(o(.64, .53), .078 * w, f..color = gownHi);
    // lacy scalloped hem
    for (var i = 0; i < 7; i++) {
      canvas.drawCircle(Offset(x(.19 + i * .105), y(.965)), .052 * w, f..color = ivory);
    }
    // white waist sash + bow
    canvas.drawRect(Rect.fromLTRB(x(.39), y(.605), x(.61), y(.645)), f..color = ivory);
    canvas.drawCircle(o(.5, .625), .028 * w, f..color = gownHi);

    // ---- Neck ----
    canvas.drawRect(Rect.fromLTRB(x(.455), y(.45), x(.545), y(.55)), f..color = skinShade);

    // ---- Hair (behind the face) ----
    switch (hair) {
      case 'puffs':
        blob(.22, .16, .20);
        blob(.78, .16, .20);
        blob(.5, .23, .27);
      case 'bun':
        blob(.5, .045, .12);
        blob(.5, .24, .275);
      default: // afro cloud
        for (final p in const [
          [.23, .20], [.19, .33], [.30, .10], [.42, .05], [.5, .03],
          [.58, .05], [.70, .10], [.81, .33], [.77, .20]
        ]) {
          blob(p[0], p[1], .135);
        }
        blob(.5, .22, .27);
    }

    // ---- Face (big & round) ----
    canvas.drawCircle(o(.5, .30), .265 * w, f..color = skin);
    // ears + gold hoops
    canvas.drawCircle(o(.255, .32), .05 * w, f..color = skin);
    canvas.drawCircle(o(.745, .32), .05 * w, f..color = skin);
    canvas.drawCircle(o(.255, .40), .034 * w, sp(gold, .02 * w));
    canvas.drawCircle(o(.745, .40), .034 * w, sp(gold, .02 * w));

    // ---- Big dreamy eyes ----
    void eye(double cx, double dir) {
      final c = o(cx, .31);
      canvas.drawOval(Rect.fromCenter(center: c, width: .16 * w, height: .20 * w), f..color = Colors.white);
      canvas.drawOval(Rect.fromCenter(center: c, width: .16 * w, height: .20 * w), sp(ink, .009 * w));
      canvas.drawCircle(o(cx, .325), .082 * w, f..color = iris);
      canvas.drawCircle(o(cx, .335), .05 * w, f..color = ink);
      canvas.drawCircle(o(cx - .022, .285), .033 * w, f..color = Colors.white); // big sparkle
      canvas.drawCircle(o(cx + .03, .34), .015 * w, f..color = Colors.white); // small sparkle
      // a few lashes on the outer corner
      final l = sp(ink, .011 * w);
      canvas.drawPath(Path()..moveTo(x(cx + dir * .07), y(.275))..lineTo(x(cx + dir * .088), y(.258)), l);
      canvas.drawPath(Path()..moveTo(x(cx + dir * .082), y(.30))..lineTo(x(cx + dir * .104), y(.30)), l);
    }

    eye(.385, -1);
    eye(.615, 1);
    // soft brows
    canvas.drawPath(Path()..moveTo(x(.31), y(.205))..quadraticBezierTo(x(.385), y(.185), x(.46), y(.205)), sp(ink, .012 * w));
    canvas.drawPath(Path()..moveTo(x(.54), y(.205))..quadraticBezierTo(x(.615), y(.185), x(.69), y(.205)), sp(ink, .012 * w));
    // blush, nose, sweet smile
    canvas.drawCircle(o(.30, .40), .036 * w, f..color = blush);
    canvas.drawCircle(o(.70, .40), .036 * w, f..color = blush);
    canvas.drawCircle(o(.5, .40), .012 * w, f..color = skinShade);
    canvas.drawPath(Path()..moveTo(x(.43), y(.43))..quadraticBezierTo(x(.5), y(.49), x(.57), y(.43)), sp(ink, .016 * w));

    // ---- Flower crown (on top of the hair) ----
    void flower(double cx, double cy) {
      for (final p in const [[0, -1], [0, 1], [-1, 0], [1, 0]]) {
        canvas.drawCircle(Offset(x(cx) + p[0] * .026 * w, y(cy) + p[1] * .026 * w), .024 * w, f..color = ivory);
      }
      canvas.drawCircle(o(cx, cy), .022 * w, f..color = gold);
    }

    flower(.33, .135);
    flower(.5, .095);
    flower(.67, .135);
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

    final dome = Path()
      ..moveTo(x(.06), y(1.0))
      ..lineTo(x(.06), y(.52))
      ..cubicTo(x(.06), y(.04), x(.94), y(.04), x(.94), y(.52))
      ..lineTo(x(.94), y(1.0))
      ..close();
    canvas.drawPath(dome, Paint()..color = straw..isAntiAlias = true);

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

    canvas.drawPath(
      dome,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..isAntiAlias = true,
    );

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

    final t = Paint()
      ..color = trunk
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(Path()..moveTo(x(.5), y(1.0))..lineTo(x(.5), y(.5)), t);
    canvas.drawPath(Path()..moveTo(x(.5), y(.6))..lineTo(x(.28), y(.42)), t..strokeWidth = w * 0.04);
    canvas.drawPath(Path()..moveTo(x(.5), y(.58))..lineTo(x(.72), y(.42)), t);
    canvas.drawPath(
        Path()..moveTo(x(.5), y(.66))..lineTo(x(.5), y(.5)),
        Paint()
          ..color = trunkDeep
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.018
          ..strokeCap = StrokeCap.round);

    canvas.drawOval(
        Rect.fromCenter(center: Offset(x(.5), y(.40)), width: w * 0.96, height: h * 0.30),
        Paint()..color = leafDeep..isAntiAlias = true);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x(.5), y(.35)), width: w * 0.90, height: h * 0.24),
        Paint()..color = leaf..isAntiAlias = true);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x(.36), y(.31)), width: w * 0.34, height: h * 0.16),
        Paint()..color = Color.lerp(leaf, Colors.white, .12)!);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x(.64), y(.31)), width: w * 0.34, height: h * 0.16),
        Paint()..color = Color.lerp(leaf, Colors.white, .12)!);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
