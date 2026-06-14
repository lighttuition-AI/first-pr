// ============================================================
// Game icons — original, "app-store-style" icons for specific games.
// ------------------------------------------------------------
// A cohesive set: each is a soft squircle TILE (gradient + glossy top
// highlight + a soft colour-matched shadow) carrying an original motif.
// All ORIGINAL art (CustomPaint / composed widgets) — App-Store-safe.
//   • arabic-alphabet → a fan of colourful Arabic flashcards (ا ب ت)
//   • arabic-trace    → a paper card with a half-traced letter + pencil
//   • counting-basket → bright balls dropping into a woven basket
//   • shapes-pattern  → ● ▲ ● with a glowing "what comes next?" slot
// Arabic glyphs use the SYSTEM font (plain TextStyle, not google_fonts)
// so they render — same approach as the alphabet board.
// ============================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The bespoke leading icon for [gameId], or null to fall back to the emoji.
Widget? customGameIcon(String gameId, {double size = 52}) {
  switch (gameId) {
    case 'arabic-alphabet':
      return ArabicLettersIcon(size: size);
    case 'arabic-trace':
      return LetterTracingIcon(size: size);
    case 'arabic-order':
      return ArabicOrderIcon(size: size);
    case 'arabic-flip':
      return ArabicFlipIcon(size: size);
    case 'arabic-sounds':
      return ArabicSoundsIcon(size: size);
    case 'fruit-quiz':
      return ProduceIcon(emoji: '🍎', grad: const [Color(0xFFFF8166), Color(0xFFE8553D)], size: size);
    case 'veggie-quiz':
      return ProduceIcon(emoji: '🥕', grad: const [Color(0xFFFFB458), Color(0xFFF0822E)], size: size);
    case 'counting-basket':
      return CountDropIcon(size: size);
    case 'shapes-pattern':
      return PatternIcon(size: size);
    case 'logic-pick':
      return WhichOneIcon(size: size);
    case 'memory-match':
      return MemoryMatchIcon(size: size);
    case 'letters-match':
      return LetterSoundsIcon(size: size);
    case 'sorting-groups':
      return SortIcon(size: size);
    case 'science-fact':
      return ScienceIcon(size: size);
    // Logic Lab · 5 more "Which one?" games (share the WhichOne icon).
    case 'pick-odd':
    case 'pick-size':
    case 'pick-eat':
    case 'pick-home':
    case 'pick-match':
      return WhichOneIcon(size: size);
    // Logic Lab · 5 more "Sort it out" games (share the Sort icon).
    case 'sort-landwater':
    case 'sort-fruitveg':
    case 'sort-hotcold':
    case 'sort-daynight':
    case 'sort-bigsmall':
      return SortIcon(size: size);
    // Number Galaxy · 5 more "Count & drop" games (share the CountDrop icon).
    case 'count-fish':
    case 'count-stars':
    case 'count-treats':
    case 'count-flowers':
    case 'count-fruit':
      return CountDropIcon(size: size);
    // Number Galaxy · 5 more "Finish the pattern" games (share the Pattern icon).
    case 'pattern-colour':
    case 'pattern-sky':
    case 'pattern-shape':
    case 'pattern-fruit':
    case 'pattern-twoone':
      return PatternIcon(size: size);
    // Discovery World · the 10 themed Flip & Match games — a themed glyph on a
    // colour tile so each is recognisable at a glance.
    case 'mem-arabic':
      return ProduceIcon(emoji: 'أ', grad: const [Color(0xFF5C7CFA), Color(0xFF3F5FD8)], size: size);
    case 'mem-animals':
      return ProduceIcon(emoji: '🦁', grad: const [Color(0xFF9BE15D), Color(0xFF5FB836)], size: size);
    case 'mem-sea':
      return ProduceIcon(emoji: '🐠', grad: const [Color(0xFF39C7DE), Color(0xFF1E9FC4)], size: size);
    case 'mem-fruits':
      return ProduceIcon(emoji: '🍓', grad: const [Color(0xFFFF8FA3), Color(0xFFFF6B9D)], size: size);
    case 'mem-veggies':
      return ProduceIcon(emoji: '🥕', grad: const [Color(0xFFFFB458), Color(0xFFF0822E)], size: size);
    case 'mem-numbers':
      return ProduceIcon(emoji: '🔢', grad: const [Color(0xFFB07EE8), Color(0xFF7C5BD0)], size: size);
    case 'mem-shapes':
      return ProduceIcon(emoji: '🔷', grad: const [Color(0xFF2ED3A3), Color(0xFF0E9E73)], size: size);
    case 'mem-vehicles':
      return ProduceIcon(emoji: '🚗', grad: const [Color(0xFFFF7A59), Color(0xFFE85D3D)], size: size);
    case 'mem-food':
      return ProduceIcon(emoji: '🍕', grad: const [Color(0xFFFFD23F), Color(0xFFFFB01F)], size: size);
    case 'mem-weather':
      return ProduceIcon(emoji: '🌈', grad: const [Color(0xFF39C7DE), Color(0xFF1E9FC4)], size: size);
  }
  return null;
}

