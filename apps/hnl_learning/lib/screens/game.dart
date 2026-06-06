// Mini-games — the shared game shell + all 7 playable games.
// Correct → +8 score, confetti, stars, Robo cheer, then advance /
// reward reveal. Wrong → the element shakes and Robo says "try again".
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/gif_service.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';
import '../widgets/planet.dart';
import '../widgets/robo.dart';
import '../widgets/shaker.dart';
import '../widgets/speech_bubble.dart';
import 'produce_quiz.dart';

void _wrongVo(BuildContext c) {
  final f = feedbackVo('vo-fb-tryagain');
  c.read<VoService>().play(f.id, f.text);
}

// ---------------- Runner ----------------
class GameRunner extends StatelessWidget {
  const GameRunner({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.session;
    if (s == null) return const SizedBox.shrink();
    final game = gameById(s.queue[s.index]);
    return GameHost(
      key: ValueKey('${game.id}-${s.index}'),
      game: game,
      onComplete: () => app.finishGame(2),
    );
  }
}

// ---------------- Shell ----------------
class GameHost extends StatefulWidget {
  final Game game;
  final VoidCallback onComplete;
  const GameHost({super.key, required this.game, required this.onComplete});

  @override
  State<GameHost> createState() => _GameHostState();
}

class _GameHostState extends State<GameHost> {
  int _roundIdx = 0;
  bool _reveal = false;

  Round get round => widget.game.rounds[_roundIdx];
  bool get isLast => _roundIdx >= widget.game.rounds.length - 1;

  void _onSolved() {
    final app = context.read<AppState>();
    final fx = context.read<FxController>();
    app.award(gainStars: 8, topic: widget.game.topic);
    fx.fire(score: 8, intensity: app.celebration);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (isLast) {
        app.award(planetId: widget.game.reward, topic: widget.game.topic);
        setState(() => _reveal = true);
      } else {
        setState(() => _roundIdx++);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final mission = app.session?.mode == 'mission';
    final topic = topicById(widget.game.topic);

    return Container(
      color: round.bg,
      child: Stack(
        children: [
          // Game area
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 140, 40, 40),
              child: switch (widget.game.type) {
                // These fill the area (and scroll / draw); other games center.
                GameType.alphabet => const AlphabetBoard(),
                GameType.trace => const TraceGame(),
                GameType.arabicOrder => const ArabicOrderGame(),
                GameType.arabicFlip => const ArabicFlipGame(),
                GameType.arabicSounds => const ArabicSoundsGame(),
                GameType.produceQuiz => ProduceQuiz(category: widget.game.topic),
                _ => Center(
                    child: _GameBody(
                        key: ValueKey(_roundIdx), game: widget.game, round: round, onSolved: _onSolved),
                  ),
              },
            ),
          ),

          // Close
          Positioned(top: 24, left: 24, child: IconCircle(Icons.close_rounded, size: 76, onTap: () => app.go('home'))),

          // Floating speaker (auto-plays the round line)
          Positioned(
            left: 24,
            bottom: 24,
            child: FloatingSpeaker(
              key: ValueKey(voIdForRound(round)),
              voId: voIdForRound(round),
              voText: round.vo ?? round.factVo ?? '',
            ),
          ),

          // Top bar
          Positioned(
            top: 24,
            left: 120,
            right: 40,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (mission) ...[const _MissionTimer(), const SizedBox(width: 18)],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.pill), boxShadow: Sh.sm),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Img(topic.emoji, size: 28),
                          const SizedBox(width: 10),
                          Text(widget.game.title, style: AppText.display(size: 28, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.game.type != GameType.alphabet &&
                    widget.game.type != GameType.trace &&
                    widget.game.type != GameType.arabicOrder &&
                    widget.game.type != GameType.arabicFlip &&
                    widget.game.type != GameType.arabicSounds &&
                    widget.game.type != GameType.produceQuiz) ...[
                  const SizedBox(height: 12),
                  _RoundDots(total: widget.game.rounds.length, index: _roundIdx),
                ],
              ],
            ),
          ),

          if (_reveal) RewardReveal(planetId: widget.game.reward, onDone: widget.onComplete),
        ],
      ),
    );
  }
}

class _RoundDots extends StatelessWidget {
  final int total, index;
  const _RoundDots({required this.total, required this.index});
  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final now = i == index, done = i < index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: now ? 20 : 14,
          height: now ? 20 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: now || done ? pal.brand : Colors.white,
            border: now || done ? null : Border.all(color: C.line, width: 2),
          ),
        );
      }),
    );
  }
}

class _MissionTimer extends StatefulWidget {
  const _MissionTimer();
  @override
  State<_MissionTimer> createState() => _MissionTimerState();
}

