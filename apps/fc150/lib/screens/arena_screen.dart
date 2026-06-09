import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/seed_data.dart';
import '../flows/challenge_flow.dart';
import '../flows/result_submit.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';

class ArenaScreen extends StatefulWidget {
  const ArenaScreen({super.key});
  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen> {
  String _tab = 'pool';

  @override
  Widget build(BuildContext context) {
    final pool = Seed.players.where((p) => p.id != 'p01').toList();
    final active = [
      (opp: Seed.byId('p06'), mode: '1v1', when: 'Today · 20:30', status: 'locked'),
      (opp: Seed.byId('p10'), mode: '1v1', when: 'Fri · 21:30', status: 'pending'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('The arena'),
        const SizedBox(height: 2),
        Text('Challenge pool', style: FCType.heading(size: 23, weight: FontWeight.w800)),
        const SizedBox(height: 14),
        // Generic entry — opens the 1v1 / 2v2 (team match) chooser.
        GButton('New challenge', full: true, icon: LucideIcons.swords, onTap: () => showChallengeFlow(context)),
        const SizedBox(height: 14),
        Segmented(
          tabs: const [MapEntry('pool', 'Pool'), MapEntry('active', 'Active'), MapEntry('done', 'History')],
          value: _tab,
          onChange: (v) => setState(() => _tab = v),
        ),
        const SizedBox(height: 16),
        if (_tab == 'pool')
          for (final p in pool) ...[_poolRow(p), const SizedBox(height: 9)],
        if (_tab == 'active')
          for (final m in active) ...[_activeRow(m), const SizedBox(height: 9)],
        if (_tab == 'done')
          for (final r in Seed.results) ...[_resultRow(r), const SizedBox(height: 9)],
      ],
    );
  }

  Widget _poolRow(Player p) {
    return Surface(
      child: Row(
        children: [
          AvatarInitials(initials: p.initials, size: 42),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.short, style: FCType.body(size: 14, weight: FontWeight.w600, height: 1.2)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    FlagBands(width: 16, bands: Seed.flagOf(p.country)),
                    const SizedBox(width: 6),
                    Text('${p.pos} · ${p.rating} OVR', style: FCType.mono(size: 11, color: FC.text2)),
                  ],
                ),
              ],
            ),
          ),
          GButton('Challenge', size: 'sm', icon: LucideIcons.swords, onTap: () => showChallengeFlow(context, preset: p)),
        ],
      ),
    );
  }

  Widget _activeRow(({Player opp, String mode, String when, String status}) m) {
    final locked = m.status == 'locked';
    return Surface(
      glow: locked,
      borderColor: locked ? const Color(0x4D00D8D6) : null,
      child: Column(
        children: [
          Row(
            children: [
              AvatarInitials(initials: m.opp.initials, size: 40),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('vs ${m.opp.short}', style: FCType.body(size: 14, weight: FontWeight.w600, height: 1.2)),
                    Text('${m.mode} · ${m.when}', style: FCType.mono(size: 11, color: FC.text2)),
                  ],
                ),
              ),
              StatusPill(m.status),
            ],
          ),
          if (locked) ...[
            const SizedBox(height: 11),
            GButton('Submit result', full: true, size: 'md', variant: GBtn.teal, icon: LucideIcons.flag, onTap: () => showResultSubmit(context, m.opp)),
          ],
        ],
      ),
    );
  }

  Widget _resultRow(MatchResult r) {
    final a = Seed.byId(r.a), b = Seed.byId(r.b);
    return Surface(
      child: Row(
        children: [
          Expanded(child: Text(a.short, textAlign: TextAlign.right, style: FCType.body(size: 13.5, weight: FontWeight.w600))),
          const SizedBox(width: 10),
          _score('${r.sa}–${r.sb}'),
          const SizedBox(width: 10),
          Expanded(child: Text(b.short, style: FCType.body(size: 13.5, weight: FontWeight.w600))),
        ],
      ),
    );
  }
}

Widget scoreChip(String s) => _score(s);

Widget _score(String s) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: FC.overlay,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FC.borderStrong),
      ),
      child: Text(s, style: FCType.mono(size: 16, weight: FontWeight.w800)),
    );