/// A small bespoke trailing accent for [gameId] (replaces stray emoji), or null.
Widget? customGameTrailing(String gameId, {double size = 34}) {
  switch (gameId) {
    case 'arabic-alphabet': // a "tap to hear" speaker
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _SoundPainter(const Color(0xFF3A57A8))),
      );
    case 'arabic-trace': // a little pencil
      return Transform.rotate(angle: -0.5, child: _Pencil(size: size * 1.05));
  }
  return null;
}

// ------------------------------------------------------------
// Shared squircle tile: gradient fill, glossy top highlight, soft shadow.
// ------------------------------------------------------------
class IconTile extends StatelessWidget {
  final double size;
  final List<Color> grad;
  final Widget child;
  const IconTile({super.key, required this.size, required this.grad, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: grad,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .22), width: size * .02),
        boxShadow: [
          BoxShadow(
            color: grad.last.withValues(alpha: .42),
            blurRadius: size * .22,
            offset: Offset(0, size * .12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // glossy top sheen
          Positioned(
            left: size * .12,
            right: size * .12,
            top: size * .07,
            height: size * .32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * .22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: .34), Colors.white.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Arabic Letters — a fan of colourful flashcards (ا ب ت).
// ------------------------------------------------------------
class ArabicLettersIcon extends StatelessWidget {
  final double size;
  const ArabicLettersIcon({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFF4A63B8), Color(0xFF21386E)], // indigo → board navy
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              _card('ت', const Color(0xFF2E9CB8), angle: -0.34, dx: -size * .21, dy: size * .035),
              _card('ا', const Color(0xFFE8553D), angle: 0.34, dx: size * .21, dy: size * .035),
              _card('ب', const Color(0xFFF2A93B), angle: 0, dx: 0, dy: -size * .03),
            ],
          ),
        ),
      );

  Widget _card(String glyph, Color c, {required double angle, required double dx, required double dy}) {
    final w = size * .40, h = size * .55;
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * .10),
            border: Border.all(color: c, width: size * .045),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: size * .06, offset: Offset(0, size * .03)),
            ],
          ),
          alignment: Alignment.center,
          // System font so the Arabic glyph renders (not google_fonts).
          child: Text(
            glyph,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: size * .30, fontWeight: FontWeight.w800, color: c, height: 1.0),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Letter Tracing — a paper card with a half-traced letter + pencil.
// ------------------------------------------------------------
class LetterTracingIcon extends StatelessWidget {
  final double size;
  const LetterTracingIcon({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFFFFD16B), Color(0xFFFF8E5E)], // warm amber → coral
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // paper
              Container(
                width: size * .60,
                height: size * .60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * .14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: size * .06, offset: Offset(0, size * .03)),
                  ],
                ),
              ),
              // faint guide glyph
              Text('ب',
                  style: TextStyle(
                      fontSize: size * .40, fontWeight: FontWeight.w800, color: const Color(0xFFFF8E5E).withValues(alpha: .28))),
              // the traced part — vivid, fading out (left = already traced)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFEF5B2B), Color(0xFFEF5B2B), Colors.transparent],
                  stops: [0, .5, .82],
                ).createShader(rect),
                child: Text('ب', style: TextStyle(fontSize: size * .40, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              // pencil
              Positioned(
                right: size * .02,
                bottom: size * .04,
                child: Transform.rotate(angle: -0.7, child: _Pencil(size: size * .52)),
              ),
            ],
          ),
        ),
      );
}

