// Home world map (main hub) — three island worlds on a dotted
// path, Robo guide, star/planet counters, and the Daily Mission.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/analytics.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/avatar.dart';
import '../widgets/branding.dart';
import '../widgets/common.dart';
import '../widgets/game_icons.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';
import '../widgets/robo.dart';
import '../widgets/speech_bubble.dart';

/// Island positions on the map, aligned with kWorlds order (fractions of
/// the map area). Add a position here when a new world is added.
const List<Offset> _worldPos = [
  Offset(0.02, 0.40), // logic   (mid-left)
  Offset(0.27, 0.02), // galaxy  (top)
  Offset(0.52, 0.05), // discovery (top-right)
  Offset(0.30, 0.40), // arabic  (mid-centre)
  Offset(0.02, 0.03), // animals (top-left)
  Offset(0.74, 0.33), // produce (right)
  Offset(0.54, 0.40), // story   (mid-right, lower)
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
    final app = context.read<AppState>();
    // Coming back from a game? Reopen that world's games list (the "games
    // area") instead of leaving the child on the bare island map.
    final resume = app.resumeWorld;
    if (resume != null) {
      app.resumeWorld = null;
      final w = kWorlds.where((x) => x.id == resume);
      if (w.isNotEmpty) _world = w.first;
    }
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
      // When the skin has an animated scene, stay transparent so its
      // characters (drawn behind the content) show through on the hub.
      decoration: activeSkin.hasScene
          ? const BoxDecoration()
          : BoxDecoration(
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
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MapPathPainter(activeSkin.brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: .22)
                            : C.inkA(.16)),
                      ),
                    ),
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
    const iw = 210.0;
    return Positioned(
      left: w * lx - iw / 2 + iw / 2 - 20,
      top: h * ty,
      child: _Island(
        world: world,
        onTap: switch (world.id) {
          // Animals & Story open their own screens; the rest open a games sheet.
          'animals' => () {
              Analytics.worldOpen('animals');
              app.openContinents();
            },
          'story' => () {
              Analytics.worldOpen('story');
              app.openStories();
            },
          _ => () {
              Analytics.worldOpen(world.id);
              setState(() => _world = world);
            },
        },
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
            onTap: app.openChildMenu,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(R.pill),
                boxShadow: Sh.sm,
                border: activeSkin.cardBorder,
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
                  const SizedBox(width: 6),
                  Icon(Icons.expand_more_rounded, color: C.muted),
                ],
              ),
            ),
          ),
          const Spacer(),
          const Logo(small: true),
          const Spacer(),
          HnlChip(icon: '⭐', value: '${app.stars}'),
        ],
      ),
    );
  }
}

