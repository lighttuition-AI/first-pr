import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../data/standings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';

/// Top-3 winners overlay shown once per session on login. Podium order is
/// Rank2 (Gold) · Rank1 (Platinum, raised & larger) · Rank3 (Silver).
///
/// What it shows depends on the Premier League season state:
///  - **Pre-season** (no season started / no drafted players): a teaser with
///    **random names** — never the seed player Khadar Agab.
///  - **Season started, no games played:** the drafted players in **alphabetical
///    order**, top 3.
///  - **After the first result:** the **live standings** leader board (best
///    points → goal difference), top 3.
/// Any short list is padded to three with random placeholders so the podium
/// always renders cleanly.
Future<void> showTop3(BuildContext context) {
  final data = _resolvePodium(context.read<AppState>());
  return Navigator.of(context).push(PageRouteBuilder(
    opaque: true,
    barrierDismissible: false,
    transitionDuration: FC.durSlow,
    pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: _Top3Page(data: data)),
  ));
}

class _Podium {
  final String tier;
  final int rank, rating;
  final Player p;
  const _Podium(this.tier, this.rank, this.rating, this.p);
}

class _PodiumData {
  final List<_Podium> podium; // rank order: [1st, 2nd, 3rd]
  final String leaderEyebrow;
  final String leaderSub;
  const _PodiumData(this.podium, this.leaderEyebrow, this.leaderSub);
}

// Placeholder names for the pre-season teaser. None is the seed player (Khadar
// Agab) — and the country codes all exist in Seed.flags so the cards show a flag.
const List<({String short, String cc})> _placeholderNames = [
  (short: 'Marco Bellini', cc: 'IT'),
  (short: 'Caio Ribeiro', cc: 'BR'),
  (short: 'Diego Álvarez', cc: 'MX'),
  (short: 'Tiago Sousa', cc: 'PT'),
  (short: 'Erik Lindqvist', cc: 'SE'),
  (short: 'Kenji Sato', cc: 'JP'),
  (short: 'Tomáš Novák', cc: 'CZ'),
  (short: 'Omar Jama', cc: 'SO'),
  (short: 'Lamine Diop', cc: 'SN'),
  (short: 'Daan Visser', cc: 'NL'),
  (short: 'Lucas Moretti', cc: 'IT'),
  (short: 'Bruno Costa', cc: 'BR'),
];

Player _placeholder(int i, String short, String cc, int rating) {
  const positions = ['ATT', 'MID', 'DEF'];
  final last = short.split(' ').last.toUpperCase();
  return Player(
    id: 'ph_$i',
    name: short.toUpperCase(),
    short: short,
    country: cc,
    pos: positions[i % positions.length],
    psn: '${last}_${10 + i}',
    rating: rating,
    stats: Stats(
      pac: (rating - 2).clamp(40, 99),
      sho: rating.clamp(40, 99),
      pas: (rating - 6).clamp(40, 99),
      dri: (rating - 1).clamp(40, 99),
      def: (rating - 22).clamp(30, 99),
      phy: (rating - 8).clamp(40, 99),
    ),
  );
}

_PodiumData _resolvePodium(AppState app) {
  const compId = 'pl';
  final started = app.seasonStarted(compId);
  final entrants = app.rosterFor(compId).map(Seed.byId).toList();
  final results = Seed.results.where((r) => r.comp == compId && r.status == 'confirmed').toList();

  List<Player> top;
  String eyebrow, sub;

  if (!started || entrants.isEmpty) {
    // First-time / pre-season teaser — all random names.
    top = const [];
    eyebrow = 'Pre-season';
    sub = 'The race hasn’t kicked off yet';
  } else if (results.isEmpty) {
    // Season started, nothing played — drafted players in alphabetical order.
    top = [...entrants]..sort((a, b) => a.short.toLowerCase().compareTo(b.short.toLowerCase()));
    eyebrow = 'Season start';
    sub = 'Alphabetical until the first result';
  } else {
    // Live standings — best points → goal difference first (real players only).
    final table = computeLeague(entrants: entrants, results: results, started: started);
    top = [for (final e in table) if (e.player != null) e.player!];
    eyebrow = 'League leader';
    sub = 'Top of the table';
  }

  // Always render three cards — pad a short list with shuffled placeholders.
  final rnd = Random();
  final pool = List.of(_placeholderNames)..shuffle(rnd);
  const tiers = ['platinum', 'gold', 'silver'];
  const phRatings = [96, 93, 91];
  final podium = <_Podium>[];
  var ph = 0;
  for (var i = 0; i < 3; i++) {
    final Player p;
    final int rating;
    if (i < top.length) {
      p = top[i];
      rating = p.rating;
    } else {
      final n = pool[ph % pool.length];
      rating = (phRatings[i] - rnd.nextInt(3)).clamp(40, 99);
      p = _placeholder(ph, n.short, n.cc, rating);
      ph++;
    }
    podium.add(_Podium(tiers[i], i + 1, rating, p));
  }
  return _PodiumData(podium, eyebrow, sub);
}