// ------------------------------------------------------------
// Letter Order — ordered boxes (ا ب …) with a letter dropping into the slot.
// ------------------------------------------------------------
class ArabicOrderIcon extends StatelessWidget {
  final double size;
  const ArabicOrderIcon({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFF5AC8A8), Color(0xFF2E9C8A)], // mint → teal
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // three boxes along the bottom: two filled in order, one empty
              Positioned(
                bottom: size * .15,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _box('ا', filled: true),
                    SizedBox(width: size * .055),
                    _box('ب', filled: true),
                    SizedBox(width: size * .055),
                    _box(null, filled: false),
                  ],
                ),
              ),
              // a letter dropping into the empty (right-most) box
              Positioned(
                top: size * .07,
                right: size * .14,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _tile('ت'),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: .92), size: size * .22),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _box(String? glyph, {required bool filled}) {
    final w = size * .22;
    return Container(
      width: w,
      height: w * 1.18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? Colors.white : Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(size * .055),
        border: filled ? null : Border.all(color: Colors.white.withValues(alpha: .85), width: size * .017),
      ),
      child: glyph == null
          ? null
          : Text(glyph,
              style: TextStyle(
                  fontSize: size * .16, fontWeight: FontWeight.w800, color: const Color(0xFF2E9C8A), height: 1.0)),
    );
  }

  Widget _tile(String glyph) {
    final w = size * .24;
    return Container(
      width: w,
      height: w * 1.12,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD23F),
        borderRadius: BorderRadius.circular(size * .055),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: size * .05, offset: Offset(0, size * .025)),
        ],
      ),
      child: Text(glyph,
          style: TextStyle(fontSize: size * .16, fontWeight: FontWeight.w900, color: const Color(0xFF7A4E00), height: 1.0)),
    );
  }
}

// ------------------------------------------------------------
// Flip the Letters — a face-down card (mirrored glyph + flip arrows) beside a
// card flipped open to a bright, correct letter.
// ------------------------------------------------------------
class ArabicFlipIcon extends StatelessWidget {
  final double size;
  const ArabicFlipIcon({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFFF36CA8), Color(0xFFC23B86)], // pink → magenta
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // face-down card — the letter "turned around" (mirrored, dim)
              Transform.translate(
                offset: Offset(-size * .15, size * .02),
                child: Transform.rotate(
                  angle: -0.20,
                  child: _card(
                    const Color(0xFF8E2C66),
                    child: Transform.flip(
                      flipX: true,
                      child: Text('ب',
                          style: TextStyle(
                              fontSize: size * .26,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                              color: Colors.white.withValues(alpha: .40))),
                    ),
                  ),
                ),
              ),
              // revealed card — the correct, upright letter
              Transform.translate(
                offset: Offset(size * .15, -size * .02),
                child: Transform.rotate(
                  angle: 0.18,
                  child: _card(
                    Colors.white,
                    child: Text('ا',
                        style: TextStyle(
                            fontSize: size * .30, fontWeight: FontWeight.w900, height: 1.0, color: const Color(0xFFC23B86))),
                  ),
                ),
              ),
              // little flip-arrows hint
              Positioned(
                bottom: size * .04,
                child: Icon(Icons.cached_rounded, size: size * .22, color: Colors.white.withValues(alpha: .95)),
              ),
            ],
          ),
        ),
      );

  Widget _card(Color c, {required Widget child}) => Container(
        width: size * .40,
        height: size * .54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(size * .10),
          border: Border.all(color: Colors.white.withValues(alpha: .92), width: size * .03),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .22), blurRadius: size * .06, offset: Offset(0, size * .03)),
          ],
        ),
        child: child,
      );
}