class _Island extends StatefulWidget {
  final World world;
  final VoidCallback onTap;
  const _Island({required this.world, required this.onTap});

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
    final s = _islandScheme(widget.world.id);
    return Pressable(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bob,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -8 * Curves.easeInOut.transform(_bob.value)),
          child: child,
        ),
        child: SizedBox(
          width: 210,
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // A real little tropical island — sky, sun, sea, sand & palms —
              // in funky popping colours, clipped to a rounded "porthole".
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: [
                      BoxShadow(color: s.seaDeep, offset: const Offset(0, 10)),
                      BoxShadow(color: s.seaDeep.withValues(alpha: .4), offset: const Offset(0, 20), blurRadius: 30),
                    ],
                    border: activeSkin.cardBorder,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: CustomPaint(painter: _IslandPainter(s)),
                  ),
                ),
              ),
              // The world's emoji, sitting on the island between the palms.
              Positioned(
                top: 84,
                child: Container(
                  width: 76,
                  height: 76,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .85),
                    shape: BoxShape.circle,
                    boxShadow: Sh.sm,
                  ),
                  child: Img(widget.world.emoji, size: 46),
                ),
              ),
              // The world name on a bright pill at the bottom.
              Positioned(
                bottom: 14,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .94),
                    borderRadius: BorderRadius.circular(R.pill),
                    boxShadow: Sh.sm,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.world.name,
                      maxLines: 1,
                      style: AppText.display(size: 22, weight: FontWeight.w800, color: const Color(0xFF15324A)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Island scene art (per-world, funky popping colours) -------
class _IslandScheme {
  final Color skyTop, skyBottom, sea, seaDeep;
  const _IslandScheme(this.skyTop, this.skyBottom, this.sea, this.seaDeep);
}

const _kSand = Color(0xFFFFD25A);
const _kSandDark = Color(0xFFEFA73A);
const _kFrond = Color(0xFF2FD27E);
const _kFrondDark = Color(0xFF12A35B);
const _kTrunk = Color(0xFFBE7E4F);
const _kCoco = Color(0xFF7B4B2A);
const _kSun = Color(0xFFFFE45C);

_IslandScheme _islandScheme(String world) {
  switch (world) {
    case 'logic':
      return const _IslandScheme(Color(0xFFCDBBFF), Color(0xFF8A5BFF), Color(0xFF2BD4E8), Color(0xFF0E9BC4));
    case 'galaxy':
      return const _IslandScheme(Color(0xFF96A2FF), Color(0xFF5B5BE0), Color(0xFF7A5CF0), Color(0xFF5331C4));
    case 'discovery':
      return const _IslandScheme(Color(0xFFAEECFF), Color(0xFF34C6E0), Color(0xFF12B5C9), Color(0xFF0A8194));
    case 'arabic':
      return const _IslandScheme(Color(0xFFA9D6FF), Color(0xFF4C9CF0), Color(0xFF2E7DE0), Color(0xFF1858B8));
    case 'animals':
      return const _IslandScheme(Color(0xFFFFDDA0), Color(0xFFFFB04D), Color(0xFF36C98E), Color(0xFF17A06A));
    case 'produce':
      return const _IslandScheme(Color(0xFFFFC6AC), Color(0xFFFF7E54), Color(0xFF24B5A6), Color(0xFF0E8A7E));
    case 'story':
      return const _IslandScheme(Color(0xFFFFD2E0), Color(0xFFFF8FB3), Color(0xFFB07CF0), Color(0xFF7C4DD0));
    default:
      return const _IslandScheme(Color(0xFFCDBBFF), Color(0xFF8A5BFF), Color(0xFF2BD4E8), Color(0xFF0E9BC4));
  }
}

class _IslandPainter extends CustomPainter {
  final _IslandScheme s;
  const _IslandPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    double x(double f) => f * w;
    double y(double f) => f * h;

    // Sky
    final skyRect = Rect.fromLTWH(0, 0, w, y(0.66));
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [s.skyTop, s.skyBottom]).createShader(skyRect),
    );

    // Sun + soft glow (top-right)
    final sun = Offset(x(0.80), y(0.22));
    canvas.drawCircle(sun, w * 0.16, Paint()..color = _kSun.withValues(alpha: .35));
    canvas.drawCircle(sun, w * 0.092, Paint()..color = _kSun);

    // Two little birds in the sky
    final birdPaint = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.013
      ..strokeCap = StrokeCap.round;
    void bird(double bx, double by, double sc) {
      final p = Path()
        ..moveTo(x(bx) - w * 0.032 * sc, y(by))
        ..quadraticBezierTo(x(bx) - w * 0.012 * sc, y(by) - h * 0.022 * sc, x(bx), y(by))
        ..quadraticBezierTo(x(bx) + w * 0.012 * sc, y(by) - h * 0.022 * sc, x(bx) + w * 0.032 * sc, y(by));
      canvas.drawPath(p, birdPaint);
    }

    bird(0.24, 0.15, 1.0);
    bird(0.36, 0.22, 0.8);

    // Sea (wavy top edge) over the lower portion
    final seaTop = y(0.58);
    final sea = Path()
      ..moveTo(0, seaTop)
      ..cubicTo(x(0.25), seaTop - h * 0.03, x(0.5), seaTop + h * 0.03, x(0.74), seaTop - h * 0.02)
      ..cubicTo(x(0.9), seaTop - h * 0.035, w, seaTop - h * 0.01, w, seaTop)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final seaRect = Rect.fromLTWH(0, seaTop - h * 0.06, w, h - seaTop + h * 0.06);
    canvas.drawPath(
      sea,
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [s.sea, s.seaDeep]).createShader(seaRect),
    );

    // Wave glints
    final glint = Paint()
      ..color = Colors.white.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x(0.12), y(0.82)), Offset(x(0.30), y(0.82)), glint);
    canvas.drawLine(Offset(x(0.66), y(0.90)), Offset(x(0.86), y(0.90)), glint);

    // Sand island mound (sits in the water)
    final mound = Rect.fromCenter(center: Offset(x(0.5), y(0.80)), width: w * 0.74, height: h * 0.36);
    canvas.drawOval(
      mound,
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_kSand, _kSandDark]).createShader(mound),
    );

    // Palm trees framing the centre (left big, right small)
    _palm(canvas, Offset(x(0.24), y(0.70)), h * 0.44, -w * 0.05);
    _palm(canvas, Offset(x(0.78), y(0.72)), h * 0.30, w * 0.04);
  }

  void _palm(Canvas canvas, Offset base, double height, double lean) {
    final crown = base.translate(lean, -height);
    final tw = height * 0.06;
    // Trunk (slightly curved, tapered)
    final trunk = Path()
      ..moveTo(base.dx - tw, base.dy)
      ..quadraticBezierTo(base.dx - tw * 0.3 + lean * 0.5, base.dy - height * 0.5, crown.dx - tw * 0.6, crown.dy)
      ..lineTo(crown.dx + tw * 0.6, crown.dy)
      ..quadraticBezierTo(base.dx + tw * 0.3 + lean * 0.5, base.dy - height * 0.5, base.dx + tw, base.dy)
      ..close();
    canvas.drawPath(trunk, Paint()..color = _kTrunk);

    // Coconuts at the crown
    canvas.drawCircle(crown.translate(-tw * 0.9, tw), tw * 0.85, Paint()..color = _kCoco);
    canvas.drawCircle(crown.translate(tw * 0.6, tw * 1.2), tw * 0.85, Paint()..color = _kCoco);

    // Fronds — oval leaves fanning up & out from the crown
    final fr = height * 0.52;
    final fw = height * 0.22;
    const angles = [-2.7, -2.05, -1.4, -0.75, -0.1];
    for (final a in angles) {
      canvas.save();
      canvas.translate(crown.dx, crown.dy);
      canvas.rotate(a.toDouble());
      canvas.drawOval(Rect.fromLTWH(0, -fw / 2, fr, fw), Paint()..color = _kFrond);
      canvas.restore();
    }
    // A darker tuft over the crown centre
    canvas.drawCircle(crown, fw * 0.42, Paint()..color = _kFrondDark);
  }

  @override
  bool shouldRepaint(covariant _IslandPainter oldDelegate) => false;
}

