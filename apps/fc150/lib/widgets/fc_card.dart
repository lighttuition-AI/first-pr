import 'dart:io';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Tier metal presets (original art, outside the base palette).
class _Tier {
  final String label;
  final Color a, b, edge;
  final Color glow; // for halo / drop-shadow
  final Color tint;
  final double tintA;
  const _Tier(this.label, this.a, this.b, this.edge, this.glow, this.tint, this.tintA);
}

const _tiers = <String, _Tier>{
  'base': _Tier('GOLD', Color(0xFFE9C76B), Color(0xFF9A7320), Color(0xCCE9C76B), Color(0xFFE9C76B), Color(0xFFE9C76B), 0.10),
  'platinum': _Tier('PLATINUM', Color(0xFF8FF6FF), Color(0xFF1693C2), Color(0xF278EEFF), Color(0xFF46E0FF), Color(0xFF28C8EB), 0.22),
  'gold': _Tier('GOLD', Color(0xFFFFD874), Color(0xFFB0760E), Color(0xF2FFD06C), Color(0xFFFFC460), Color(0xFFFFBC40), 0.16),
  'silver': _Tier('SILVER', Color(0xFFFAFBFE), Color(0xFF6C7484), Color(0xEBE0E5F0), Color(0xFFCED5E4), Color(0xFFB4BCCE), 0.10),
};

/// The reusable FC150 player card — the hero component. Aspect ratio 1 : 1.5,
/// radius 18, four visual variants (neon / holo / mono / platinum).
class FCCard extends StatefulWidget {
  final String variant;
  final String tier;
  final int rating;
  final String name;
  final String pos;
  final String psn;
  final Stats stats;
  final double width;
  final bool shine;
  final String? photo; // local file path
  final List<Color>? flagBands;
  final VoidCallback? onTap;
  final VoidCallback? onPhotoTap; // tap the photo to expand it full-screen

  const FCCard({
    super.key,
    this.variant = 'neon',
    this.tier = 'base',
    required this.rating,
    required this.name,
    required this.pos,
    required this.psn,
    required this.stats,
    this.width = 300,
    this.shine = true,
    this.photo,
    this.flagBands,
    this.onTap,
    this.onPhotoTap,
  });

  @override
  State<FCCard> createState() => _FCCardState();
}