// ------------------------------------------------------------
// Letter Sounds — a card of three vowelled letters (بَ بِ بُ) with sound waves.
// ------------------------------------------------------------
class ArabicSoundsIcon extends StatelessWidget {
  final double size;
  const ArabicSoundsIcon({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFF5BB8E8), Color(0xFF2E73C4)], // sky → blue
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // white card holding the three short-vowel forms
              Container(
                width: size * .64,
                height: size * .56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * .14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: size * .06, offset: Offset(0, size * .03)),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: size * .04),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final g in const ['بَ', 'بِ', 'بُ'])
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: size * .012),
                            child: Text(g,
                                style: TextStyle(
                                    fontSize: size * .21,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                    color: const Color(0xFF2E73C4))),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // sound waves off the top-right corner
              Positioned(
                top: size * .05,
                right: size * .04,
                child: SizedBox(
                  width: size * .26,
                  height: size * .26,
                  child: CustomPaint(painter: _SoundPainter(Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
}

// ------------------------------------------------------------
// Fruits / Veggies — a big bright emoji on a glossy colour tile (pops!).
// ------------------------------------------------------------
class ProduceIcon extends StatelessWidget {
  final String emoji;
  final List<Color> grad;
  final double size;
  const ProduceIcon({super.key, required this.emoji, required this.grad, this.size = 52});

  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: grad,
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * .52, height: 1.0),
        ),
      );
}

// ------------------------------------------------------------
// Count & drop — bright balls dropping into a woven basket.
// ------------------------------------------------------------
class CountDropIcon extends StatelessWidget {
  final double size;
  const CountDropIcon({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFF63C5E8), Color(0xFF2E86C1)], // sky → ocean blue
        child: SizedBox(
          width: size * .82,
          height: size * .82,
          child: CustomPaint(painter: _CountPainter()),
        ),
      );
}

class _CountPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final b = s.width;
    double x(double f) => f * b;
    double y(double f) => f * b;
    final p = Paint()..isAntiAlias = true;

    void ball(double cx, double cy, double r, Color col) {
      canvas.drawCircle(Offset(x(cx), y(cy)), r * b, p..color = Colors.black.withValues(alpha: .12));
      canvas.drawCircle(Offset(x(cx), y(cy)), r * b, p..color = col);
      canvas.drawCircle(Offset(x(cx - r * .32), y(cy - r * .34)), r * b * .34, p..color = Colors.white.withValues(alpha: .65));
    }

    // motion streaks above the falling balls
    final streak = Paint()
      ..color = Colors.white.withValues(alpha: .55)
      ..strokeWidth = b * .025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x(.30), y(.04)), Offset(x(.30), y(.14)), streak);
    canvas.drawLine(Offset(x(.70), y(.00)), Offset(x(.70), y(.10)), streak);

    // three colourful balls dropping in
    ball(.70, .19, .115, const Color(0xFF7ED957)); // green (high)
    ball(.30, .28, .12, const Color(0xFFF2C14E)); // amber (mid)
    ball(.50, .46, .13, const Color(0xFFE8553D)); // red (entering)

    // ---- woven basket ----
    const cream = Color(0xFFF6E4C0);
    const weave = Color(0xFFCBA063);
    const rim = Color(0xFFE2C290);
    final cup = Path()
      ..moveTo(x(.18), y(.62))
      ..lineTo(x(.30), y(.92))
      ..quadraticBezierTo(x(.50), y(.99), x(.70), y(.92))
      ..lineTo(x(.82), y(.62))
      ..close();
    canvas.drawPath(cup, p..color = cream);
    // weave lines
    final wl = Paint()
      ..color = weave
      ..style = PaintingStyle.stroke
      ..strokeWidth = b * .03
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.save();
    canvas.clipPath(cup);
    for (final f in const [.36, .50, .64]) {
      canvas.drawLine(Offset(x(f), y(.62)), Offset(x(f), y(.96)), wl);
    }
    canvas.drawLine(Offset(x(.20), y(.75)), Offset(x(.80), y(.75)), wl);
    canvas.restore();
    // rim opening
    canvas.drawOval(Rect.fromCenter(center: Offset(x(.50), y(.62)), width: x(.64), height: y(.16)), p..color = rim);
    canvas.drawOval(Rect.fromCenter(center: Offset(x(.50), y(.625)), width: x(.54), height: y(.115)), p..color = const Color(0xFFB98A4E));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ------------------------------------------------------------
