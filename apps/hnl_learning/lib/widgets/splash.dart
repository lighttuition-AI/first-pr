// ============================================================
// SplashScreen — the launch / loading screen.
// ------------------------------------------------------------
// The three Somali Village sisters, each in a round badge with a
// colourful progress ring that fills (with sparkles at the leading
// edge) while her name is announced. The rings light up one at a
// time — Nimoo, then Ladan, then Hibo — and the ring fill is the
// clock: each name gets a guaranteed window, so the first is never
// dropped and the last is never cut off. When the third ring
// finishes the splash reports done (app.dart fades it away).
// ============================================================
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import 'branding.dart';
import 'village.dart';

class SplashScreen extends StatefulWidget {
  /// Fired once all three name-rings have finished (or immediately on a
  /// failure) so the boot gate can fade the splash away. Keeping the splash
  /// up until the rings complete means the names never bleed into the app.
  final VoidCallback? onComplete;
  const SplashScreen({super.key, this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const int _names = 3;
  static const int _leadInMs = 650; // faces pop + harp settles before name 1
  static const int _gapMs = 200; // tiny hold between sisters
  static const int _tailMs = 380; // after the last ring, before fading

  // name 1 stretches least … name 3 most (only affects the default TTS voice).
  static const List<double> _rates = [0.42, 0.34, 0.26];

  late final AnimationController _pop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  // Reused per sister; its duration is set to that name's real clip length so
  // the ring fills exactly as the name plays — never cutting it off.
  late final AnimationController _ring = AnimationController(vsync: this);
  late final AnimationController _twinkle =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 850))..repeat();

  final AudioPlayer _harp = AudioPlayer();
  int _active = -1; // which ring is filling right now (-1 = none)
  int _doneCount = 0; // how many rings have completed (they stay full)
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playIntro());
  }

  // Harp bed, then each sister in turn: announce her name and fill her ring
  // over the name's *actual* duration before moving to the next.
  Future<void> _playIntro() async {
    if (!mounted) return;
    final soundOn = context.read<AppState>().sound;
    final vo = context.read<VoService>();
    if (soundOn) {
      try {
        await _harp.setReleaseMode(ReleaseMode.loop); // soft bed under the names
        // A grown-up's uploaded intro tune (Studio) plays a touch louder than
        // the gentle default harp; both sit under the spoken names.
        await _harp.setVolume(vo.hasSplashMusic ? 0.45 : 0.30);
        await _harp.play(vo.splashMusicSource());
      } catch (_) {/* audio unavailable here */}
    }
    await Future.delayed(const Duration(milliseconds: _leadInMs));

    for (var i = 0; i < _names && i < kSplashVo.length; i++) {
      if (!mounted) return;
      final line = kSplashVo[i];
      final dwell = soundOn
          ? await vo.beginSplashLine(line.id, line.text, rate: _rates[i])
          : const Duration(milliseconds: 1300);
      if (!mounted) return;
      _ring.duration = dwell;
      setState(() => _active = i);
      await _ring.forward(from: 0); // fills exactly as the name plays
      if (!mounted) return;
      setState(() {
        _doneCount = i + 1;
        _active = -1;
      });
      await Future.delayed(const Duration(milliseconds: _gapMs));
    }
    await Future.delayed(const Duration(milliseconds: _tailMs));
    _done();
  }

  void _done() {
    if (_completed) return;
    _completed = true;
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _harp.dispose();
    _twinkle.dispose();
    _ring.dispose();
    _pop.dispose();
    super.dispose();
  }

  // Ring fill for sister [i]: full if already done, live value if active, else empty.
  double _fill(int i) {
    if (i < _doneCount) return 1.0;
    if (i == _active) return _ring.value;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pop, _ring, _twinkle]),
      builder: (context, _) {
        final pop = Curves.easeOutBack.transform(_pop.value);
        final fade = Curves.easeOut.transform((_pop.value * 1.5).clamp(0.0, 1.0));
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.25),
              radius: 1.15,
              colors: [Color(0xFFFFF8EC), Color(0xFFFCE6CC)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.62 + 0.38 * pop,
                  child: Opacity(opacity: fade, child: _cluster()),
                ),
                const SizedBox(height: 22),
                Opacity(opacity: fade, child: const Logo()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cluster() => SizedBox(
        width: 480,
        height: 360,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // playful floating accents (letters · numbers · maths · music)
            _accent('A', const Color(0xFFF2B233), left: 214, top: -8, angle: -0.22, size: 54),
            _accent('5', const Color(0xFF4FB477), left: -10, top: 150, angle: -0.18, size: 52),
            _accent('+', const Color(0xFF4F9DDB), right: -8, top: 150, angle: 0.16, size: 58),
            _accent('🎵', null, right: 196, bottom: -6, angle: 0.14, size: 44),
            // the three sisters, each in a ring badge (Nimoo · Ladan · Hibo)
            Positioned(
              left: 24,
              top: 26,
              child: _SisterBadge(
                d: 150,
                dress: const Color(0xFFF2B233),
                hair: 'afro',
                fill: _fill(0),
                twinkle: _twinkle.value,
              ),
            ),
            Positioned(
              right: 24,
              top: 26,
              child: _SisterBadge(
                d: 150,
                dress: const Color(0xFF9B5DE5),
                hair: 'bun',
                fill: _fill(1),
                twinkle: _twinkle.value,
              ),
            ),
            Positioned(
              bottom: 0,
              child: _SisterBadge(
                d: 172,
                dress: const Color(0xFFF368A0),
                hair: 'puffs',
                fill: _fill(2),
                twinkle: _twinkle.value,
              ),
            ),
          ],
        ),
      );

  Widget _accent(String glyph, Color? color,
          {double? left, double? right, double? top, double? bottom, required double angle, required double size}) =>
      Positioned(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
        child: Transform.rotate(
          angle: angle,
          child: Text(
            glyph,
            style: color == null
                ? TextStyle(fontSize: size)
                : TextStyle(fontSize: size, fontWeight: FontWeight.w900, color: color),
          ),
        ),
      );
}