class _FCCardState extends State<FCCard> with TickerProviderStateMixin {
  // Created eagerly in initState (not lazy `late`) so dispose() never triggers a
  // first-time AnimationController creation on a deactivated element — which
  // crashes for cards that never read the controller during their life (e.g.
  // the mono variant with shine: false).
  late final AnimationController _shine;
  late final AnimationController _holo;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000))..repeat();
    _holo = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    _holo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = w * 1.5;
    final s = w / 300.0; // scale factor against the 300px reference design
    final isPlat = widget.variant == 'platinum';
    final t = _tiers[widget.tier] ?? _tiers['base']!;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final ratingCol = isPlat ? t.a : Colors.white;
    final labelText = isPlat ? t.label : (widget.variant == 'holo' ? 'HOLO' : 'FC150');

    // ---- background + edge per variant ----
    late final Gradient bg;
    late final Color edge;
    late final Gradient accentBar;
    if (widget.variant == 'neon') {
      bg = const LinearGradient(begin: Alignment(-0.3, -1), end: Alignment(0.3, 1), colors: [Color(0xFF1A1730), Color(0xFF0C0B18), Color(0xFF0A0A14)], stops: [0, 0.6, 1]);
      edge = const Color(0x807C6CF8);
      accentBar = FC.gradient;
    } else if (widget.variant == 'holo') {
      bg = const LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [Color(0xFF14122A), Color(0xFF0B0A16)]);
      edge = const Color(0x7300D8D6);
      accentBar = const LinearGradient(colors: [Color(0xFF7C6CF8), Color(0xFF00D8D6), Color(0xFF00C853), Color(0xFFFFB300), Color(0xFF7C6CF8)]);
    } else if (isPlat) {
      bg = LinearGradient(begin: Alignment(-0.4, -1), end: Alignment(0.4, 1), colors: [t.tint.withValues(alpha: t.tintA), const Color(0xFF0C0E1A), const Color(0xFF08080E)], stops: const [0, 0.52, 1]);
      edge = t.edge;
      accentBar = LinearGradient(colors: [t.b, t.a, t.b]);
    } else {
      bg = const LinearGradient(colors: [FC.surface, FC.surface]);
      edge = FC.borderStrong;
      accentBar = FC.gradient;
    }

    final glowColor = isPlat
        ? t.glow.withValues(alpha: 0.5)
        : widget.variant == 'holo'
            ? const Color(0x7300D8D6)
            : const Color(0x807C6CF8);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          gradient: bg,
          borderRadius: BorderRadius.circular(18 * s),
          border: Border.all(color: edge, width: 1),
          boxShadow: [
            BoxShadow(color: glowColor, blurRadius: 34 * s, spreadRadius: -10 * s),
            BoxShadow(color: const Color(0xCC000000), blurRadius: 60 * s, spreadRadius: -24 * s, offset: Offset(0, 24 * s)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18 * s),
          child: Stack(
            children: [
              // holo iridescent rotating foil
              if (widget.variant == 'holo')
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _holo,
                      builder: (_, __) => Opacity(
                        opacity: 0.6,
                        child: Transform.rotate(
                          angle: reduceMotion ? 0 : _holo.value * 6.28318,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: SweepGradient(
                                center: Alignment(0, -0.3),
                                colors: [
                                  Color(0x2E7C6CF8), Color(0x2E00D8D6), Color(0x2400C853),
                                  Color(0x24FFB300), Color(0x24FF5252), Color(0x2E7C6CF8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // faint pitch-grid texture
              Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _PitchGrid(34 * s)))),

              // platinum corner foil glow
              if (isPlat)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -1),
                          radius: 0.9,
                          colors: [t.glow.withValues(alpha: 0.20), Colors.transparent],
                          stops: const [0, 0.6],
                        ),
                      ),
                    ),
                  ),
                ),

              // top accent line (4px)
              Positioned(top: 0, left: 0, right: 0, child: Container(height: 4 * s, decoration: BoxDecoration(gradient: accentBar))),

              // content column
              Padding(
                padding: EdgeInsets.only(top: 4 * s),
                child: _content(w, s, isPlat, t, ratingCol, labelText, accentBar, edge),
              ),

              // idle shine sweep
              if (widget.shine && !reduceMotion)
                Positioned.fill(child: IgnorePointer(child: _ShineSweep(_shine, w, h))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(double w, double s, bool isPlat, _Tier t, Color ratingCol, String labelText, Gradient accentBar, Color edge) {
    final mutedLabel = isPlat ? Colors.white.withValues(alpha: 0.7) : FC.text2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // tier nameplate (winner cards only)
        if (isPlat)
          Padding(
            padding: EdgeInsets.only(top: 12 * s),
            child: _Nameplate(t: t, width: w, s: s),
          ),

        // HEADER: rating + position | flag + brand pill
        Padding(
          padding: EdgeInsets.fromLTRB(18 * s, (isPlat ? 8 : 18) * s, 18 * s, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.rating}',
                      style: FCType.mono(size: w * 0.2, weight: FontWeight.w700, color: ratingCol, letterSpacing: -0.04 * w * 0.2, height: 0.92)),
                  SizedBox(height: 4 * s),
                  Text(widget.pos,
                      style: FCType.heading(size: w * 0.066, weight: FontWeight.w800, color: isPlat ? t.a : FC.purple300, letterSpacing: 0.06 * w * 0.066)),
                  SizedBox(height: 7 * s),
                  Container(width: 30 * s, height: 2 * s, decoration: BoxDecoration(gradient: accentBar, borderRadius: BorderRadius.circular(2))),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FlagBands(width: w * 0.115, bands: widget.flagBands),
                  if (!isPlat) ...[
                    SizedBox(height: 8 * s),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
                      decoration: BoxDecoration(
                        color: const Color(0x40000000),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: FC.borderStrong),
                      ),
                      child: Text(labelText, style: FCType.body(size: 9.5 * s.clamp(0.8, 1.2), weight: FontWeight.w700, color: FC.text2, letterSpacing: 1.3 * s)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // PLAYER IMAGE — photo or silhouette (flex-grow)
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(18 * s, 4 * s, 18 * s, 0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: widget.photo != null
                  ? _Photo(path: widget.photo!, s: s, onTap: widget.onPhotoTap)
                  : FractionallySizedBox(
                      widthFactor: 0.78,
                      heightFactor: 1,
                      child: CustomPaint(painter: _Silhouette(isPlat ? t.a : (widget.variant == 'holo' ? const Color(0xFFBFEAFF) : Colors.white.withValues(alpha: 0.9)))),
                    ),
            ),
          ),
        ),

        // NAME
        Container(
          margin: EdgeInsets.fromLTRB(16 * s, 4 * s, 16 * s, 0),
          padding: EdgeInsets.only(bottom: 10 * s),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isPlat ? edge : FC.border))),
          child: Text(widget.name.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FCType.heading(size: w * 0.082, weight: FontWeight.w800, color: isPlat ? t.a : Colors.white, letterSpacing: 0.02 * w * 0.082)),
        ),

        // STATS grid — row-wise PAC,DRI / SHO,DEF / PAS,PHY
        Padding(
          padding: EdgeInsets.fromLTRB(22 * s, 12 * s, 22 * s, 0),
          child: Column(
            children: [
              for (final row in const [['PAC', 'DRI'], ['SHO', 'DEF'], ['PAS', 'PHY']])
                Padding(
                  padding: EdgeInsets.only(bottom: 7 * s),
                  child: Row(
                    children: [
                      Expanded(child: _statCell(row[0], w, mutedLabel)),
                      SizedBox(width: w * 0.07),
                      Expanded(child: _statCell(row[1], w, mutedLabel)),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // PSN footer
        Padding(
          padding: EdgeInsets.only(top: 8 * s, bottom: 14 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 5 * s, height: 5 * s, decoration: const BoxDecoration(color: FC.success, shape: BoxShape.circle, boxShadow: [BoxShadow(color: FC.success, blurRadius: 6)])),
              SizedBox(width: 6 * s),
              Text('PSN · ${widget.psn}', style: FCType.mono(size: w * 0.042, weight: FontWeight.w600, color: isPlat ? Colors.white.withValues(alpha: 0.75) : FC.text2, letterSpacing: 0.06 * w * 0.042)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCell(String label, double w, Color labelColor) {
    final key = const {'PAC': 'pac', 'DRI': 'dri', 'SHO': 'sho', 'DEF': 'def', 'PAS': 'pas', 'PHY': 'phy'}[label]!;
    final v = widget.stats.byKey(key);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$v', style: FCType.mono(size: w * 0.062, weight: FontWeight.w700, color: FC.statColor(v))),
        Text(label, style: FCType.body(size: w * 0.043, weight: FontWeight.w600, color: labelColor, letterSpacing: 0.08 * w * 0.043)),
      ],
    );
  }
}

/// Metallic gradient tier nameplate with hairline rules either side.
class _Nameplate extends StatelessWidget {
  final _Tier t;
  final double width;
  final double s;
  const _Nameplate({required this.t, required this.width, required this.s});

  @override
  Widget build(BuildContext context) {
    final rule = Container(width: width * 0.12, height: 1.5);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, t.edge])), child: rule),
        SizedBox(width: width * 0.03),
        ShaderMask(
          shaderCallback: (r) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, t.a, t.b],
            stops: const [0, 0.42, 1],
          ).createShader(r),
          child: Text(
            t.label,
            style: FCType.heading(size: width * 0.075, weight: FontWeight.w800, color: Colors.white, letterSpacing: 0.30 * width * 0.075),
          ),
        ),
        SizedBox(width: width * 0.03),
        DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [t.edge, Colors.transparent])), child: rule),
      ],
    );
  }
}