// Finish the pattern — ● ▲ ● and a glowing "next" slot.
// ------------------------------------------------------------
class PatternIcon extends StatelessWidget {
  final double size;
  const PatternIcon({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFF9B8CF2), Color(0xFF6A5AE0)], // violet → indigo
        child: SizedBox(
          width: size * .84,
          height: size * .84,
          child: CustomPaint(painter: _PatternPainter()),
        ),
      );
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final b = s.width;
    double x(double f) => f * b;
    double y(double f) => f * b;
    final p = Paint()..isAntiAlias = true;
    const cy = .5;
    final xs = const [.15, .385, .62, .855];
    final r = b * .105;

    void shadow(double cx) =>
        canvas.drawCircle(Offset(x(cx), y(cy) + b * .03), r, p..color = Colors.black.withValues(alpha: .12));

    // ● circle
    shadow(xs[0]);
    canvas.drawCircle(Offset(x(xs[0]), y(cy)), r, p..color = Colors.white);
    // ▲ triangle (yellow)
    shadow(xs[1]);
    final tcx = x(xs[1]), tcy = y(cy);
    canvas.drawPath(
      Path()
        ..moveTo(tcx, tcy - r * 1.05)
        ..lineTo(tcx + r * 1.05, tcy + r * .85)
        ..lineTo(tcx - r * 1.05, tcy + r * .85)
        ..close(),
      p..color = const Color(0xFFFFD23F),
    );
    // ● circle
    shadow(xs[2]);
    canvas.drawCircle(Offset(x(xs[2]), y(cy)), r, p..color = Colors.white);

    // ⬚ glowing "next" slot — dashed rounded square + sparkle
    final slot = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x(xs[3]), y(cy)), width: r * 2.1, height: r * 2.1),
      Radius.circular(r * .5),
    );
    canvas.drawRRect(slot, p..color = Colors.white.withValues(alpha: .14));
    final dash = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = b * .028
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    _dashedRRect(canvas, slot, dash, dash: b * .07, gap: b * .05);
    _sparkle(canvas, Offset(x(xs[3]), y(cy)), r * .62, Colors.white);
  }

  void _dashedRRect(Canvas canvas, RRect rr, Paint paint, {required double dash, required double gap}) {
    final path = Path()..addRRect(rr);
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + dash, m.length)), paint);
        d += dash + gap;
      }
    }
  }

  void _sparkle(Canvas canvas, Offset c, double r, Color col) {
    final p = Paint()
      ..color = col
      ..strokeWidth = r * .26
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), p);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ------------------------------------------------------------
// Which one? — a magnifying glass finding the right answer.
// ------------------------------------------------------------
class WhichOneIcon extends StatelessWidget {
  final double size;
  const WhichOneIcon({super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFFFF8A66), Color(0xFFE8553D)], // warm red
        child: SizedBox(width: size * .82, height: size * .82, child: CustomPaint(painter: _PickPainter())),
      );
}

class _PickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final b = s.width;
    Offset o(double fx, double fy) => Offset(fx * b, fy * b);
    final p = Paint()..isAntiAlias = true;
    // faint option dots behind
    p.color = Colors.white.withValues(alpha: .26);
    canvas.drawCircle(o(.26, .22), b * .085, p);
    canvas.drawCircle(o(.52, .14), b * .07, p);
    canvas.drawCircle(o(.78, .25), b * .06, p);
    // magnifier handle
    canvas.drawLine(
      o(.62, .62),
      o(.88, .88),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = b * .13
        ..strokeCap = StrokeCap.round,
    );
    // lens
    canvas.drawCircle(o(.44, .47), b * .30, p..color = Colors.white);
    canvas.drawCircle(o(.44, .47), b * .22, p..color = const Color(0xFFFDE9E3));
    // green tick inside the lens — "this one!"
    canvas.drawPath(
      Path()..moveTo(.32 * b, .48 * b)..lineTo(.41 * b, .57 * b)..lineTo(.57 * b, .37 * b),
      Paint()
        ..color = const Color(0xFF15B886)
        ..style = PaintingStyle.stroke
        ..strokeWidth = b * .075
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ------------------------------------------------------------
// Flip & match — a face-down card + a revealed match.
// ------------------------------------------------------------
class MemoryMatchIcon extends StatelessWidget {
  final double size;
  const MemoryMatchIcon({super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFF7BC86C), Color(0xFF3F9A4B)], // green
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // face-down card
              Transform.translate(
                offset: Offset(-size * .14, size * .02),
                child: Transform.rotate(
                  angle: -0.18,
                  child: _miniCard(
                    size,
                    const Color(0xFF3E5C9A),
                    child: Transform.rotate(
                      angle: 0.785,
                      child: Container(
                        width: size * .12,
                        height: size * .12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .85),
                          borderRadius: BorderRadius.circular(size * .02),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // revealed match
              Transform.translate(
                offset: Offset(size * .14, -size * .02),
                child: Transform.rotate(
                  angle: 0.18,
                  child: _miniCard(size, Colors.white,
                      child: Icon(Icons.star_rounded, size: size * .26, color: const Color(0xFFF2A93B))),
                ),
              ),
            ],
          ),
        ),
      );

  static Widget _miniCard(double s, Color c, {required Widget child}) => Container(
        width: s * .40,
        height: s * .54,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(s * .10),
          border: Border.all(color: Colors.white.withValues(alpha: .92), width: s * .03),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .22), blurRadius: s * .06, offset: Offset(0, s * .03)),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      );
}

