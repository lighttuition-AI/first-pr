import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../flows/challenge_flow.dart';
import '../flows/result_submit.dart';
import '../models/models.dart';
import '../state/app_state.dart';
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
    final app = context.watch<AppState>();
    final me = app.currentUser;
    final pool = Seed.players.where((p) => p.id != me.id).toList();
    final active = app.activeChallenges;
    final history = app.matchHistory;

    void challenge({Player? preset}) => showChallengeFlow(
          context,
          preset: preset,
          onConfirm: (opp, mode, when) => context.read<AppState>().addChallenge(opp.id, mode, when),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('The arena'),
        const SizedBox(height: 2),
        Text('Challenge pool', style: FCType.heading(size: 23, weight: FontWeight.w800)),
        const SizedBox(height: 14),
        GButton('New challenge', full: true, icon: LucideIcons.swords, onTap: () => challenge()),
        const SizedBox(height: 14),
        Segmented(
          tabs: [
            const MapEntry('pool', 'Pool'),
            MapEntry('active', 'Active${active.isEmpty ? '' : ' · ${active.length}'}'),
            const MapEntry('done', 'History'),
          ],
          value: _tab,
          onChange: (v) => setState(() => _tab = v),
        ),
        const SizedBox(height: 16),
        if (_tab == 'pool')
          for (final p in pool) ...[_poolRow(p, challenge), const SizedBox(height: 9)],
        if (_tab == 'active') ...[
          if (active.isEmpty)
            _empty(LucideIcons.swords, 'No active challenges', 'Tap “New challenge” to set one up.')
          else
            for (final m in active) ...[_activeRow(m), const SizedBox(height: 9)],
        ],
        if (_tab == 'done') ...[
          if (history.isEmpty)
            _empty(LucideIcons.flag, 'No matches played yet', 'Your confirmed results show up here.')
          else
            for (final h in history) ...[_historyRow(h), const SizedBox(height: 9)],
        ],
      ],
    );
  }

  Widget _empty(IconData icon, String title, String sub) => Surface(
        pad: 22,
        child: Column(
          children: [
            Icon(icon, size: 26, color: FC.textMuted),
            const SizedBox(height: 10),
            Text(title, style: FCType.body(size: 14, weight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(sub, textAlign: TextAlign.center, style: FCType.body(size: 12, color: FC.text2)),
          ],
        ),
      );

  Widget _poolRow(Player p, void Function({Player? preset}) challenge) {
    return Surface(
      child: Row(
        children: [
          AvatarInitials(initials: p.initials, size: 42, photo: p.photo, name: p.short),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.short, style: FCType.body(size: 14, weight: FontWeight.w600, height: 1.2)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    FlagBands(width: 18, code: p.country),
                    const SizedBox(width: 6),
                    Text('${p.pos} · ${p.rating} OVR', style: FCType.mono(size: 11, color: FC.text2)),
                  ],
                ),
              ],
            ),
          ),
          GButton('Challenge', size: 'sm', icon: LucideIcons.swords, onTap: () => challenge(preset: p)),
        ],
      ),
    );
  }

  Widget _activeRow(Map<String, dynamic> m) {
    final opp = Seed.byId(m['opp'] as String);
    final status = (m['status'] as String?) ?? 'locked';
    final locked = status == 'locked';
    return Surface(
      glow: locked,
      borderColor: locked ? const Color(0x4D00D8D6) : null,
      child: Column(
        children: [
          Row(
            children: [
              AvatarInitials(initials: opp.initials, size: 40, photo: opp.photo, name: opp.short),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('vs ${opp.short}', style: FCType.body(size: 14, weight: FontWeight.w600, height: 1.2)),
                    Text('${m['mode']} · ${m['when']}', style: FCType.mono(size: 11, color: FC.text2)),
                  ],
                ),
              ),
              StatusPill(status),
            ],
          ),
          if (locked) ...[
            const SizedBox(height: 11),
            GButton('Submit result', full: true, size: 'md', variant: GBtn.teal, icon: LucideIcons.flag, onTap: () => showResultSubmit(context, opp)),
          ],
        ],
      ),
    );
  }

  Widget _historyRow(Map<String, dynamic> h) {
    final opp = Seed.byId(h['opp'] as String);
    final sa = h['sa'] as int, sb = h['sb'] as int;
    final won = sa > sb;
    return Surface(
      child: Row(
        children: [
          Expanded(child: Text('You', textAlign: TextAlign.right, style: FCType.body(size: 13.5, weight: won ? FontWeight.w700 : FontWeight.w500, color: won ? Colors.white : FC.text2))),
          const SizedBox(width: 10),
          _score('$sa–$sb'),
          const SizedBox(width: 10),
          Expanded(child: Text(opp.short, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.body(size: 13.5, weight: !won ? FontWeight.w700 : FontWeight.w500, color: !won ? Colors.white : FC.text2))),
        ],
      ),
    );
  }
}

Widget _score(String s) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: FC.overlay,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FC.borderStrong),
      ),
      child: Text(s, style: FCType.mono(size: 16, weight: FontWeight.w800)),
    );
