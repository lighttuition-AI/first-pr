// Parent area — child-lock gate + dashboard (stats, cognitive
// radar, per-skill bars, certificate, and settings).
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';
import '../widgets/robo.dart';
import '../widgets/shaker.dart';

const _target = 6;

// ---------------- Gate ----------------
class GateScreen extends StatefulWidget {
  /// What to do once 1-2-3-4 is entered correctly.
  /// Defaults to opening the parent dashboard.
  final VoidCallback? onUnlock;

  /// Close (X) action. Defaults to returning to the home map.
  final VoidCallback? onClose;

  const GateScreen({super.key, this.onUnlock, this.onClose});
  @override
  State<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends State<GateScreen> {
  late final List<int> _seq = [1, 2, 3, 4]..shuffle(math.Random());
  int _next = 1;
  final _padKey = GlobalKey<ShakerState>();

  @override
  void initState() {
    super.initState();
    final v = kScreenVo['gate']!;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) context.read<VoService>().play(v.id, v.text);
    });
  }

  void _tap(int n) {
    if (n == _next) {
      if (_next == 4) {
        context.read<FxController>().fire(intensity: 'gentle');
        final unlock = widget.onUnlock ?? () => context.read<AppState>().go('parent');
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) unlock();
        });
      }
      setState(() => _next = _next + 1);
    } else {
      _padKey.currentState?.shake();
      setState(() => _next = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Container(
      color: C.cream,
      child: Stack(
        children: [
          Positioned(top: 30, left: 40, child: IconCircle(Icons.close_rounded, onTap: widget.onClose ?? () => app.go('home'))),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 70)),
                const SizedBox(height: 10),
                Text('Grown-ups only', style: AppText.h1),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: AppText.lead.copyWith(fontSize: 30),
                    children: const [
                      TextSpan(text: 'Tap the numbers '),
                      TextSpan(text: 'in order', style: TextStyle(fontWeight: FontWeight.w900)),
                      TextSpan(text: ' — 1, 2, 3, 4.'),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Shaker(
                  key: _padKey,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _seq.length; i++) _numberTile(i, _seq[i], app),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final on = i < _next - 1;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: on ? app.pal.brand : C.line),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberTile(int i, int n, AppState app) {
    final got = n < _next;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Transform.rotate(
        angle: (i.isEven ? -1 : 1) * (3 + i) * math.pi / 180,
        child: GestureDetector(
          onTap: got ? null : () => _tap(n),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 150,
            height: 150,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: got ? app.pal.brandSoft : Colors.white,
              borderRadius: BorderRadius.circular(R.lg),
              boxShadow: Sh.md,
            ),
            child: Img(
              '$n',
              display: '$n',
              fill: false,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Dashboard ----------------
class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});
  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  bool _cert = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Container(
      color: C.paper,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 26, 40, 10),
                child: Row(
                  children: [
                    IconCircle(Icons.close_rounded, onTap: () => app.go('home')),
                    const SizedBox(width: 20),
                    Text('Parent dashboard', style: AppText.h2),
                    const Spacer(),
                    KidButton(
                      variant: BtnVariant.ghost,
                      onTap: app.openPictureStudio,
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('🖼️ '), Text('Pictures')]),
                    ),
                    const SizedBox(width: 14),
                    KidButton(
                      variant: BtnVariant.ghost,
                      onTap: app.openVoiceStudio,
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('🎙️ '), Text('Voiceover')]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(40, 10, 40, 40),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _stat('🔥', '${app.streak}', 'day streak'),
                          _stat('⏱️', '${app.timeToday}', 'min today'),
                          _stat('⭐', '${app.stars}', 'stars'),
                          _stat('🪐', '${app.planets.length}', 'planets'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _card(
                              'Cognitive sectors',
                              'Skills this week',
                              SizedBox(
                                height: 360,
                                child: Center(
                                  child: CustomPaint(size: const Size(340, 340), painter: _RadarPainter(app.skillXp, app.pal.brand)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _card(
                              'By skill area',
                              'Progress',
                              Column(children: [for (final t in kTopics) _skillBar(t, app)]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _cert = true),
                              child: _card(
                                'Achievement',
                                'Certificate of progress 🏆',
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("A printable certificate celebrating your child's learning.",
                                        style: AppText.lead.copyWith(fontSize: 22)),
                                    const SizedBox(height: 14),
                                    KidButton(small: true, onTap: () => setState(() => _cert = true), child: const Text('📄 View & download')),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(child: _settingsCard(app)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_cert) _Certificate(onClose: () => setState(() => _cert = false)),
        ],
      ),
    );
  }

  Widget _stat(String ico, String value, String label) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(R.lg), boxShadow: Sh.sm),
          child: Column(
            children: [
              Text(ico, style: const TextStyle(fontSize: 36)),
              Text(value, style: AppText.display(size: 40, weight: FontWeight.w800)),
              Text(label, style: AppText.body(size: 20, weight: FontWeight.w700, color: C.inkSoft)),
            ],
          ),
        ),
      );

  Widget _card(String kicker, String title, Widget child) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(R.lg), boxShadow: Sh.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Kicker(kicker),
            const SizedBox(height: 6),
            Text(title, style: AppText.display(size: 32, weight: FontWeight.w700)),
            const SizedBox(height: 18),
            child,
          ],
        ),
      );

  Widget _skillBar(Topic t, AppState app) {
    final v = math.min(1.0, (app.skillXp[t.id] ?? 0) / _target);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(t.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          SizedBox(width: 150, child: Text(t.label, style: AppText.body(size: 22, weight: FontWeight.w700))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(R.pill),
              child: Stack(
                children: [
                  Container(height: 18, color: C.line),
                  FractionallySizedBox(
                    widthFactor: v,
                    child: Container(height: 18, color: t.color(app.pal)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(AppState app) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(R.lg), boxShadow: Sh.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Kicker('Settings'),
            const SizedBox(height: 6),
            Text('Controls', style: AppText.display(size: 32, weight: FontWeight.w700)),
            const SizedBox(height: 14),
            _setRow('Session length', _Stepper(
              value: app.sessionLen,
              onMinus: () => app.setTweak(() => app.sessionLen = math.max(5, app.sessionLen - 5)),
              onPlus: () => app.setTweak(() => app.sessionLen = math.min(30, app.sessionLen + 5)),
            )),
            _setRow('Sound & voiceover', _Toggle(value: app.sound, onTap: () => app.setTweak(() => app.sound = !app.sound))),
            _setRow('Record my own voiceover',
                KidButton(small: true, variant: BtnVariant.ghost, onTap: app.openVoiceStudio, child: const Text('🎙️ Open Studio'))),
            _setRow('Use my own pictures',
                KidButton(small: true, variant: BtnVariant.ghost, onTap: app.openPictureStudio, child: const Text('🖼️ Picture Studio'))),
            _setRow('Celebration GIFs',
                KidButton(small: true, variant: BtnVariant.ghost, onTap: app.openGifStudio, child: const Text('🎞️ GIF Studio'))),
            _setRow('Child profile', Row(mainAxisSize: MainAxisSize.min, children: [
              KidButton(small: true, variant: BtnVariant.ghost, onTap: () => app.go('age'), child: const Text('Age')),
              const SizedBox(width: 10),
              KidButton(small: true, variant: BtnVariant.ghost, onTap: () => app.go('avatar'), child: const Text('Avatar')),
            ])),
            _setRow('Start over',
                KidButton(small: true, variant: BtnVariant.ghost, danger: true, onTap: app.resetAll, child: const Text('Reset progress'))),
          ],
        ),
      );

  Widget _setRow(String label, Widget control) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppText.body(size: 24, weight: FontWeight.w700))),
            control,
          ],
        ),
      );
}