class _Top3Page extends StatefulWidget {
  final _PodiumData data;
  const _Top3Page({required this.data});
  @override
  State<_Top3Page> createState() => _Top3PageState();
}

class _Top3PageState extends State<_Top3Page> with SingleTickerProviderStateMixin {
  final _confetti = ConfettiController(duration: const Duration(milliseconds: 2600));
  late final AnimationController _enter =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();

  List<_Podium> get _podium => widget.data.podium;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 350), () {
      if (mounted) _confetti.play();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _enter.dispose();
    super.dispose();
  }

  Color _tierColor(String t) =>
      t == 'platinum' ? const Color(0xFF8FF6FF) : t == 'gold' ? const Color(0xFFFFD874) : const Color(0xFFFAFBFE);

  @override
  Widget build(BuildContext context) {
    // display order: rank2, rank1, rank3
    final display = [_podium[1], _podium[0], _podium[2]];
    return Scaffold(
      backgroundColor: FC.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.2,
            colors: [Color(0x2E7C6CF8), Color(0xEB040409)],
            stops: [0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 16),
                  const Eyebrow('Premier League · 2025/26', color: FC.teal),
                  const SizedBox(height: 6),
                  Text('Top 3 of the season', style: FCType.heading(size: 23, weight: FontWeight.w800)),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (int i = 0; i < display.length; i++)
                              _PodiumCard(
                                item: display[i],
                                color: _tierColor(display[i].tier),
                                anim: _enter,
                                index: i,
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Eyebrow(widget.data.leaderEyebrow, color: FC.warning),
                        const SizedBox(height: 3),
                        Text(_podium[0].p.short, style: FCType.heading(size: 18, weight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('${_podium[0].rating} OVR · ${widget.data.leaderSub}',
                            style: FCType.mono(size: 12, color: FC.text2)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
                    child: GButton('Enter the arena',
                        full: true, icon: LucideIcons.arrowRight, onTap: () => Navigator.of(context).pop()),
                  ),
                ],
              ),
              Align(alignment: const Alignment(0, -0.5), child: FCConfetti(_confetti)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final _Podium item;
  final Color color;
  final Animation<double> anim;
  final int index;
  const _PodiumCard({required this.item, required this.color, required this.anim, required this.index});

  @override
  Widget build(BuildContext context) {
    final raised = item.rank == 1;
    final restY = raised ? -14.0 : 6.0;
    final start = (0.12 + index * 0.18).clamp(0.0, 0.6);
    final slide = CurvedAnimation(parent: anim, curve: Interval(start, (start + 0.4).clamp(0.0, 1.0), curve: FC.easeOut));

    return AnimatedBuilder(
      animation: slide,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, restY + (1 - slide.value) * 22),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FCCard(
                variant: 'platinum',
                tier: item.tier,
                rating: item.rating,
                name: item.p.name,
                pos: item.p.pos,
                psn: item.p.psn,
                stats: item.p.stats,
                flagBands: Seed.flagOf(item.p.country),
                width: raised ? 122 : 102,
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FC.bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                  boxShadow: [BoxShadow(color: color, blurRadius: 12, spreadRadius: -2)],
                ),
                child: Text('${item.rank}', style: FCType.mono(size: 12, weight: FontWeight.w800, color: color)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
