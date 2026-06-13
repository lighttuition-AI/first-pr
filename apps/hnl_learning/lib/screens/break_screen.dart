// Session break — friendly "time for a break" with a stat recap.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/kid_button.dart';
import '../widgets/robo.dart';
import '../widgets/speech_bubble.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({super.key});
  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  @override
  void initState() {
    super.initState();
    final v = kScreenVo['break']!;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) context.read<VoService>().play(v.id, v.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final v = kScreenVo['break']!;
    return Container(
      color: app.pal.brandSoft,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (app.mascot) const Robo(size: 200, pose: 'idle'),
            const SizedBox(height: 6),
            SpeechBubble(
              text: 'Great job — time for a break!',
              tail: Tail.down,
              voId: v.id,
              voText: v.text,
            ),
            const SizedBox(height: 24),
            Text('You earned a break! 🌿', style: AppText.h1),
            const SizedBox(height: 10),
            Text('Stretch, blink, sip some water. Your stars are saved.',
                style: AppText.lead.copyWith(fontSize: 30)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stat('${app.stars}', '⭐ stars'),
                _stat('~${app.sessionLen}', '⏱ minutes'),
              ],
            ),
            const SizedBox(height: 36),
            KidButton(large: true, onTap: () => app.go('home'), child: const Text('Back to map')),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.lg), boxShadow: Sh.sm),
        child: Column(
          children: [
            Text(value, style: AppText.display(size: 46, weight: FontWeight.w800)),
            Text(label, style: AppText.body(size: 22, weight: FontWeight.w700, color: C.inkSoft)),
          ],
        ),
      );
}