/// Simple geometric horizontal flag bands (original art, not official).
class FlagBands extends StatelessWidget {
  final double width;
  final List<Color>? bands;
  const FlagBands({super.key, this.width = 28, this.bands});

  @override
  Widget build(BuildContext context) {
    final cols = (bands == null || bands!.isEmpty)
        ? const [Color(0xFFAE1C28), Color(0xFFFFFFFF), Color(0xFF21468B)]
        : bands!;
    return Container(
      width: width,
      height: width * 0.66,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(children: [for (final c in cols) Expanded(child: ColoredBox(color: c))]),
    );
  }
}

class _Photo extends StatelessWidget {
  final String path;
  final double s;
  final VoidCallback? onTap;
  const _Photo({required this.path, required this.s, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(12 * s),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(path), fit: BoxFit.cover, alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => const ColoredBox(color: FC.overlay)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xD908080E)],
                stops: [0.55, 1],
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      // Tap to expand — shared-element transition into the full-screen viewer.
      image = Hero(tag: 'fc-card-photo', child: image);
      image = GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: image);
    }

    return FractionallySizedBox(widthFactor: 0.86, heightFactor: 1, child: image);
  }
}

class _PitchGrid extends CustomPainter {
  final double step;
  _PitchGrid(this.step);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _PitchGrid old) => old.step != step;
}

class _Silhouette extends CustomPainter {
  final Color tint;
  _Silhouette(this.tint);
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 200, sy = size.height / 230;
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [tint.withValues(alpha: 0.95), tint.withValues(alpha: 0.55)],
    ).createShader(Offset.zero & size);
    final p = Paint()..shader = shader;
    canvas.drawCircle(Offset(100 * sx, 62 * sy), 40 * ((sx + sy) / 2), p);
    final path = Path()
      ..moveTo(28 * sx, 230 * sy)
      ..cubicTo(28 * sx, 168 * sy, 60 * sx, 120 * sy, 100 * sx, 120 * sy)
      ..cubicTo(140 * sx, 120 * sy, 172 * sx, 168 * sy, 172 * sx, 230 * sy)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _Silhouette old) => old.tint != tint;
}

class _ShineSweep extends StatelessWidget {
  final Animation<double> anim;
  final double w, h;
  const _ShineSweep(this.anim, this.w, this.h);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        // sweep crosses once, then rests off-screen for the remainder of the cycle
        final k = (anim.value / 0.4).clamp(0.0, 1.0);
        final dx = (-1.4 + 2.8 * k) * w;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.rotate(
            angle: -0.35,
            child: Container(
              width: w * 0.5,
              height: h * 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0x22FFFFFF), Colors.transparent],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
