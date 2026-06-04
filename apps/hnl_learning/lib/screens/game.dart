// Mini-games — the shared game shell + all 7 playable games.
// Correct → +8 score, confetti, stars, Robo cheer, then advance /
// reward reveal. Wrong → the element shakes and Robo says "try again".
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';
import '../widgets/planet.dart';
import '../widgets/robo.dart';
import '../widgets/shaker.dart';
import '../widgets/speech_bubble.dart';

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
              child: widget.game.type == GameType.alphabet
                  // The board fills the area and scrolls; other games center.
                  ? const AlphabetBoard()
                  : Center(
                      child: _GameBody(
                          key: ValueKey(_roundIdx), game: widget.game, round: round, onSolved: _onSolved),
                    ),
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
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(R.pill), boxShadow: Sh.sm),
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
                if (widget.game.type != GameType.alphabet) ...[
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(R.pill), boxShadow: Sh.sm),
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
        color: Colors.white,
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
                color: Colors.white,
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
                        color: _done ? Colors.white : C.inkA(.03),
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
          color: Colors.white,
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
          color: up ? Colors.white : null,
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
                    color: Colors.white,
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(R.lg), boxShadow: Sh.md),
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
                      const Icon(Icons.volume_up_rounded, color: C.inkSoft),
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
