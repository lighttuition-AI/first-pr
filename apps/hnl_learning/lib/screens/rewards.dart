// Rewards — the planet collection (9 cells) + reveal modal.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/kid_button.dart';
import '../widgets/planet.dart';
import '../widgets/robo.dart';
import '../widgets/speech_bubble.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  PlanetData? _active;

  @override
  void initState() {
    super.initState();
    final v = kScreenVo['rewards']!;
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) context.read<VoService>().play(v.id, v.text);
    });
  }

  Game? _gameForPlanet(String pid) {
    try {
      return kGames.firstWhere((g) => g.reward == pid);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final v = kScreenVo['rewards']!;
    final owned = app.planets;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -1),
          radius: 1.3,
          colors: [const Color(0xFFEAF0FF), C.paper],
          stops: const [0, .6],
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                child: Row(
                  children: [
                    IconCircle(Icons.arrow_back_rounded, onTap: () => app.go('home')),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪐', style: TextStyle(fontSize: 40)),
                        const SizedBox(width: 12),
                        Text('My Planets', style: AppText.h2),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.pill), boxShadow: Sh.sm),
                      child: Text('${owned.length}/${kPlanets.length}',
                          style: AppText.display(size: 28, weight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 26,
                      runSpacing: 26,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final p in kPlanets) _cell(p, owned.contains(p.id)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (app.mascot) Robo(size: 130, pose: owned.isNotEmpty ? 'cheer' : 'idle'),
                    const SizedBox(width: 6),
                    SpeechBubble(
                      text: owned.isNotEmpty
                          ? 'Wow, ${owned.length} ${owned.length == 1 ? "planet" : "planets"}!'
                          : 'Play games to collect planets!',
                      tail: Tail.down,
                      voId: v.id,
                      voText: v.text,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_active != null) _revealModal(app),
        ],
      ),
    );
  }

  Widget _cell(PlanetData p, bool owned) {
    return GestureDetector(
      onTap: owned ? () => setState(() => _active = p) : null,
      child: Container(
        width: 210,
        height: 210,
        decoration: BoxDecoration(
          color: owned ? C.card : C.inkA(.03),
          borderRadius: BorderRadius.circular(R.lg),
          boxShadow: owned ? Sh.sm : null,
          border: owned ? null : Border.all(color: C.line, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Planet(data: p, size: 130, faded: !owned, spin: owned),
                if (!owned) const Text('🔒', style: TextStyle(fontSize: 40)),
              ],
            ),
            const SizedBox(height: 8),
            Text(owned ? p.name : '???',
                style: AppText.display(size: 26, weight: FontWeight.w700, color: owned ? C.ink : C.muted)),
          ],
        ),
      ),
    );
  }

  Widget _revealModal(AppState app) {
    final p = _active!;
    final game = _gameForPlanet(p.id);
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _active = null),
        child: ColoredBox(
          color: C.inkA(.5),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.fromLTRB(60, 50, 60, 50),
                decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(R.xl), boxShadow: Sh.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Planet(data: p, size: 260, spin: true),
                    const SizedBox(height: 20),
                    Text(p.name, style: AppText.h2),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        style: AppText.lead.copyWith(fontSize: 26),
                        children: [
                          const TextSpan(text: 'Earned in '),
                          TextSpan(text: game?.title ?? 'a game', style: const TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    KidButton(
                      large: true,
                      onTap: () {
                        setState(() => _active = null);
                        if (game != null) app.startGame(game.id);
                      },
                      child: const Text('Play again'),
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
