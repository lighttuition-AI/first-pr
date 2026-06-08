import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Submit-result sheet: two steppers (You : Opponent) → confirmation state.
Future<void> showResultSubmit(BuildContext context, Player opp) {
  return showFcSheet(context, builder: (_) => _ResultSubmit(opp: opp));
}

class _ResultSubmit extends StatefulWidget {
  final Player opp;
  const _ResultSubmit({required this.opp});
  @override
  State<_ResultSubmit> createState() => _ResultSubmitState();
}

class _ResultSubmitState extends State<_ResultSubmit> {
  int _sa = 3, _sb = 1;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: FC.successTint,
                shape: BoxShape.circle,
                border: Border.all(color: FC.success, width: 2),
              ),
              child: const Icon(LucideIcons.check, size: 32, color: FC.success),
            ),
            const SizedBox(height: 14),
            Text('Score submitted', style: FCType.heading(size: 20, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 270),
              child: Text(
                'Waiting for ${widget.opp.short} to confirm. Auto-approves in 12h if no response. Rating change applies once confirmed.',
                textAlign: TextAlign.center,
                style: FCType.body(size: 13, color: FC.text2),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Submit result', style: FCType.heading(size: 20, weight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Enter the final score from your PS5 match', style: FCType.body(size: 13, color: FC.text2)),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _scoreColumn('You', _sa, (v) => setState(() => _sa = v)),
              Text(':', style: FCType.mono(size: 22, weight: FontWeight.w700, color: FC.textMuted)),
              _scoreColumn(widget.opp.short.split(' ').first, _sb, (v) => setState(() => _sb = v)),
            ],
          ),
        ),
        GButton('Submit for confirmation', full: true, icon: LucideIcons.send, onTap: () => setState(() => _done = true)),
      ],
    );
  }

  Widget _scoreColumn(String label, int v, ValueChanged<int> set) {
    return Column(
      children: [
        Text(label, style: FCType.body(size: 12, weight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stepBtn('−', () => set((v - 1).clamp(0, 99))),
            const SizedBox(width: 14),
            SizedBox(width: 34, child: Text('$v', textAlign: TextAlign.center, style: FCType.mono(size: 30, weight: FontWeight.w800))),
            const SizedBox(width: 14),
            _stepBtn('+', () => set(v + 1)),
          ],
        ),
      ],
    );
  }

  Widget _stepBtn(String t, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: FC.overlay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: FC.borderStrong),
        ),
        child: Text(t, style: FCType.mono(size: 22, weight: FontWeight.w600)),
      ),
    );
  }
}
