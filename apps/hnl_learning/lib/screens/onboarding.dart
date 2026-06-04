// Parent onboarding — 3 modular, swappable steps (A/B/C).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/branding.dart';
import '../widgets/kid_button.dart';
import '../widgets/robo.dart';
import '../widgets/speech_bubble.dart';

const _stepBg = [C.cream, C.cream, Color(0xFFE7EFFF)];

class OnboardingScreen extends StatefulWidget {
  final int index;
  const OnboardingScreen({super.key, required this.index});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingStep data = kOnboarding[widget.index];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) context.read<VoService>().play('vo-onb-${data.id}', data.vo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pal = app.pal;
    final last = widget.index == kOnboarding.length - 1;
    final bg = widget.index == 0 ? pal.brandSoft : _stepBg[widget.index % 3];

    return Container(
      color: bg,
      child: Column(
        children: [
          SetupHeader(
            index: widget.index,
            total: kOnboarding.length,
            onBack: widget.index > 0 ? () => app.go('onb-${widget.index - 1}') : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(64, 10, 64, 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left — Robo + overlapping bubble
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpeechBubble(
                          text: data.title,
                          tail: Tail.left,
                          voId: 'vo-onb-${data.id}',
                          voText: data.vo,
                        ),
                        const SizedBox(height: 4),
                        if (app.mascot) const Robo(size: 260, pose: 'wave'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right — promise card
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(R.lg),
                        boxShadow: Sh.md,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STEP ${data.step} · FOR GROWN-UPS', style: AppText.kicker),
                          const SizedBox(height: 10),
                          Text(data.title,
                              style: AppText.display(size: 52, weight: FontWeight.w800, height: 1.05)),
                          const SizedBox(height: 24),
                          for (final p in data.promises) _PromiseRow(p),
                          const SizedBox(height: 26),
                          KidButton(
                            large: true,
                            onTap: () => app.go(last ? 'age' : 'onb-${widget.index + 1}'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(last ? 'Get started' : 'Continue'),
                                const SizedBox(width: 12),
                                const Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromiseRow extends StatelessWidget {
  final Promise p;
  const _PromiseRow(this.p);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: C.inkA(.04),
        borderRadius: BorderRadius.circular(R.md),
      ),
      child: Row(
        children: [
          Text(p.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(p.text, style: AppText.display(size: 27, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