class _MissionTimerState extends State<_MissionTimer> {
  late int _total;
  late int _left;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _total = app.sessionLen * 60;
    final started = app.session?.started ?? DateTime.now().millisecondsSinceEpoch;
    _left = math.max(0, _total - ((DateTime.now().millisecondsSinceEpoch - started) ~/ 1000));
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _left = math.max(0, _left - 1));
      if (_left <= 0) {
        context.read<AppState>().go('break');
      } else {
        _tick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_left ~/ 60).toString();
    final ss = (_left % 60).toString().padLeft(2, '0');
    final pct = _total == 0 ? 0.0 : (1 - _left / _total);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.pill), boxShadow: Sh.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⏱ $mm:$ss', style: AppText.display(size: 24, weight: FontWeight.w700)),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(R.pill),
            child: SizedBox(
              width: 120,
              height: 8,
              child: LinearProgressIndicator(
                value: pct.clamp(0, 1),
                backgroundColor: C.line,
                valueColor: AlwaysStoppedAnimation(context.watch<AppState>().pal.brand),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Body dispatch ----------------
class _GameBody extends StatelessWidget {
  final Game game;
  final Round round;
  final VoidCallback onSolved;
  const _GameBody({super.key, required this.game, required this.round, required this.onSolved});

  @override
  Widget build(BuildContext context) {
    switch (game.type) {
      case GameType.pick:
        return PickGame(round: round, onSolved: onSolved);
      case GameType.count:
        return CountGame(round: round, onSolved: onSolved);
      case GameType.pattern:
        return PatternGame(round: round, onSolved: onSolved);
      case GameType.memory:
        return MemoryGame(round: round, onSolved: onSolved);
      case GameType.letter:
        return LetterGame(round: round, onSolved: onSolved);
      case GameType.sort:
        return SortGame(round: round, onSolved: onSolved);
      case GameType.science:
        return ScienceGame(round: round, onSolved: onSolved);
      case GameType.alphabet:
        // Routed directly in GameHost (it fills/scrolls); here for completeness.
        return const AlphabetBoard();
      case GameType.trace:
        return const TraceGame();
      case GameType.arabicOrder:
        return const ArabicOrderGame();
      case GameType.arabicFlip:
        return const ArabicFlipGame();
      case GameType.arabicSounds:
        return const ArabicSoundsGame();
      case GameType.produceQuiz:
        return ProduceQuiz(category: game.topic);
    }
  }
}

// ---------------- Arabic World · game 1: alphabet board ----------------
// A grid of the 28 Arabic letters; tap one to hear it. Every letter is a
// recordable voice line, so a grown-up can record the real pronunciation.
class AlphabetBoard extends StatelessWidget {
  const AlphabetBoard({super.key});

  // Soft tile backgrounds + letter inks, cycled to mimic the colorful poster.
  static const _bgs = [
    Color(0xFFF6ECC9), Color(0xFFB7C9A1), Color(0xFF9B8BA9),
    Color(0xFFBAD8DC), Color(0xFFB28D6B), Color(0xFFCFE0C2),
  ];
  static const _inks = [
    Color(0xFFCDA12B), Color(0xFFE84C6B), Color(0xFF1E5631),
    Color(0xFF1B3A6B), Color(0xFF8B5A2B), Color(0xFF2E8B8B),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // Arabic reads right-to-left: first letter (Alif) lands top-right.
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 2.4,
        ),
        itemCount: kArabicLetters.length,
        itemBuilder: (context, i) => _LetterTile(
          letter: kArabicLetters[i],
          bg: _bgs[i % _bgs.length],
          ink: _inks[(i * 5 + 2) % _inks.length],
        ),
      ),
    );
  }
}

class _LetterTile extends StatefulWidget {
  final ArabicLetter letter;
  final Color bg, ink;
  const _LetterTile({required this.letter, required this.bg, required this.ink});

  @override
  State<_LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<_LetterTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final speaking = context.watch<VoService>().isActive(widget.letter.id);
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () => context.read<VoService>().play(widget.letter.id, widget.letter.name),
      child: AnimatedScale(
        scale: _down ? 0.94 : 1,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(R.md),
            boxShadow: Sh.sm,
            border: Border.all(
              color: speaking ? widget.ink : Colors.transparent,
              width: 4,
            ),
          ),
          // System font (not google_fonts) so the Arabic glyph renders.
          child: Text(
            widget.letter.glyph,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 66, fontWeight: FontWeight.w700, color: widget.ink),
          ),
        ),
      ),
    );
  }
}

// ---------------- Arabic World · game 2: letter tracing ----------------
// Pick a colour, then trace the letter with a finger over a hollow guide.
// Each letter reuses the same recordable voice line as the alphabet board.
class TraceGame extends StatefulWidget {
  const TraceGame({super.key});
  @override
  State<TraceGame> createState() => _TraceGameState();
}

class _Stroke {
  final Color color;
  final List<Offset> points;
  _Stroke(this.color, this.points);
}

class _TraceGameState extends State<TraceGame> {
  static const _palette = [
    Color(0xFFE84C6B), Color(0xFFFF8A3D), Color(0xFFFFC23C), Color(0xFF2E8B57),
    Color(0xFF2E8BC4), Color(0xFF7A5BD0), Color(0xFF8B5A2B), Color(0xFF2B3A43),
  ];
  static const double _canvas = 520;

  int _idx = 0;
  Color _color = _palette[0];
  final List<_Stroke> _strokes = [];
  _Stroke? _current;
  final Set<int> _traced = {};
  bool _celebrating = false;

  ArabicLetter get _letter => kArabicLetters[_idx];

  @override
  void initState() {
    super.initState();
    _playLetter(550);
  }