// ------------------------------------------------------------
// Letter sounds — bright ABC alphabet blocks.
// ------------------------------------------------------------
class LetterSoundsIcon extends StatelessWidget {
  final double size;
  const LetterSoundsIcon({super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFF56C2C8), Color(0xFF2E9CA0)], // teal
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _block(size, 'C', const Color(0xFFF368A0), dx: 0, dy: -size * .17),
              _block(size, 'A', const Color(0xFFE8553D), dx: -size * .17, dy: size * .13),
              _block(size, 'B', const Color(0xFFF2A93B), dx: size * .17, dy: size * .13),
            ],
          ),
        ),
      );

  static Widget _block(double s, String g, Color c, {required double dx, required double dy}) {
    final side = s * .36;
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(c, Colors.white, .24)!, c],
          ),
          borderRadius: BorderRadius.circular(s * .09),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .22), blurRadius: s * .05, offset: Offset(0, s * .03)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(g, style: TextStyle(fontSize: s * .22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
      ),
    );
  }
}

// ------------------------------------------------------------
// Sort it out — shapes dropping into two bins.
// ------------------------------------------------------------
class SortIcon extends StatelessWidget {
  final double size;
  const SortIcon({super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFFFFB35C), Color(0xFFF0822E)], // orange
        child: SizedBox(width: size * .82, height: size * .82, child: CustomPaint(painter: _SortPainter())),
      );
}

class _SortPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final b = s.width;
    Offset o(double fx, double fy) => Offset(fx * b, fy * b);
    final p = Paint()..isAntiAlias = true;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = b * .055
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    void bin(double cx) => canvas.drawPath(
          Path()
            ..moveTo((cx - .15) * b, .66 * b)
            ..lineTo((cx - .12) * b, .92 * b)
            ..lineTo((cx + .12) * b, .92 * b)
            ..lineTo((cx + .15) * b, .66 * b),
          stroke,
        );
    bin(.28);
    bin(.72);
    // down arrows
    final arr = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = b * .04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    canvas.drawPath(Path()..moveTo(.22 * b, .52 * b)..lineTo(.28 * b, .585 * b)..lineTo(.34 * b, .52 * b), arr);
    canvas.drawPath(Path()..moveTo(.66 * b, .52 * b)..lineTo(.72 * b, .585 * b)..lineTo(.78 * b, .52 * b), arr);
    // shapes being sorted
    canvas.drawCircle(o(.28, .34), b * .12, p..color = const Color(0xFFE8553D));
    canvas.drawCircle(o(.245, .305), b * .038, p..color = Colors.white.withValues(alpha: .6));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: o(.72, .32), width: b * .23, height: b * .23), Radius.circular(b * .05)),
      p..color = const Color(0xFF3E8FB0),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ------------------------------------------------------------
