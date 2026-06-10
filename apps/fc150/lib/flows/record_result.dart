import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Admin: record a confirmed head-to-head result between two drafted players.
/// The result feeds the competition's standings. [onConfirm] gets
/// (playerAId, playerBId, scoreA, scoreB).
void showRecordResultSheet(
  BuildContext context, {
  required String compName,
  required List<Player> entrants,
  required void Function(String aId, String bId, int sa, int sb) onConfirm,
}) {
  showFcSheet(context, builder: (_) => _RecordResult(compName: compName, entrants: entrants, onConfirm: onConfirm));
}

class _RecordResult extends StatefulWidget {
  final String compName;
  final List<Player> entrants;
  final void Function(String aId, String bId, int sa, int sb) onConfirm;
  const _RecordResult({required this.compName, required this.entrants, required this.onConfirm});
  @override
  State<_RecordResult> createState() => _RecordResultState();
}

class _RecordResultState extends State<_RecordResult> {
  String? _a, _b;
  int _sa = 0, _sb = 0;
  String _slot = 'a'; // which side the next list tap fills

  bool get _ready => _a != null && _b != null && _a != _b;

  void _pick(String id) {
    setState(() {
      if (_slot == 'a') {
        _a = id;
        if (_b == null || _b == id) _slot = 'b';
      } else {
        _b = id;
        if (_a == null || _a == id) _slot = 'a';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entrants.length < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Eyebrow('Record result', color: FC.purple300),
          const SizedBox(height: 8),
          Text(widget.compName, style: FCType.heading(size: 19, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          Surface(child: Center(child: Text('Draft at least two players into this competition first.', textAlign: TextAlign.center, style: FCType.body(size: 13, color: FC.text2)))),
          const SizedBox(height: 6),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(11)),
              child: const Icon(LucideIcons.flag, size: 20, color: FC.purple300),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Record result', color: FC.purple300),
                  const SizedBox(height: 2),
                  Text(widget.compName, style: FCType.heading(size: 19, weight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Scoreboard — the two chosen players + a score stepper each.
        Row(
          children: [
            Expanded(child: _side('a', _a, _sa, (v) => setState(() => _sa = v))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('–', style: FCType.heading(size: 20, weight: FontWeight.w800, color: FC.text2))),
            Expanded(child: _side('b', _b, _sb, (v) => setState(() => _sb = v))),
          ],
        ),
        const SizedBox(height: 14),
        Align(alignment: Alignment.centerLeft, child: SectionTitle(_slot == 'a' ? 'Choose home player' : 'Choose away player')),
        const SizedBox(height: 9),
        for (final p in widget.entrants) ...[_playerOption(p), const SizedBox(height: 8)],
        const SizedBox(height: 4),
        GButton(
          'Save result',
          variant: GBtn.primary,
          icon: LucideIcons.check,
          full: true,
          disabled: !_ready,
          onTap: !_ready
              ? null
              : () {
                  widget.onConfirm(_a!, _b!, _sa, _sb);
                  Navigator.of(context).maybePop();
                },
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _side(String slot, String? id, int score, ValueChanged<int> onScore) {
    final active = _slot == slot;
    final p = id == null ? null : widget.entrants.firstWhere((e) => e.id == id, orElse: () => widget.entrants.first);
    return Surface(
      onTap: () => setState(() => _slot = slot),
      borderColor: active ? FC.borderFocus : null,
      child: Column(
        children: [
          Text(p?.short ?? (slot == 'a' ? 'Home' : 'Away'),
              maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.body(size: 12.5, weight: FontWeight.w700, color: p == null ? FC.textMuted : FC.text)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepBtn(LucideIcons.minus, () => onScore((score - 1).clamp(0, 99))),
              SizedBox(width: 34, child: Text('$score', textAlign: TextAlign.center, style: FCType.mono(size: 22, weight: FontWeight.w800))),
              _stepBtn(LucideIcons.plus, () => onScore((score + 1).clamp(0, 99))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: FC.text),
        ),
      );

  Widget _playerOption(Player p) {
    final isA = _a == p.id, isB = _b == p.id;
    final tag = isA ? 'HOME' : (isB ? 'AWAY' : null);
    return Surface(
      onTap: () => _pick(p.id),
      borderColor: (isA || isB) ? FC.borderFocus : null,
      child: Row(
        children: [
          AvatarInitials(initials: p.initials, size: 36, photo: p.photo, expandable: false),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.short, style: FCType.body(size: 13.5, weight: FontWeight.w600, height: 1.2)),
                Text('${p.pos} · ${p.rating} OVR', style: FCType.mono(size: 11, color: FC.text2)),
              ],
            ),
          ),
          if (tag != null) Pill(tag, tone: PillTone.neutral),
        ],
      ),
    );
  }
}