class _MissionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MissionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFFFD96B), C.sun],
          ),
          boxShadow: Sh.md,
          border: activeSkin.cardBorder,
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
              decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.pill)),
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
              decoration: BoxDecoration(
                color: C.paper,
                borderRadius: BorderRadius.vertical(top: Radius.circular(R.xl)),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 40)],
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
  final VoidCallback onTap;
  const _GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final topic = topicById(game.topic);
    final pal = context.read<AppState>().pal;
    // A friendly "tap to play" badge (planet collecting was removed).
    final Widget playDot = Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(color: pal.brandSoft, shape: BoxShape.circle),
      child: Icon(Icons.play_arrow_rounded, color: pal.brand, size: 28),
    );
    final String subtitle;
    final Widget trailing;
    switch (game.type) {
      case GameType.alphabet:
        subtitle = '${kArabicLetters.length} letters';
        trailing = customGameTrailing(game.id) ?? const Text('🔤', style: TextStyle(fontSize: 34));
      case GameType.trace:
        subtitle = 'Trace & colour';
        trailing = customGameTrailing(game.id) ?? const Text('✏️', style: TextStyle(fontSize: 34));
      case GameType.arabicOrder:
        subtitle = 'Drag them in order';
        trailing = customGameTrailing(game.id) ?? const Text('🔀', style: TextStyle(fontSize: 34));
      case GameType.arabicFlip:
        subtitle = 'Flip & hear · ${kArabicLetters.length} cards';
        trailing = customGameTrailing(game.id) ?? const Text('🔄', style: TextStyle(fontSize: 34));
      case GameType.arabicSounds:
        subtitle = '${kHarakatForms.length} sounds · tap to hear';
        trailing = customGameTrailing(game.id) ?? const Text('🔊', style: TextStyle(fontSize: 34));
      case GameType.produceQuiz:
        subtitle = 'Guess & hear · EN + Somali';
        trailing = customGameTrailing(game.id) ?? Text(game.topic == 'fruit' ? '🍎' : '🥕', style: const TextStyle(fontSize: 34));
      case GameType.memory:
        subtitle = 'Flip & match · ${game.rounds.first.deck.length} pairs';
        trailing = playDot;
      default:
        subtitle = '${game.rounds.length} rounds';
        trailing = playDot;
    }

    return Pressable(
      onTap: onTap,
      child: Container(
        width: 290,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(R.lg),
            boxShadow: Sh.sm,
            border: activeSkin.cardBorder),
        child: Row(
          children: [
            customGameIcon(game.id, size: 52) ?? Img(topic.emoji, size: 52),
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
  final Color color;
  _MapPathPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 1366, sy = size.height / 820;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    final path = Path()
      ..moveTo(p(250, 560).dx, p(250, 560).dy)
      ..cubicTo(p(430, 520).dx, p(430, 520).dy, p(500, 280).dx, p(500, 280).dy, p(690, 260).dx, p(690, 260).dy)
      ..cubicTo(p(880, 240).dx, p(880, 240).dy, p(980, 340).dx, p(980, 340).dy, p(1110, 400).dx, p(1110, 400).dy);
    final dot = Paint()..color = color;
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
  bool shouldRepaint(covariant _MapPathPainter old) => old.color != color;
}