// One sister in a round badge: her face on a soft disc, framed by a colourful
// progress ring that fills (with sparkles at the leading edge) while her name
// is announced, and gives a little glow once it's complete.
class _SisterBadge extends StatelessWidget {
  final double d; // badge diameter
  final Color dress;
  final String hair;
  final double fill; // 0..1 ring progress
  final double twinkle; // 0..1 spark shimmer phase
  const _SisterBadge({
    required this.d,
    required this.dress,
    required this.hair,
    required this.fill,
    required this.twinkle,
  });

  @override
  Widget build(BuildContext context) {
    final disc = Color.lerp(dress, Colors.white, 0.86)!;
    final headSize = d * 1.22;
    final done = fill >= 0.999;
    final speaking = fill > 0.001 && !done; // her name is playing right now
    // A gentle "lift" while speaking, settling a touch raised once complete.
    final scale = speaking ? 1.06 : (done ? 1.03 : 1.0);
    final pulse = speaking ? (0.5 + 0.5 * math.sin(twinkle * 2 * math.pi)) : 0.0;
    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // soft drop shadow + the face disc
          Positioned.fill(
            child: Transform.scale(
              scale: scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: disc,
                  boxShadow: [
                    BoxShadow(
                      color: dress.withValues(
                          alpha: speaking ? (0.34 + 0.14 * pulse) : (done ? 0.42 : 0.20)),
                      blurRadius: speaking ? (26 + 8 * pulse) : (done ? 26 : 15),
                      spreadRadius: speaking ? (1 + pulse) : (done ? 1 : 0),
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      Positioned(
                        left: d / 2 - headSize / 2,
                        top: d / 2 - 0.42 * headSize, // face centre → badge centre
                        child: SomaliGirl(dress: dress, hair: hair, size: headSize, headOnly: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // the progress ring + leading-edge sparkles
          Positioned.fill(
            child: CustomPaint(
              painter: _RingPainter(fill: fill, twinkle: twinkle, color: dress),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fill; // 0..1
  final double twinkle; // 0..1
  final Color color;
  _RingPainter({required this.fill, required this.twinkle, required this.color});

  static const double _twoPi = math.pi * 2;
  static const double _top = -math.pi / 2; // 12 o'clock start

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final stroke = size.width * 0.058;
    final r = size.width / 2 - stroke / 2 - 1;
    final rect = Rect.fromCircle(center: c, radius: r);

    // faint track all the way round
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: 0.16),
    );
    if (fill <= 0) return;

    final bright = Color.lerp(color, Colors.white, 0.30)!;
    final sweep = fill * _twoPi;

    // soft glow under the arc
    canvas.drawArc(
      rect,
      _top,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 1.7
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // the colourful progress arc
    canvas.drawArc(
      rect,
      _top,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: _top,
          endAngle: _top + _twoPi,
          colors: [bright, Colors.white, color, bright],
          stops: const [0.0, 0.32, 0.72, 1.0],
        ).createShader(rect),
    );

    // leading-edge: a glowing tip + a little burst of sparkles
    final tipA = _top + sweep;
    final tip = c + Offset(math.cos(tipA), math.sin(tipA)) * r;
    if (fill < 0.999) {
      canvas.drawCircle(
        tip,
        stroke * 0.62,
        Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(tip, stroke * 0.42, Paint()..color = Colors.white);
      for (var k = 0; k < 5; k++) {
        final ph = (twinkle + k * 0.2) % 1.0;
        final ang = tipA + (k - 2) * 0.55 - 0.6; // fan out just behind the tip
        final dist = stroke * (0.7 + 2.0 * ph);
        final pos = tip + Offset(math.cos(ang), math.sin(ang)) * dist;
        final op = (1.0 - ph).clamp(0.0, 1.0);
        final sz = stroke * 0.5 * (1.0 - ph * 0.55);
        _star(canvas, pos, sz, Color.lerp(Colors.white, const Color(0xFFFFE08A), 0.5)!.withValues(alpha: op));
      }
    } else {
      // complete: a gentle full-ring shimmer
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 0.9
          ..color = Colors.white.withValues(alpha: 0.28 + 0.18 * math.sin(twinkle * _twoPi))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  // A small 4-point sparkle star.
  void _star(Canvas canvas, Offset centre, double r, Color color) {
    final inner = r * 0.38;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final rad = i.isEven ? r : inner;
      final a = _top + i * math.pi / 4;
      final p = centre + Offset(math.cos(a), math.sin(a)) * rad;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fill != fill || old.twinkle != twinkle || old.color != color;
}
