// ============================================================
// ContinentMapScreen — the Animals island hub.
// ------------------------------------------------------------
// A bright, kid-friendly world map: seven pressable continent
// landmasses (original blobby shapes, not a traced map) floating on a
// soft ocean. Tap one to start its shuffled animal quiz.
// ============================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/animals.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/kid_button.dart';

class ContinentMapScreen extends StatelessWidget {
  const ContinentMapScreen({super.key});

  // Map-like placement: centre fraction (x, y) + size (w, h) per continent id.
  static const Map<String, List<double>> _layout = {
    'north_america': [0.21, 0.30, 320, 230],
    'europe': [0.49, 0.19, 210, 150],
    'asia': [0.75, 0.31, 360, 250],
    'africa': [0.50, 0.54, 250, 290],
    'south_america': [0.29, 0.72, 240, 280],
    'oceania': [0.81, 0.71, 250, 190],
    'antarctica': [0.50, 0.92, 560, 120],
  };

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE8F5), Color(0xFF8FD3EE)],
        ),
      ),
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 4),
            child: Row(
              children: [
                IconCircle(Icons.arrow_back_rounded, onTap: () => app.go('home')),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: C.card,
                    borderRadius: BorderRadius.circular(R.pill),
                    boxShadow: Sh.sm,
                  ),
                  child: Text('🌍  Tap a continent!',
                      style: AppText.display(size: 26, weight: FontWeight.w800)),
                ),
                const Spacer(),
                const SizedBox(width: kTap), // balance the back button
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final w = box.maxWidth, h = box.maxHeight;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final c in kContinents)
                      if (_layout[c.id] case final p?)
                        Positioned(
                          left: p[0] * w - p[2] / 2,
                          top: p[1] * h - p[3] / 2,
                          width: p[2],
                          height: p[3],
                          child: _ContinentButton(
                            continent: c,
                            onTap: () => app.startContinent(c.id),
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinentButton extends StatefulWidget {
  final Continent continent;
  final VoidCallback onTap;
  const _ContinentButton({required this.continent, required this.onTap});

  @override
  State<_ContinentButton> createState() => _ContinentButtonState();
}

class _ContinentButtonState extends State<_ContinentButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.continent;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: CustomPaint(
          painter: _BlobPainter(c.color, c.id.hashCode),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 2),
                Text(
                  c.name,
                  textAlign: TextAlign.center,
                  style: AppText.display(size: 22, weight: FontWeight.w800, color: Colors.white).copyWith(
                    shadows: const [Shadow(color: Color(0x66000000), offset: Offset(0, 1), blurRadius: 3)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// An organic "landmass" blob filling the box, with a soft top sheen.
class _BlobPainter extends CustomPainter {
  final Color color;
  final int seed;
  _BlobPainter(this.color, this.seed);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    final rx = s.width * 0.47, ry = s.height * 0.46;
    const n = 11;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        () {
          final a = (i / n) * 2 * math.pi;
          final j = 0.80 + 0.20 * math.sin(seed * 1.7 + i * 2.3);
          return Offset(cx + math.cos(a) * rx * j, cy + math.sin(a) * ry * j);
        }()
    ];
    final path = _closedSmooth(pts);

    // soft drop shadow
    canvas.drawPath(path.shift(const Offset(0, 5)), Paint()
      ..color = Colors.black.withValues(alpha: .12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // body
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
    // top sheen
    canvas.save();
    canvas.clipPath(path);
    canvas.drawCircle(
      Offset(cx, cy - ry * 0.5),
      s.width * 0.5,
      Paint()..color = Colors.white.withValues(alpha: .18),
    );
    canvas.restore();
    // crisp edge
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(color, Colors.black, .18)!.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..isAntiAlias = true,
    );
  }

  Path _closedSmooth(List<Offset> pts) {
    final path = Path();
    final n = pts.length;
    Offset p(int i) => pts[(i % n + n) % n];
    path.moveTo(p(0).dx, p(0).dy);
    for (var i = 0; i < n; i++) {
      final p0 = p(i - 1), p1 = p(i), p2 = p(i + 1), p3 = p(i + 2);
      final c1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final c2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) => old.color != color || old.seed != seed;
}
