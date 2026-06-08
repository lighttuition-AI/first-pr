import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';

/// Top-3 winners overlay shown once per session on login. Podium order is
/// Rank2 (Gold) · Rank1 (Platinum, raised & larger) · Rank3 (Silver).
Future<void> showTop3(BuildContext context) {
  return Navigator.of(context).push(PageRouteBuilder(
    opaque: true,
    barrierDismissible: false,
    transitionDuration: FC.durSlow,
    pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const _Top3Page()),
  ));
}

class _Podium {
  final String tier;
  final int rank, rating;
  final Player p;
  const _Podium(this.tier, this.rank, this.rating, this.p);
}

class _Top3Page extends StatefulWidget {
  const _Top3Page();
  @override
  State<_Top3Page> createState() => _Top3PageState();
}

class _Top3PageState extends State<_Top3Page> with SingleTickerProviderStateMixin {
  final _confetti = ConfettiController(duration: const Duration(milliseconds: 2600));
  late final AnimationController _enter =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();

  late final List<_Podium> _podium = [
    _Podium('platinum', 1, 96, Seed.byId('p02')),
    _Podium('gold', 2, 93, Seed.byId('p01')),
    _Podium('silver', 3, 91, Seed.byId('p03')),
  ];

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
                        const Eyebrow('Champion', color: FC.warning),
                        const SizedBox(height: 3),
                        Text(_podium[0].p.short, style: FCType.heading(size: 18, weight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('96 OVR · Platinum card unlocked', style: FCType.mono(size: 12, color: FC.text2)),
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
