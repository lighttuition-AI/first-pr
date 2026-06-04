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
  // ---- timing (the ring fill is the clock) ----
  static const int _names = 3;
  static const int _slotMs = 2000; // each ring fills over this long
  static const int _gapMs = 200; // tiny hold between sisters
  static const int _leadInMs = 850; // faces pop + harp settles before name 1
  static const int _tailMs = 450; // after the last ring, before fading
  static const int _ringTotalMs = _names * _slotMs + (_names - 1) * _gapMs;

  // name 1 stretches least … name 3 most (only affects the default TTS voice).
  static const List<double> _rates = [0.42, 0.34, 0.26];

  late final AnimationController _pop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  late final AnimationController _seq =
      AnimationController(vsync: this, duration: const Duration(milliseconds: _ringTotalMs))
        ..addListener(_tick)
        ..addStatusListener(_onSeqStatus);
  late final AnimationController _twinkle =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 850))..repeat();

  final AudioPlayer _harp = AudioPlayer();
  final List<bool> _fired = List.filled(_names, false);
  bool _soundOn = true;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playIntro());
  }

  // Harp first, then after a short lead-in the ring sequence begins (which in
  // turn announces each name as its ring starts to fill).
  Future<void> _playIntro() async {
    if (!mounted) return;
    _soundOn = context.read<AppState>().sound;
    if (_soundOn) {
      try {
        await _harp.setReleaseMode(ReleaseMode.loop); // soft bed under the names
        await _harp.setVolume(0.32);
        await _harp.play(AssetSource('audio/harp.wav'));
      } catch (_) {/* audio unavailable here */}
    }
    await Future.delayed(const Duration(milliseconds: _leadInMs));
    if (mounted) _seq.forward();
  }

  // Announce each name exactly once, the moment its ring starts to fill.
  void _tick() {
    final pMs = _seq.value * _ringTotalMs;
    for (var i = 0; i < _names; i++) {
      final start = i * (_slotMs + _gapMs);
      if (!_fired[i] && pMs >= start) {
        _fired[i] = true;
        _say(i);
      }
    }
  }

  void _say(int i) {
    if (!mounted || !_soundOn) return;
    final line = kSplashVo[i];
    // Fire-and-forget; the ring slot — not the clip length — sets the pace.
    context.read<VoService>().play(line.id, line.text, rate: _rates[i]);
  }

  void _onSeqStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: _tailMs), _done);
    }
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
    _seq.dispose();
    _pop.dispose();
    super.dispose();
  }

  double _fill(int i, double pMs) {
    final start = i * (_slotMs + _gapMs);
    return ((pMs - start) / _slotMs).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pop, _seq, _twinkle]),
      builder: (context, _) {
        final pop = Curves.easeOutBack.transform(_pop.value);
        final fade = Curves.easeOut.transform((_pop.value * 1.5).clamp(0.0, 1.0));
        final pMs = _seq.value * _ringTotalMs;
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
                  child: Opacity(opacity: fade, child: _cluster(pMs)),
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

  Widget _cluster(double pMs) => SizedBox(
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
                fill: _fill(0, pMs),
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
                fill: _fill(1, pMs),
                twinkle: _twinkle.value,
              ),
            ),
            Positioned(
              bottom: 0,
              child: _SisterBadge(
                d: 172,
                dress: const Color(0xFFF368A0),
                hair: 'puffs',
                fill: _fill(2, pMs),
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
    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // soft drop shadow + the face disc
          Positioned.fill(
            child: Transform.scale(
              scale: done ? 1.04 : 1.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: disc,
                  boxShadow: [
                    BoxShadow(
                      color: dress.withValues(alpha: done ? 0.45 : 0.22),
                      blurRadius: done ? 26 : 16,
                      spreadRadius: done ? 1 : 0,
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