// Discover! — a science flask with bubbling liquid + a sparkle.
// ------------------------------------------------------------
class ScienceIcon extends StatelessWidget {
  final double size;
  const ScienceIcon({super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => IconTile(
        size: size,
        grad: const [Color(0xFF5ED49A), Color(0xFF2FA86E)], // emerald
        child: SizedBox(width: size * .80, height: size * .80, child: CustomPaint(painter: _SciencePainter())),
      );
}

class _SciencePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final b = s.width;
    Offset o(double fx, double fy) => Offset(fx * b, fy * b);
    double xx(double f) => f * b;
    double yy(double f) => f * b;
    final p = Paint()..isAntiAlias = true;

    final flask = Path()
      ..moveTo(xx(.42), yy(.16))
      ..lineTo(xx(.42), yy(.40))
      ..lineTo(xx(.22), yy(.82))
      ..quadraticBezierTo(xx(.20), yy(.93), xx(.33), yy(.93))
      ..lineTo(xx(.67), yy(.93))
      ..quadraticBezierTo(xx(.80), yy(.93), xx(.78), yy(.82))
      ..lineTo(xx(.58), yy(.40))
      ..lineTo(xx(.58), yy(.16))
      ..close();
    canvas.drawPath(flask, p..color = Colors.white);

    // liquid + bubbles, clipped to the glass
    canvas.save();
    canvas.clipPath(flask);
    canvas.drawRect(Rect.fromLTRB(0, yy(.60), b, b), p..color = const Color(0xFF34C77B));
    p.color = Colors.white.withValues(alpha: .8);
    canvas.drawCircle(o(.44, .74), xx(.045), p);
    canvas.drawCircle(o(.58, .80), xx(.035), p);
    canvas.drawCircle(o(.50, .67), xx(.03), p);
    canvas.restore();

    // cork / rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(xx(.40), yy(.09), xx(.60), yy(.17)), Radius.circular(xx(.03))),
      p..color = const Color(0xFFEAC079),
    );
    // sparkle
    final sp = Paint()
      ..color = Colors.white
      ..strokeWidth = xx(.03)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawLine(o(.80, .22), o(.80, .36), sp);
    canvas.drawLine(o(.73, .29), o(.87, .29), sp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ------------------------------------------------------------
// A chunky little pencil (eraser · ferrule · body · wood · lead).
// ------------------------------------------------------------
class _Pencil extends StatelessWidget {
  final double size; // overall length
  const _Pencil({required this.size});
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size * .34, height: size, child: CustomPaint(painter: _PencilPainter()));
}

class _PencilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final p = Paint()..isAntiAlias = true;
    final cx = w / 2;
    final bw = w * .72;
    final l = cx - bw / 2, r = cx + bw / 2;

    final eraserH = h * .12;
    canvas.drawRRect(
      RRect.fromRectAndCorners(Rect.fromLTRB(l, 0, r, eraserH),
          topLeft: Radius.circular(w * .3), topRight: Radius.circular(w * .3)),
      p..color = const Color(0xFFFF8FA3),
    );
    canvas.drawRect(Rect.fromLTRB(l, eraserH, r, eraserH + h * .055), p..color = const Color(0xFFBFC3CC));
    final bodyTop = eraserH + h * .055, bodyBot = h * .74;
    canvas.drawRect(Rect.fromLTRB(l, bodyTop, r, bodyBot), p..color = const Color(0xFFFFC93C));
    canvas.drawRect(Rect.fromLTRB(cx + bw * .14, bodyTop, r, bodyBot), p..color = const Color(0xFFE8A91F));
    // wood cone
    final leadY = h * .95;
    canvas.drawPath(
      Path()..moveTo(l, bodyBot)..lineTo(r, bodyBot)..lineTo(cx, leadY)..close(),
      p..color = const Color(0xFFEAC079),
    );
    // graphite tip
    canvas.drawPath(
      Path()..moveTo(cx - bw * .17, leadY - h * .055)..lineTo(cx + bw * .17, leadY - h * .055)..lineTo(cx, h)..close(),
      p..color = const Color(0xFF464646),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ------------------------------------------------------------
// A small speaker + sound waves (tap-to-hear hint).
// ------------------------------------------------------------
class _SoundPainter extends CustomPainter {
  final Color color;
  _SoundPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final p = Paint()
      ..color = color
      ..isAntiAlias = true;
    // speaker box + cone
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * .10, h * .38, w * .30, h * .62), Radius.circular(w * .03)),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .30, h * .38)
        ..lineTo(w * .50, h * .20)
        ..lineTo(w * .50, h * .80)
        ..lineTo(w * .30, h * .62)
        ..close(),
      p,
    );
    final wave = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .07
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawArc(Rect.fromCircle(center: Offset(w * .46, h * .5), radius: w * .20), -0.7, 1.4, false, wave);
    canvas.drawArc(Rect.fromCircle(center: Offset(w * .46, h * .5), radius: w * .33), -0.7, 1.4, false, wave);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
