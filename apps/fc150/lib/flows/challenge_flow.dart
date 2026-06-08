import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Opens the multi-step challenge bottom sheet. [preset] skips the opponent
/// step (launched from a player's card); [autoLock] jumps straight to the
/// "match locked" confirmation (accepting an invite).
Future<void> showChallengeFlow(
  BuildContext context, {
  Player? preset,
  String? presetSlot,
  bool autoLock = false,
}) {
  return showFcSheet(
    context,
    dismissible: !autoLock,
    builder: (_) => _ChallengeSheet(preset: preset, presetSlot: presetSlot, autoLock: autoLock),
  );
}

class _ChallengeSheet extends StatefulWidget {
  final Player? preset;
  final String? presetSlot;
  final bool autoLock;
  const _ChallengeSheet({this.preset, this.presetSlot, this.autoLock = false});

  @override
  State<_ChallengeSheet> createState() => _ChallengeSheetState();
}

class _ChallengeSheetState extends State<_ChallengeSheet> {
  late int _step = widget.preset != null ? 2 : 0;
  String _mode = '1v1';
  late Player? _opp = widget.preset;
  late String _slot = widget.presetSlot ?? 'Today · 20:30';
  late bool _sent = widget.autoLock;

  static const _slots = ['Today · 20:30', 'Today · 22:00', 'Tomorrow · 19:00', 'Tomorrow · 21:30', 'Sat · 18:00'];

  @override
  void initState() {
    super.initState();
    if (widget.autoLock) {
      Timer(const Duration(milliseconds: 1800), _closeIfMounted);
    }
  }

  void _closeIfMounted() {
    if (mounted) Navigator.of(context).maybePop();
  }

  void _send() {
    setState(() => _sent = true);
    Timer(const Duration(milliseconds: 1700), _closeIfMounted);
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) return _locked();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepper(),
        const SizedBox(height: 16),
        if (_step == 0) _typeStep(),
        if (_step == 1) _opponentStep(),
        if (_step == 2) _timeStep(),
        if (_step == 3) _confirmStep(),
      ],
    );
  }

  Widget _stepper() => Row(
        children: [
          for (int i = 0; i < 4; i++) ...[
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: i <= _step ? FC.gradient : null,
                  color: i <= _step ? null : FC.overlay,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 6),
          ],
        ],
      );

  Widget _heading(String title, [String? sub]) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FCType.heading(size: 20, weight: FontWeight.w800)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub, style: FCType.body(size: 13, color: FC.text2)),
          ],
        ],
      );

  Widget _typeStep() {
    Widget tile(String m, IconData ic, String sub) {
      final sel = _mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _mode = m),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: sel ? FC.purpleTint : FC.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sel ? FC.borderFocus : FC.border),
              boxShadow: sel ? FC.glowPurpleSm : null,
            ),
            child: Column(
              children: [
                Icon(ic, size: 26, color: sel ? FC.purple300 : FC.text2),
                const SizedBox(height: 8),
                Text(m, style: FCType.heading(size: 18, weight: FontWeight.w800)),
                Text(sub, style: FCType.body(size: 12, color: FC.text2, height: 1.2)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Challenge type', 'How do you want to play?'),
        const SizedBox(height: 16),
        Row(children: [
          tile('1v1', LucideIcons.user, 'Solo duel'),
          const SizedBox(width: 12),
          tile('2v2', LucideIcons.users, 'Team match'),
        ]),
        const SizedBox(height: 18),
        GButton('Continue', full: true, icon: LucideIcons.arrowRight, onTap: () => setState(() => _step = 1)),
      ],
    );
  }

  Widget _opponentStep() {
    final pool = Seed.players.where((p) => p.id != 'p01').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Pick opponent', 'Available in the $_mode pool right now'),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: pool.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _PoolPickRow(
              p: pool[i],
              selected: _opp?.id == pool[i].id,
              onTap: () => setState(() => _opp = pool[i]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GButton('Continue', full: true, icon: LucideIcons.arrowRight, disabled: _opp == null, onTap: () => setState(() => _step = 2)),
      ],
    );
  }

  Widget _timeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Propose a time', 'vs ${_opp?.short ?? '—'} · $_mode'),
        const SizedBox(height: 14),
        for (final s in _slots) ...[
          GestureDetector(
            onTap: () => setState(() => _slot = s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                color: _slot == s ? FC.purpleTint : FC.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _slot == s ? FC.borderFocus : FC.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s, style: FCType.mono(size: 13.5, weight: FontWeight.w600)),
                  if (_slot == s) const Icon(LucideIcons.check, size: 18, color: FC.purple300),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        GButton('Review', full: true, icon: LucideIcons.arrowRight, onTap: () => setState(() => _step = 3)),
      ],
    );
  }

  Widget _confirmStep() {
    final rows = [
      ('Type', _mode),
      ('Opponent', _opp?.short ?? '—'),
      ('When', _slot),
      ('Console', 'PlayStation 5'),
      ('Competition', 'Friendly'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Confirm challenge'),
        const SizedBox(height: 14),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FC.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: FC.surface,
                    border: i < rows.length - 1 ? const Border(bottom: BorderSide(color: FC.border)) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rows[i].$1, style: FCType.body(size: 13, color: FC.text2)),
                      Text(rows[i].$2, style: FCType.body(size: 13.5, weight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "If your opponent doesn't show, you automatically win 3–0 and it counts to the league table and your card.",
          style: FCType.body(size: 12, color: FC.textMuted, height: 1.5),
        ),
        const SizedBox(height: 14),
        GButton('Send challenge', full: true, variant: GBtn.teal, icon: LucideIcons.swords, onTap: _send),
      ],
    );
  }

  Widget _locked() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: FC.tealTint,
                shape: BoxShape.circle,
                border: Border.all(color: FC.teal, width: 2),
                boxShadow: FC.glowTeal,
              ),
              child: const Icon(LucideIcons.lock, size: 34, color: FC.teal),
            ),
          ),
          const SizedBox(height: 18),
          const Eyebrow('Match locked', color: FC.teal),
          const SizedBox(height: 6),
          Text('Challenge confirmed', style: FCType.heading(size: 21, weight: FontWeight.w800)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'You vs ${_opp?.short ?? 'your opponent'} · $_slot. Both removed from the pool for this slot. Play it on PS5, then submit the score.',
              textAlign: TextAlign.center,
              style: FCType.body(size: 13.5, color: FC.text2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opponent picker row (avatar · name · pos·PSN · rating).
class _PoolPickRow extends StatelessWidget {
  final Player p;
  final bool selected;
  final VoidCallback onTap;
  const _PoolPickRow({required this.p, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? FC.purpleTint : FC.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? FC.borderFocus : FC.border),
        ),
        child: Row(
          children: [
            AvatarInitials(initials: p.initials, size: 38),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.short, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.body(size: 14, weight: FontWeight.w600, height: 1.2)),
                  Text('${p.pos} · PSN ${p.psn}', style: FCType.mono(size: 11.5, color: FC.text2)),
                ],
              ),
            ),
            Text('${p.rating}', style: FCType.mono(size: 16, weight: FontWeight.w700, color: FC.purple300)),
          ],
        ),
      ),
    );
  }
}