class _Stepper extends StatelessWidget {
  final int value;
  final VoidCallback onMinus, onPlus;
  const _Stepper({required this.value, required this.onMinus, required this.onPlus});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn('–', onMinus),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('$value min', style: AppText.display(size: 26, weight: FontWeight.w700)),
        ),
        _btn('+', onPlus),
      ],
    );
  }

  Widget _btn(String s, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: C.line, borderRadius: BorderRadius.circular(R.sm)),
          child: Text(s, style: AppText.display(size: 30, weight: FontWeight.w800)),
        ),
      );
}

class _Toggle extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  const _Toggle({required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 78,
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: value ? pal.brand : C.line, borderRadius: BorderRadius.circular(R.pill)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Map<String, int> data;
  final Color brand;
  _RadarPainter(this.data, this.brand);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final radius = size.width / 2 - 44;
    final n = kTopics.length;
    Offset pt(int i, double r) {
      final a = -math.pi / 2 + (i / n) * math.pi * 2;
      return Offset(cx + math.cos(a) * r, cy + math.sin(a) * r);
    }

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = C.line;
    for (final rr in [0.33, 0.66, 1.0]) {
      final path = Path();
      for (var i = 0; i < n; i++) {
        final p = pt(i, radius * rr);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, grid);
    }
    for (var i = 0; i < n; i++) {
      canvas.drawLine(Offset(cx, cy), pt(i, radius), grid);
    }

    final valPath = Path();
    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final v = math.min(1.0, (data[kTopics[i].id] ?? 0) / _target);
      final p = pt(i, radius * v);
      pts.add(p);
      i == 0 ? valPath.moveTo(p.dx, p.dy) : valPath.lineTo(p.dx, p.dy);
    }
    valPath.close();
    canvas.drawPath(valPath, Paint()..color = brand.withValues(alpha: .26));
    canvas.drawPath(valPath, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = brand..strokeJoin = StrokeJoin.round);
    final dot = Paint()..color = brand;
    for (final p in pts) {
      canvas.drawCircle(p, 6, dot);
    }

    for (var i = 0; i < n; i++) {
      final p = pt(i, radius + 26);
      final tp = TextPainter(
        text: TextSpan(text: kTopics[i].emoji, style: const TextStyle(fontSize: 26)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.data != data || old.brand != brand;
}

class _Certificate extends StatefulWidget {
  final VoidCallback onClose;
  const _Certificate({required this.onClose});
  @override
  State<_Certificate> createState() => _CertificateState();
}

class _CertificateState extends State<_Certificate> {
  bool _saved = false;
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: ColoredBox(
          color: C.inkA(.5),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 720,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(R.xl), boxShadow: Sh.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: C.cream,
                        borderRadius: BorderRadius.circular(R.lg),
                        border: Border.all(color: C.sun, width: 6),
                      ),
                      child: Column(
                        children: [
                          const Text('🏅', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 8),
                          Text('HNL LEARNING', style: AppText.kicker),
                          const SizedBox(height: 6),
                          Text('Certificate of Progress',
                              textAlign: TextAlign.center,
                              style: AppText.display(size: 44, weight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text('proudly awarded to', style: AppText.lead.copyWith(fontSize: 24)),
                          const SizedBox(height: 6),
                          Text('My Superstar Learner',
                              style: AppText.display(size: 36, weight: FontWeight.w700, color: app.pal.brand)),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _certStat('${app.stars}', 'stars'),
                              _certStat('${app.planets.length}', 'planets'),
                              _certStat('${app.streak}', 'day streak'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (app.mascot) const Robo(size: 70, pose: 'cheer'),
                              const SizedBox(width: 10),
                              Text('Keep up the brilliant work!', style: AppText.body(size: 22, weight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    KidButton(
                      large: true,
                      onTap: () {
                        setState(() => _saved = true);
                        context.read<FxController>().fire(intensity: 'gentle');
                      },
                      child: Text(_saved ? '✓ Saved to device' : '📄 Download PDF'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _certStat(String v, String l) => Column(
        children: [
          Text(v, style: AppText.display(size: 32, weight: FontWeight.w800)),
          Text(l, style: AppText.body(size: 20, weight: FontWeight.w700, color: C.inkSoft)),
        ],
      );
}