  void _playLetter([int delay = 250]) {
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) context.read<VoService>().play(_letter.id, _letter.name);
    });
  }

  void _go(int delta) {
    setState(() {
      _idx = (_idx + delta) % kArabicLetters.length;
      if (_idx < 0) _idx += kArabicLetters.length;
      _strokes.clear();
      _current = null;
    });
    _playLetter();
  }

  /// Mark the current letter traced. When all 28 are done → celebrate.
  void _markDone() {
    if (_strokes.isEmpty) return;
    setState(() => _traced.add(_idx));
    if (_traced.length >= kArabicLetters.length) {
      context.read<FxController>().fire(intensity: context.read<AppState>().celebration);
      setState(() => _celebrating = true);
    } else {
      _nextUntraced();
    }
  }

  void _nextUntraced() {
    for (var step = 1; step <= kArabicLetters.length; step++) {
      final n = (_idx + step) % kArabicLetters.length;
      if (!_traced.contains(n)) {
        setState(() {
          _idx = n;
          _strokes.clear();
          _current = null;
        });
        _playLetter();
        return;
      }
    }
  }

  void _restart() {
    setState(() {
      _celebrating = false;
      _traced.clear();
      _idx = 0;
      _strokes.clear();
      _current = null;
    });
    _playLetter();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        // Letter name + speaker + prev/next
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconCircle(Icons.chevron_left_rounded, size: 64, onTap: () => _go(-1)),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => context.read<VoService>().play(_letter.id, _letter.name),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.pill), boxShadow: Sh.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_letter.glyph, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 14),
                    Text(_letter.name, style: AppText.display(size: 28, weight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Icon(Icons.volume_up_rounded, color: C.inkSoft),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            IconCircle(Icons.chevron_right_rounded, size: 64, onTap: () => _go(1)),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tracing canvas
              Container(
                width: _canvas,
                height: _canvas,
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(R.lg),
                  boxShadow: Sh.md,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(R.lg),
                  child: Stack(
                    children: [
                      // Hollow guide letter to trace over
                      Center(
                        child: Text(
                          _letter.glyph,
                          style: TextStyle(
                            fontSize: 380,
                            height: 1.0,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 5
                              ..color = const Color(0xFFCAD4DA),
                          ),
                        ),
                      ),
                      // Drawing surface
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (d) => setState(() {
                          _current = _Stroke(_color, [d.localPosition]);
                          _strokes.add(_current!);
                        }),
                        onPanUpdate: (d) => setState(() => _current?.points.add(d.localPosition)),
                        onPanEnd: (_) => _current = null,
                        child: CustomPaint(size: const Size(_canvas, _canvas), painter: _TracePainter(_strokes)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 44),
              // Colour palette + clear
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pick a colour', style: AppText.display(size: 26, weight: FontWeight.w700, color: C.inkSoft)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final c in _palette) _Swatch(color: c, selected: c == _color, onTap: () => setState(() => _color = c)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  KidButton(
                    onTap: _strokes.isEmpty ? null : _markDone,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(_traced.contains(_idx) ? '✓ Traced' : 'Done!'),
                      const SizedBox(width: 10),
                      const Icon(Icons.check_rounded),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  KidButton(
                    variant: BtnVariant.ghost,
                    small: true,
                    onTap: _strokes.isEmpty ? null : () => setState(() => _strokes.clear()),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.refresh_rounded),
                      SizedBox(width: 8),
                      Text('Clear'),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  Text('Traced ${_traced.length} / ${kArabicLetters.length}',
                      style: AppText.body(size: 22, weight: FontWeight.w800, color: C.muted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Stack(
      children: [
        content,
        if (_celebrating)
          Positioned.fill(child: _FinishCard(title: 'You traced every letter! 🎉', onDone: _restart)),
      ],
    );
  }
}

// A full-set completion card: a big uploaded GIF (or Robo) + a replay button.
// Shared by the tracing + letter-order games. Confetti is fired separately
// via the FxController.
class _FinishCard extends StatelessWidget {
  final String title;
  final VoidCallback onDone;
  const _FinishCard({required this.title, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final gif = context.watch<GifService>().randomGif();
    final app = context.watch<AppState>();
    return ColoredBox(
      color: C.inkA(.55),
      child: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(50, 40, 50, 40),
          decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(R.xl), boxShadow: Sh.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: AppText.display(size: 46, weight: FontWeight.w800)),
              const SizedBox(height: 20),
              if (gif != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(R.lg),
                  child: Image.memory(gif, width: 540, height: 380, fit: BoxFit.contain, gaplessPlayback: true),
                )
              else if (app.mascot)
                const Robo(size: 200, pose: 'cheer'),
              const SizedBox(height: 26),
              KidButton(
                large: true,
                onTap: onDone,
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Yay! Again'),
                  SizedBox(width: 12),
                  Icon(Icons.refresh_rounded),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _Swatch({required this.color, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: Sh.sm,
          border: Border.all(color: Colors.white, width: selected ? 5 : 0),
        ),
        child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 26) : null,
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  final List<_Stroke> strokes;
  _TracePainter(this.strokes);
  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length == 1) {
        canvas.drawCircle(s.points.first, 9, Paint()..color = s.color);
      } else {
        final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
        for (final p in s.points.skip(1)) {
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter old) => true;
}

// ---------------- Arabic World · game 3: put the letters in order ----------------
// The 28 boxes sit empty in alphabet order (each shows a faint ghost of its
// letter as a gentle guide); the letters are shuffled in a tray below. Drag a
// letter up into its box — the right box snaps it in (glyph turns solid + the
// letter is spoken + a little confetti); a wrong box gives a gentle shake. Fill
// all 28 → celebrate + play again (reshuffled). Explore-only (no timer/score).
class ArabicOrderGame extends StatefulWidget {
  const ArabicOrderGame({super.key});
  @override
  State<ArabicOrderGame> createState() => _ArabicOrderGameState();
}

class _ArabicOrderGameState extends State<ArabicOrderGame> {
  final Set<int> _placed = {}; // slot indices already filled correctly
  final Map<int, GlobalKey<ShakerState>> _keys = {};
  late List<int> _shuffled; // tray order (letter indices)
  bool _celebrating = false;

  // Vibrant, kid-friendly colours; each letter keeps its colour on both the
  // tray tile and its target box, so a child can colour-match while learning.
  static const _palette = [
    Color(0xFFE84C6B), Color(0xFFFF8A3D), Color(0xFFFFC23C), Color(0xFF2E9E5B),
    Color(0xFF2E8BC4), Color(0xFF7A5BD0), Color(0xFFE85AA0), Color(0xFF17A8A0),
  ];
  Color _col(int i) => _palette[i % _palette.length];

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    _shuffled = [for (var i = 0; i < kArabicLetters.length; i++) i]..shuffle();
  }

  GlobalKey<ShakerState> _key(int i) => _keys.putIfAbsent(i, () => GlobalKey<ShakerState>());

  // A letter (index [letterIdx]) was dropped on the box for slot [slot].
  void _drop(int slot, int letterIdx) {
    if (_placed.contains(slot)) return;
    if (letterIdx == slot) {
      setState(() => _placed.add(slot));
      context.read<VoService>().play(kArabicLetters[slot].id, kArabicLetters[slot].name);
      final fx = context.read<FxController>();
      if (_placed.length >= kArabicLetters.length) {
        fx.fire(intensity: context.read<AppState>().celebration); // big finish
        Future.delayed(const Duration(milliseconds: 550), () {
          if (mounted) setState(() => _celebrating = true);
        });
      } else {
        fx.fire(score: 0, intensity: 'gentle');
      }
    } else {
      _key(letterIdx).currentState?.shake();
      _wrongVo(context);
    }
  }

  void _restart() {
    setState(() {
      _placed.clear();
      _celebrating = false;
      _shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.watch<AppState>().pal.brand;
    final remaining = _shuffled.where((i) => !_placed.contains(i)).toList();

    final content = Column(
      children: [
        // ---- the 28 ordered boxes (Alif top-right, reading right-to-left) ----
        Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SizedBox(
              width: 7 * 108 + 6 * 12, // exactly 7 boxes per row → 4 rows of 7
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [for (var i = 0; i < kArabicLetters.length; i++) _box(i, brand)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Placed ${_placed.length} / ${kArabicLetters.length}',
            style: AppText.body(size: 22, weight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 14),
        // ---- the shuffled letter tray ----
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  for (final i in remaining)
                    Draggable<int>(
                      data: i,
                      dragAnchorStrategy: pointerDragAnchorStrategy,
                      feedback: Material(
                        type: MaterialType.transparency,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, -0.5),
                          child: _tile(i, dragging: true),
                        ),
                      ),
                      childWhenDragging: Opacity(opacity: .25, child: _tile(i)),
                      child: Shaker(key: _key(i), child: _tile(i)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Stack(
      children: [
        content,
        if (_celebrating)
          Positioned.fill(child: _FinishCard(title: 'You put every letter in order! 🎉', onDone: _restart)),
      ],
    );
  }

  // One target box for slot [i]. Empty: a soft colour tint + a colour-matched
  // ghost glyph (a gentle guide). Filled: solid vibrant colour + white glyph,
  // locked (won't accept more). [brand] highlights the box being hovered over.
  Widget _box(int i, Color brand) {
    final filled = _placed.contains(i);
    final col = _col(i);
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !filled,
      onAcceptWithDetails: (d) => _drop(i, d.data),
      builder: (context, cand, rej) {
        final hover = cand.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 108,
          height: 92,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? col : (hover ? col.withValues(alpha: .26) : col.withValues(alpha: .12)),
            borderRadius: BorderRadius.circular(R.md),
            border: Border.all(
              color: hover ? brand : col.withValues(alpha: filled ? 1 : .5),
              width: hover || filled ? 4 : 2.5,
            ),
            boxShadow: filled
                ? [BoxShadow(color: col.withValues(alpha: .45), blurRadius: 12, offset: const Offset(0, 6))]
                : Sh.sm,
          ),
          child: Text(
            kArabicLetters[i].glyph,
            style: TextStyle(
              fontSize: 56,
              height: 1.0,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.none,
              color: filled ? Colors.white : col.withValues(alpha: .55), // colour-matched ghost guide
            ),
          ),
        );
      },
    );
  }

  // A draggable letter tile — a vibrant colour chip (matches its target box).
  Widget _tile(int i, {bool dragging = false}) {
    final col = _col(i);
    return Container(
      width: 96,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(col, Colors.white, .22)!, col],
        ),
        borderRadius: BorderRadius.circular(R.md),
        boxShadow: [
          BoxShadow(color: col.withValues(alpha: dragging ? .6 : .42), blurRadius: dragging ? 18 : 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Text(
        kArabicLetters[i].glyph,
        style: const TextStyle(
          fontSize: 52,
          height: 1.0,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.none,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---------------- Arabic World · game 4: flip the letters ----------------
// A poster of 28 cards, each shown "turned around" (the letter mirrored & dim,
// with a little flip hint). Tap a card → it does a 3D flip to the correct,
// upright letter and speaks it (reusing the alphabet board's recordable voice
// lines). When all 28 are revealed → confetti, then every card flips back for
// a fresh round. Explore-only (no timer/score).
class ArabicFlipGame extends StatefulWidget {
  const ArabicFlipGame({super.key});
  @override
  State<ArabicFlipGame> createState() => _ArabicFlipGameState();
}

class _ArabicFlipGameState extends State<ArabicFlipGame> {
  final Set<int> _revealed = {}; // cards flipped to the correct side
  int _round = 0; // bumps each new game → cycles the card colours
  bool _resetting = false; // brief lock while the board flips back

  // Vibrant, poster-style colours (cycled across the 28 cards).
  static const _palette = [
    Color(0xFFE84C6B), Color(0xFFFF8A3D), Color(0xFFF2B100), Color(0xFF2E9E5B),
    Color(0xFF2E8BC4), Color(0xFF7A5BD0), Color(0xFFE85AA0), Color(0xFF17A8A0),
    Color(0xFF8B5A2B), Color(0xFF4A63B8),
  ];
  Color _col(int i) => _palette[(i + _round) % _palette.length];

  void _tap(int i) {
    if (_resetting) return;
    final l = kArabicLetters[i];
    context.read<VoService>().play(flipVoId(l), l.name); // tap (or re-tap) → hear it (own recording)
    if (_revealed.contains(i)) return;
    setState(() => _revealed.add(i));
    if (_revealed.length >= kArabicLetters.length) {
      context.read<FxController>().fire(intensity: context.read<AppState>().celebration);
      setState(() => _resetting = true);
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() {
          _revealed.clear();
          _round++;
          _resetting = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, cons) {
              const cols = 7, rows = 4, gap = 14.0;
              final cw = ((cons.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
              final ch = ((cons.maxHeight - gap * (rows - 1)) / rows).floorToDouble();
              return Directionality(
                // RTL so the first letter (Alif) sits top-right, like a poster.
                textDirection: TextDirection.rtl,
                child: Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (var i = 0; i < kArabicLetters.length; i++)
                      _FlipCard(
                        key: ValueKey('flip-$i'),
                        letter: kArabicLetters[i],
                        color: _col(i),
                        flipped: _revealed.contains(i),
                        width: cw,
                        height: ch,
                        onTap: () => _tap(i),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text('Flipped ${_revealed.length} / ${kArabicLetters.length}',
            style: AppText.body(size: 22, weight: FontWeight.w800, color: Colors.white)),
      ],
    );
  }
}

class _FlipCard extends StatefulWidget {
  final ArabicLetter letter;
  final Color color;
  final bool flipped;
  final double width, height;
  final VoidCallback onTap;
  const _FlipCard({
    super.key,
    required this.letter,
    required this.color,
    required this.flipped,
    required this.width,
    required this.height,
    required this.onTap,
  });
  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 430),
    value: widget.flipped ? 1 : 0,
  );
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  bool _down = false;

  @override
  void didUpdateWidget(covariant _FlipCard old) {
    super.didUpdateWidget(old);
    if (widget.flipped != old.flipped) {
      widget.flipped ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.95 : 1,
        duration: const Duration(milliseconds: 110),
        child: AnimatedBuilder(
          animation: _a,
          builder: (context, _) {
            final showFront = _a.value > 0.5; // past the halfway point
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0014) // perspective
                ..rotateY(_a.value * math.pi),
              child: showFront
                  // un-mirror the front (the card itself is rotated 180°)
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _front(),
                    )
                  : _back(),
            );
          },
        ),
      ),
    );
  }

  // "Turned around": a solid colour card with the glyph mirrored & dim + a
  // little circular-arrows hint — it reads as the letter facing away.
  Widget _back() {
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(R.lg),
        boxShadow: Sh.sm,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.flip(
            flipX: true,
            child: Text(
              widget.letter.glyph,
              style: TextStyle(
                fontSize: widget.height * 0.42,
                height: 1.0,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: .26),
              ),
            ),
          ),
          Positioned(
            bottom: widget.height * 0.08,
            child: Icon(Icons.cached_rounded, color: Colors.white.withValues(alpha: .82), size: widget.height * 0.16),
          ),
        ],
      ),
    );
  }

  // The correct, upright letter + its name — the colourful poster face.
  Widget _front() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(R.lg),
        boxShadow: Sh.sm,
        border: Border.all(color: widget.color, width: 4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.letter.glyph,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: widget.height * 0.40, height: 1.0, fontWeight: FontWeight.w800, color: widget.color),
          ),
          SizedBox(height: widget.height * 0.03),
          SizedBox(
            width: widget.width - 16,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(widget.letter.name,
                  style: AppText.body(size: widget.height * 0.12, weight: FontWeight.w800, color: widget.color)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Arabic World · game 5: letter sounds (harakat) ----------------
// A 4×7 RTL grid of 28 consonant cards; each card holds the 3 short-vowel forms
// (read right-to-left as a · i · u). Every one of the 84 cells is its own
// tappable sound — tap → hear that exact syllable (each separately recordable
// in the Voiceover Studio). Explore-only.
class ArabicSoundsGame extends StatelessWidget {
  const ArabicSoundsGame({super.key});

  static const _palette = [
    Color(0xFFE84C6B), Color(0xFFFF8A3D), Color(0xFFF2B100), Color(0xFF2E9E5B),
    Color(0xFF2E8BC4), Color(0xFF7A5BD0), Color(0xFFE85AA0), Color(0xFF17A8A0),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) {
        const cols = 4, rows = 7, gap = 12.0, cellGap = 6.0, padH = 8.0, padV = 7.0;
        final cw = ((cons.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
        final ch = ((cons.maxHeight - gap * (rows - 1)) / rows).floorToDouble();
        final cellW = (cw - padH * 2 - cellGap * 2) / 3;
        final cellH = ch - padV * 2;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < kHarakatLetters.length; i++)
                Container(
                  width: cw,
                  height: ch,
                  padding: const EdgeInsets.symmetric(horizontal: padH, vertical: padV),
                  decoration: BoxDecoration(
                    color: _palette[i % _palette.length].withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(R.lg),
                    border: Border.all(color: _palette[i % _palette.length].withValues(alpha: .55), width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final f in kHarakatLetters[i].forms)
                        _SoundCell(form: f, color: _palette[i % _palette.length], width: cellW, height: cellH),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SoundCell extends StatefulWidget {
  final HarakatForm form;
  final Color color;
  final double width, height;
  const _SoundCell({required this.form, required this.color, required this.width, required this.height});
  @override
  State<_SoundCell> createState() => _SoundCellState();
}

class _SoundCellState extends State<_SoundCell> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    // Only this cell rebuilds when its own clip starts/stops playing.
    final speaking = context.select<VoService, bool>((v) => v.isActive(widget.form.id));
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () => context.read<VoService>().play(widget.form.id, widget.form.label),
      child: AnimatedScale(
        scale: _down ? 0.9 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(R.md),
            boxShadow: Sh.sm,
            border: Border.all(color: speaking ? widget.color : Colors.transparent, width: 3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.form.glyph,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: widget.height * 0.42, height: 1.0, fontWeight: FontWeight.w700, color: widget.color),
              ),
              SizedBox(height: widget.height * 0.03),
              SizedBox(
                width: widget.width - 6,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(widget.form.label,
                      style: AppText.body(size: widget.height * 0.14, weight: FontWeight.w800, color: C.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Reusable tap card (pick / letter / science) ----------------
class TapCard extends StatefulWidget {
  final bool correct;
  final bool locked;
  final double scale;
  final VoidCallback onCorrect;
  final Widget child;
  const TapCard({
    super.key,
    required this.correct,
    required this.onCorrect,
    required this.child,
    this.locked = false,
    this.scale = 1.0,
  });

  @override
  State<TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<TapCard> with SingleTickerProviderStateMixin {
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  bool _ring = false;

  void _tap() {
    if (widget.locked || _ring) return;
    if (widget.correct) {
      setState(() => _ring = true);
      widget.onCorrect();
    } else {
      _shake.forward(from: 0);
      _wrongVo(context);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(R.lg),
        boxShadow: _ring ? [BoxShadow(color: pal.brand.withValues(alpha: .5), blurRadius: 24, spreadRadius: 2)] : Sh.sm,
        border: Border.all(color: _ring ? pal.brand : Colors.transparent, width: 5),
      ),
      child: widget.child,
    );

    card = AnimatedBuilder(
      animation: _shake,
      builder: (_, child) {
        final v = _shake.value;
        final dx = v == 0 ? 0.0 : math.sin(v * math.pi * 5) * 18 * (1 - v);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: card,
    );

    return Transform.scale(
      scale: widget.scale,
      child: GestureDetector(onTap: _tap, child: card),
    );
  }
}

// ---------------- 1: Logic — pick ----------------
class PickGame extends StatefulWidget {
  final Round round;
  final VoidCallback onSolved;
  const PickGame({super.key, required this.round, required this.onSolved});
  @override
  State<PickGame> createState() => _PickGameState();
}

class _PickGameState extends State<PickGame> {
  bool _done = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.round.prompt != null)
          Text(widget.round.prompt!, style: AppText.display(size: 38, weight: FontWeight.w700)),
        const SizedBox(height: 36),
        Wrap(
          spacing: 30,
          runSpacing: 30,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final o in widget.round.options)
              TapCard(
                correct: o.correct,
                locked: _done,
                scale: o.scale,
                onCorrect: () {
                  setState(() => _done = true);
                  widget.onSolved();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Img(o.emoji, size: 120),
                    if (o.label != null) ...[
                      const SizedBox(height: 8),
                      Text(o.label!, style: AppText.display(size: 26, weight: FontWeight.w700)),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------- 2: Counting — drag N into basket ----------------
class CountGame extends StatefulWidget {
  final Round round;
  final VoidCallback onSolved;
  const CountGame({super.key, required this.round, required this.onSolved});
  @override
  State<CountGame> createState() => _CountGameState();
}

class _CountGameState extends State<CountGame> {
  final List<int> _placed = [];
  bool _done = false;
  final _basketKey = GlobalKey<ShakerState>();

  void _check() {
    if (_placed.length == widget.round.target) {
      setState(() => _done = true);
      widget.onSolved();
    } else {
      _basketKey.currentState?.shake();
      final fb = _placed.length > widget.round.target
          ? feedbackVo('vo-fb-toomany')
          : feedbackVo('vo-fb-addmore');
      context.read<VoService>().play(fb.id, fb.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final remaining = [for (int i = 0; i < r.pool; i++) i].where((i) => !_placed.contains(i)).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DragTarget<int>(
          onAcceptWithDetails: (d) {
            if (!_done && !_placed.contains(d.data)) setState(() => _placed.add(d.data));
          },
          builder: (context, cand, rej) => Shaker(
            key: _basketKey,
            child: Container(
              width: 360,
              height: 230,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(R.lg),
                boxShadow: Sh.md,
                border: Border.all(color: cand.isNotEmpty ? context.watch<AppState>().pal.brand : C.line, width: 3),
              ),
              child: Stack(
                children: [
                  Align(alignment: Alignment.centerLeft, child: Img(r.basket, size: 110)),
                  Padding(
                    padding: const EdgeInsets.only(left: 120),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final id in _placed)
                          GestureDetector(
                            onTap: _done ? null : () => setState(() => _placed.remove(id)),
                            child: Img(r.item, size: 48),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: context.watch<AppState>().pal.brand, shape: BoxShape.circle),
                      child: Text('${_placed.length}',
                          style: AppText.display(size: 30, weight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          alignment: WrapAlignment.center,
          children: [
            for (final id in remaining)
              Draggable<int>(
                data: id,
                feedback: Img(r.item, size: 84),
                childWhenDragging: Opacity(opacity: .3, child: Img(r.item, size: 70)),
                child: Img(r.item, size: 70),
              ),
          ],
        ),
        const SizedBox(height: 26),
        if (_placed.isNotEmpty)
          KidButton(
            large: true,
            onTap: _done ? null : _check,
            child: Text(_done ? '✓ Perfect!' : 'Done!'),
          ),
      ],
    );
  }
}

// ---------------- 3: Shapes & Patterns — drag into slot ----------------
class PatternGame extends StatefulWidget {
  final Round round;
  final VoidCallback onSolved;
  const PatternGame({super.key, required this.round, required this.onSolved});
  @override
  State<PatternGame> createState() => _PatternGameState();
}

class _PatternGameState extends State<PatternGame> {
  String? _filled;
  bool _done = false;
  final _slotKey = GlobalKey<ShakerState>();

  void _drop(String choice) {
    if (_done) return;
    if (choice == widget.round.answer) {
      setState(() {
        _filled = choice;
        _done = true;
      });
      widget.onSolved();
    } else {
      _slotKey.currentState?.shake();
      _wrongVo(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final pal = context.watch<AppState>().pal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final s in r.sequence)
              if (s == '?')
                DragTarget<String>(
                  onAcceptWithDetails: (d) => _drop(d.data),
                  builder: (context, cand, rej) => Shaker(
                    key: _slotKey,
                    child: Container(
                      width: 110,
                      height: 110,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _done ? C.card : C.inkA(.03),
                        borderRadius: BorderRadius.circular(R.md),
                        border: Border.all(
                          color: cand.isNotEmpty ? pal.brand : C.muted,
                          width: 3,
                        ),
                      ),
                      child: _filled != null
                          ? Img(_filled!, size: 64)
                          : Text('?', style: AppText.display(size: 48, weight: FontWeight.w800, color: C.muted)),
                    ),
                  ),
                )
              else
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  child: Img(s, size: 64),
                ),
          ],
        ),
        const SizedBox(height: 50),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            for (final c in r.choices)
              Draggable<String>(
                data: c,
                feedback: _choiceTile(c, dragging: true),
                childWhenDragging: Opacity(opacity: .3, child: _choiceTile(c)),
                child: _choiceTile(c),
              ),
          ],
        ),
      ],
    );
  }

  Widget _choiceTile(String c, {bool dragging = false}) => Container(
        width: 110,
        height: 110,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(R.md),
          boxShadow: dragging ? Sh.md : Sh.sm,
        ),
        child: Img(c, size: 64),
      );
}

// ---------------- 4: Memory — flip & match ----------------
class MemoryGame extends StatefulWidget {
  final Round round;
  final VoidCallback onSolved;
  const MemoryGame({super.key, required this.round, required this.onSolved});
  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemCard {
  final String id, emoji;
  _MemCard(this.id, this.emoji);
}

class _MemoryGameState extends State<MemoryGame> {
  late final List<_MemCard> _cards;
  final List<int> _flipped = [];
  final Set<String> _matched = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final pairs = <_MemCard>[];
    for (var i = 0; i < widget.round.deck.length; i++) {
      pairs.add(_MemCard('${i}a', widget.round.deck[i]));
      pairs.add(_MemCard('${i}b', widget.round.deck[i]));
    }
    pairs.shuffle(math.Random());
    _cards = pairs;
  }

  void _flip(int idx) {
    if (_busy || _flipped.contains(idx) || _matched.contains(_cards[idx].emoji)) return;
    setState(() => _flipped.add(idx));
    if (_flipped.length == 2) {
      _busy = true;
      final a = _flipped[0], b = _flipped[1];
      if (_cards[a].emoji == _cards[b].emoji) {
        Future.delayed(const Duration(milliseconds: 480), () {
          if (!mounted) return;
          setState(() {
            _matched.add(_cards[a].emoji);
            _flipped.clear();
            _busy = false;
          });
          context.read<FxController>().fire(score: 0, intensity: 'gentle');
          if (_matched.length == widget.round.deck.length) widget.onSolved();
        });
      } else {
        Future.delayed(const Duration(milliseconds: 850), () {
          if (!mounted) return;
          setState(() {
            _flipped.clear();
            _busy = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cols = _cards.length <= 8 ? 4 : 5;
    final pal = context.watch<AppState>().pal;
    return SizedBox(
      width: cols * 150.0,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < _cards.length; i++)
            _buildCard(i, _flipped.contains(i) || _matched.contains(_cards[i].emoji), _matched.contains(_cards[i].emoji), pal),
        ],
      ),
    );
  }

  Widget _buildCard(int i, bool up, bool matched, Palette pal) {
    return GestureDetector(
      onTap: () => _flip(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 130,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.md),
          gradient: up ? null : LinearGradient(colors: [pal.galaxy, pal.galaxyDeep], begin: Alignment.topLeft, end: Alignment.bottomRight),
          color: up ? C.card : null,
          boxShadow: Sh.sm,
          border: matched ? Border.all(color: const Color(0xFF15B886), width: 4) : null,
        ),
        child: up
            ? Img(_cards[i].emoji, size: 70)
            : Text('?', style: AppText.display(size: 54, weight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}

// ---------------- 5: Letters — match letter to picture ----------------
class LetterGame extends StatefulWidget {
  final Round round;
  final VoidCallback onSolved;
  const LetterGame({super.key, required this.round, required this.onSolved});
  @override
  State<LetterGame> createState() => _LetterGameState();
}

class _LetterGameState extends State<LetterGame> {
  bool _done = false;
  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final pal = context.watch<AppState>().pal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 200,
          height: 200,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(R.lg),
            gradient: LinearGradient(colors: [pal.brand, pal.brandDeep], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: Sh.md,
          ),
          child: Img(r.letter, display: r.letter, size: 150),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 30,
          runSpacing: 30,
          alignment: WrapAlignment.center,
          children: [
            for (final o in r.options)
              TapCard(
                correct: o.correct,
                locked: _done,
                onCorrect: () {
                  setState(() => _done = true);
                  widget.onSolved();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Img(o.emoji, size: 96),
                    const SizedBox(height: 8),
                    Text(o.label ?? '', style: AppText.display(size: 24, weight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------- 6: Sorting — drag into groups ----------------
class SortGame extends StatefulWidget {
  final Round round;
  final VoidCallback onSolved;
  const SortGame({super.key, required this.round, required this.onSolved});
  @override
  State<SortGame> createState() => _SortGameState();
}

class _SortGameState extends State<SortGame> {
  final Map<int, String> _placed = {};
  final Map<int, GlobalKey<ShakerState>> _keys = {};

  GlobalKey<ShakerState> _key(int i) => _keys.putIfAbsent(i, () => GlobalKey<ShakerState>());

  void _drop(String groupId, int idx) {
    if (_placed.containsKey(idx)) return;
    final item = widget.round.items[idx];
    if (item.group == groupId) {
      setState(() => _placed[idx] = groupId);
      context.read<FxController>().fire(score: 0, intensity: 'gentle');
      if (_placed.length == widget.round.items.length) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) widget.onSolved();
        });
      }
    } else {
      _key(idx).currentState?.shake();
      _wrongVo(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    final pal = context.watch<AppState>().pal;
    final unplaced = [for (int i = 0; i < r.items.length; i++) i].where((i) => !_placed.containsKey(i)).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 30,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            for (final g in r.groups)
              DragTarget<int>(
                onAcceptWithDetails: (d) => _drop(g.id, d.data),
                builder: (context, cand, rej) => Container(
                  width: 280,
                  constraints: const BoxConstraints(minHeight: 230),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: C.card,
                    borderRadius: BorderRadius.circular(R.lg),
                    boxShadow: Sh.sm,
                    border: Border.all(color: cand.isNotEmpty ? pal.brand : C.line, width: 3),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Img(g.emoji, size: 48),
                          const SizedBox(width: 10),
                          Text(g.label, style: AppText.display(size: 28, weight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final e in _placed.entries.where((e) => e.value == g.id))
                            Img(r.items[e.key].emoji, size: 56),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 50),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            for (final idx in unplaced)
              Draggable<int>(
                data: idx,
                feedback: Img(r.items[idx].emoji, size: 84),
                childWhenDragging: Opacity(opacity: .3, child: Img(r.items[idx].emoji, size: 70)),
                child: Shaker(key: _key(idx), child: Img(r.items[idx].emoji, size: 70)),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------- 7: Science — fact then question ----------------
class ScienceGame extends StatefulWidget {
  final Round round;
  final VoidCallback onSolved;
  const ScienceGame({super.key, required this.round, required this.onSolved});
  @override
  State<ScienceGame> createState() => _ScienceGameState();
}

class _ScienceGameState extends State<ScienceGame> {
  String _phase = 'fact';
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    if (_phase == 'fact') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.lg), boxShadow: Sh.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Img(r.factEmoji ?? '', size: 130),
                const SizedBox(height: 20),
                Text(r.fact ?? '', textAlign: TextAlign.center, style: AppText.display(size: 40, weight: FontWeight.w800)),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => context.read<VoService>().play('${r.id}-fact', r.factVo),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up_rounded, color: C.inkSoft),
                      const SizedBox(width: 8),
                      Text('Hear it', style: AppText.body(size: 24, weight: FontWeight.w700, color: C.inkSoft)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          KidButton(
            large: true,
            onTap: () {
              final vo = context.read<VoService>();
              setState(() => _phase = 'question');
              Future.delayed(const Duration(milliseconds: 350), () {
                if (mounted) vo.play('${r.id}-q', r.qVo);
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [const Text('Got it!'), const SizedBox(width: 12), const Icon(Icons.arrow_forward_rounded)],
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (r.prompt != null)
          Text(r.prompt!, style: AppText.display(size: 38, weight: FontWeight.w700)),
        const SizedBox(height: 36),
        Wrap(
          spacing: 30,
          runSpacing: 30,
          alignment: WrapAlignment.center,
          children: [
            for (final o in r.options)
              TapCard(
                correct: o.correct,
                locked: _done,
                onCorrect: () {
                  setState(() => _done = true);
                  widget.onSolved();
                },
                child: Img(o.emoji, size: 110),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------- Reward reveal ----------------
class RewardReveal extends StatefulWidget {
  final String planetId;
  final VoidCallback onDone;
  const RewardReveal({super.key, required this.planetId, required this.onDone});

  @override
  State<RewardReveal> createState() => _RewardRevealState();
}

class _RewardRevealState extends State<RewardReveal> {
  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    context.read<FxController>().fire(intensity: app.celebration);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final line = kRewardVo[widget.planetId]!;
      context.read<VoService>().play(line.id, line.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final planet = planetById(widget.planetId);
    final app = context.watch<AppState>();
    return Positioned.fill(
      child: ColoredBox(
        color: C.inkA(.5),
        child: Center(
          child: _Pop(
            child: Container(
              padding: const EdgeInsets.fromLTRB(60, 50, 60, 50),
              decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(R.xl), boxShadow: Sh.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('NEW PLANET!', style: AppText.kicker.copyWith(color: app.pal.brand, fontSize: 24)),
                  const SizedBox(height: 20),
                  Planet(data: planet, size: 260, spin: true),
                  const SizedBox(height: 20),
                  Text('You unlocked ${planet.name}!', style: AppText.h2),
                  const SizedBox(height: 16),
                  if (app.mascot) const Robo(size: 120, pose: 'cheer'),
                  const SizedBox(height: 24),
                  KidButton(
                    large: true,
                    onTap: widget.onDone,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [const Text('Yay!'), const SizedBox(width: 12), const Icon(Icons.arrow_forward_rounded)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pop extends StatefulWidget {
  final Widget child;
  const _Pop({required this.child});
  @override
  State<_Pop> createState() => _PopState();
}

class _PopState extends State<_Pop> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420))..forward();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.elasticOut)),
      child: widget.child,
    );
  }
}
