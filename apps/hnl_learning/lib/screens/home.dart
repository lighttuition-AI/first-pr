// Home world map (main hub) — three island worlds on a dotted
// path, Robo guide, star/planet counters, and the Daily Mission.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/avatar.dart';
import '../widgets/branding.dart';
import '../widgets/common.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';
import '../widgets/planet.dart';
import '../widgets/robo.dart';
import '../widgets/speech_bubble.dart';

/// Island positions on the map, aligned with kWorlds order (fractions of
/// the map area). Add a position here when a new world is added.
const List<Offset> _worldPos = [
  Offset(0.05, 0.30), // logic
  Offset(0.34, 0.05), // galaxy
  Offset(0.67, 0.10), // discovery
  Offset(0.50, 0.42), // arabic
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  World? _world;

  @override
  void initState() {
    super.initState();
    final v = kScreenVo['home']!;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.read<VoService>().play(v.id, v.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final v = kScreenVo['home']!;
    final body = DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.9),
          radius: 1.2,
          colors: [app.pal.brandSoft.withValues(alpha: .7), C.paper],
        ),
      ),
      child: Column(
        children: [
          const _HomeHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final w = box.maxWidth, h = box.maxHeight;
                return Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _MapPathPainter())),
                    // World islands (positions aligned with kWorlds order).
                    for (var i = 0; i < kWorlds.length && i < _worldPos.length; i++)
                      _islandAt(app, kWorlds[i], _worldPos[i].dx, _worldPos[i].dy, w, h),

                    // Robo guide + bubble (bottom-left, clear of the islands)
                    Positioned(
                      left: w * 0.04,
                      bottom: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SpeechBubble(
                            text: 'Tap an island to play!',
                            tail: Tail.down,
                            voId: v.id,
                            voText: v.text,
                          ),
                          const SizedBox(height: 2),
                          if (app.mascot) const Robo(size: 150, pose: 'wave'),
                        ],
                      ),
                    ),

                    // Daily mission
                    Positioned(
                      right: 40,
                      bottom: 40,
                      child: _MissionCard(onTap: () => app.startMission()),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        body,
        if (_world != null)
          WorldSheet(
            world: _world!,
            onClose: () => setState(() => _world = null),
            onPlay: (id) {
              setState(() => _world = null);
              app.startGame(id);
            },
          ),
      ],
    );
  }

  Widget _islandAt(AppState app, World world, double lx, double ty, double w, double h) {
    const iw = 250.0;
    return Positioned(
      left: w * lx - iw / 2 + iw / 2 - 20,
      top: h * ty,
      child: _Island(
        world: world,
        count: gamesInWorld(world.id).length + 1,
        onTap: () => setState(() => _world = world),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final av = app.avatar != null ? kAvatars.firstWhere((a) => a.id == app.avatar) : kAvatars[0];
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 26, 30, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => app.go('gate'),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 22, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.pill),
                boxShadow: Sh.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (app.photoBytes != null)
                    ClipOval(child: Image.memory(app.photoBytes!, width: 64, height: 64, fit: BoxFit.cover))
                  else
                    Avatar(data: av, size: 64),
                  const SizedBox(width: 12),
                  Text('${app.age ?? 5}', style: AppText.display(size: 34, weight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const Spacer(),
          const Logo(small: true),
          const Spacer(),
          Row(
            children: [
              HnlChip(icon: '⭐', value: '${app.stars}'),
              const SizedBox(width: 14),
              HnlChip(icon: '🪐', value: '${app.planets.length}', onTap: () => app.go('rewards')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Island extends StatefulWidget {
  final World world;
  final int count;
  final VoidCallback onTap;
  const _Island({required this.world, required this.count, required this.onTap});

  @override
  State<_Island> createState() => _IslandState();
}

class _IslandState extends State<_Island> with SingleTickerProviderStateMixin {
  late final AnimationController _bob =
      AnimationController(vsync: this, duration: Duration(milliseconds: 2200 + widget.world.id.hashCode % 800))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    final wc = pal.world(widget.world.id);
    final wd = pal.worldDeep(widget.world.id);
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bob,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -8 * Curves.easeInOut.transform(_bob.value)),
          child: child,
        ),
        child: Container(
          width: 250,
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(110),
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.4),
              colors: [Color.lerp(wc, Colors.white, .35)!, wc, wd],
              stops: const [0, .55, 1],
            ),
            boxShadow: [
              BoxShadow(color: wd, offset: const Offset(0, 12)),
              BoxShadow(color: wd.withValues(alpha: .4), offset: const Offset(0, 22), blurRadius: 34),
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 214,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Img(widget.world.emoji, size: 64),
                    const SizedBox(height: 4),
                    Text(widget.world.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: AppText.display(size: 26, weight: FontWeight.w800, color: Colors.white)),
                    Text(widget.world.tagline,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(size: 16, weight: FontWeight.w700, color: Colors.white.withValues(alpha: .92))),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.count, (i) {
                        final locked = i == widget.count - 1;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: locked ? Colors.white.withValues(alpha: .35) : Colors.white,
                          ),
                        );
                      }),
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
}

class _MissionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MissionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.lg),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD96B), C.sun],
          ),
          boxShadow: Sh.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(R.pill),
              ),
              child: Text('DAILY MISSION', style: AppText.kicker.copyWith(color: const Color(0xFF8A5A00))),
            ),
            const SizedBox(height: 10),
            const Text('🎯', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 4),
            Text("Today's adventure", style: AppText.display(size: 32, weight: FontWeight.w800)),
            Text('${app.missionGames().length} quick games · ~${app.sessionLen} min',
                style: AppText.body(size: 22, weight: FontWeight.w700, color: const Color(0xFF8A5A00))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(R.pill)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Start', style: AppText.display(size: 28, weight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- World sheet ----------------
class WorldSheet extends StatefulWidget {
  final World world;
  final VoidCallback onClose;
  final void Function(String gameId) onPlay;
  const WorldSheet({super.key, required this.world, required this.onClose, required this.onPlay});

  @override
  State<WorldSheet> createState() => _WorldSheetState();
}

class _WorldSheetState extends State<WorldSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pal = app.pal;
    final games = gamesInWorld(widget.world.id);
    final wc = pal.world(widget.world.id);

    return Stack(
      children: [
        // Scrim
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: FadeTransition(
              opacity: _c,
              child: Container(color: C.inkA(.4)),
            ),
          ),
        ),
        // Sheet
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
            child: Container(
              width: kStageW,
              constraints: const BoxConstraints(maxHeight: 760),
              padding: const EdgeInsets.fromLTRB(60, 40, 60, 50),
              decoration: const BoxDecoration(
                color: C.paper,
                borderRadius: BorderRadius.vertical(top: Radius.circular(R.xl)),
                boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 40)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: wc.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(R.lg),
                        ),
                        child: Img(widget.world.emoji, size: 52),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.world.name, style: AppText.h2),
                            const SizedBox(height: 4),
                            Text(widget.world.blurb, style: AppText.lead.copyWith(fontSize: 26)),
                          ],
                        ),
                      ),
                      IconCircle(Icons.close_rounded, onTap: widget.onClose),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 22,
                        runSpacing: 22,
                        children: [
                          for (final g in games)
                            _GameCard(
                              game: g,
                              done: app.planets.contains(g.reward),
                              onTap: () => widget.onPlay(g.id),
                            ),
                          for (int i = 0; i < 2; i++) const _LockedCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;
  final bool done;
  final VoidCallback onTap;
  const _GameCard({required this.game, required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final topic = topicById(game.topic);
    final isAlphabet = game.type == GameType.alphabet;
    final subtitle = isAlphabet ? '${kArabicLetters.length} letters' : '${game.rounds.length} rounds';

    Widget trailing;
    if (isAlphabet) {
      trailing = const Text('🔤', style: TextStyle(fontSize: 34));
    } else if (done) {
      trailing = Text('✓', style: AppText.display(size: 34, weight: FontWeight.w800, color: const Color(0xFF15B886)));
    } else {
      trailing = Planet(data: planetById(game.reward), size: 44);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 290,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(R.lg), boxShadow: Sh.sm),
        child: Row(
          children: [
            Img(topic.emoji, size: 52),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(game.title, style: AppText.display(size: 28, weight: FontWeight.w700)),
                  Text(subtitle, style: AppText.body(size: 20, weight: FontWeight.w700, color: C.muted)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: C.inkA(.03),
        borderRadius: BorderRadius.circular(R.lg),
        border: Border.all(color: C.line, width: 2),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('More soon', style: AppText.display(size: 28, weight: FontWeight.w700, color: C.muted)),
                Text('New puzzles weekly',
                    style: AppText.body(size: 20, weight: FontWeight.w700, color: C.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 1366, sy = size.height / 820;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    final path = Path()
      ..moveTo(p(250, 560).dx, p(250, 560).dy)
      ..cubicTo(p(430, 520).dx, p(430, 520).dy, p(500, 280).dx, p(500, 280).dy, p(690, 260).dx, p(690, 260).dy)
      ..cubicTo(p(880, 240).dx, p(880, 240).dy, p(980, 340).dx, p(980, 340).dy, p(1110, 400).dx, p(1110, 400).dy);
    final dot = Paint()..color = C.inkA(.16);
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        final pos = m.getTangentForOffset(d)?.position;
        if (pos != null) canvas.drawCircle(pos, 4, dot);
        d += 30;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
