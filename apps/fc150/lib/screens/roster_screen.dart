import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';

/// Roster — the admin's squad builder. Approved players register into a single
/// pool; the admin drafts them into each competition (Premier League caps at
/// 38, World Cup at 32) and leaves the rest out. Selections live in [AppState].
class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});
  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  String _comp = 'pl'; // pl / wc
  String _filter = 'all'; // all / in / out

  static const _compName = {'pl': 'Premier League', 'wc': 'World Cup'};

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pool = Seed.roster;
    final placed = app.rosterFor(_comp);
    final cap = app.capOf(_comp);
    final full = placed.length >= cap;

    final shown = pool.where((p) {
      if (_filter == 'in') return placed.contains(p.id);
      if (_filter == 'out') return !placed.contains(p.id);
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Control room', color: FC.warning),
                  const SizedBox(height: 2),
                  Text('Roster', style: FCType.heading(size: 23, weight: FontWeight.w800)),
                ],
              ),
            ),
            Pill('${pool.length} approved', glyph: '●', tone: PillTone.purple),
          ],
        ),
        const SizedBox(height: 4),
        Text('Draft approved players into each competition. The pool holds more than a competition can fit — you decide who plays and who sits out.',
            style: FCType.body(size: 12.5, color: FC.text2, height: 1.35)),
        const SizedBox(height: 16),

        // competition switcher
        Segmented(
          tabs: const [MapEntry('pl', 'Premier League'), MapEntry('wc', 'World Cup')],
          value: _comp,
          onChange: (v) => setState(() => _comp = v),
        ),
        const SizedBox(height: 14),

        // capacity meter
        _CapacityCard(name: _compName[_comp]!, count: placed.length, cap: cap),
        const SizedBox(height: 16),

        // filter + count
        Row(
          children: [
            Expanded(
              child: Segmented(
                tabs: [
                  const MapEntry('all', 'All'),
                  MapEntry('in', 'In · ${placed.length}'),
                  MapEntry('out', 'Out · ${pool.length - placed.length}'),
                ],
                value: _filter,
                onChange: (v) => setState(() => _filter = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        for (final p in shown) ...[
          _RosterRow(
            player: p,
            placed: placed.contains(p.id),
            blocked: full && !placed.contains(p.id),
            onTap: () {
              final ok = app.toggleRoster(_comp, p.id);
              if (!ok) {
                flashToast(context, '${_compName[_comp]} is full · $cap/$cap');
              } else {
                final nowIn = app.isPlaced(_comp, p.id);
                flashToast(context, '${p.short} ${nowIn ? 'added to' : 'removed from'} ${_compName[_comp]}');
              }
            },
          ),
          const SizedBox(height: 9),
        ],
        if (shown.isEmpty)
          Surface(child: Center(child: Text('No players in this view', style: FCType.body(size: 13, color: FC.text2)))),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _CapacityCard extends StatelessWidget {
  final String name;
  final int count, cap;
  const _CapacityCard({required this.name, required this.count, required this.cap});

  @override
  Widget build(BuildContext context) {
    final pct = (count / cap).clamp(0.0, 1.0);
    final full = count >= cap;
    final barColor = full ? FC.success : pct > 0.85 ? FC.warning : FC.teal;
    return Surface(
      glow: true,
      borderColor: full ? const Color(0x4D00C853) : const Color(0x4D00D8D6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.usersRound, size: 18, color: FC.teal),
              const SizedBox(width: 10),
              Expanded(child: Text(name, style: FCType.body(size: 14, weight: FontWeight.w700))),
              if (full) const Pill('Full', glyph: '✓', tone: PillTone.success) else Pill('${cap - count} open', tone: PillTone.teal),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$count', style: FCType.mono(size: 26, weight: FontWeight.w700, color: barColor, height: 1)),
              Text(' / $cap placed', style: FCType.body(size: 12.5, color: FC.text2)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 7, color: Colors.white.withValues(alpha: 0.08)),
                LayoutBuilder(
                  builder: (_, c) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: FC.durSlow,
                    curve: FC.easeOut,
                    builder: (_, t, __) => Container(height: 7, width: c.maxWidth * t, color: barColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RosterRow extends StatelessWidget {
  final Player player;
  final bool placed;
  final bool blocked;
  final VoidCallback onTap;
  const _RosterRow({required this.player, required this.placed, required this.blocked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Surface(
      borderColor: placed ? const Color(0x4D00D8D6) : null,
      child: Row(
        children: [
          AvatarInitials(initials: player.initials, size: 38, photo: player.photo),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.short, style: FCType.body(size: 13.5, weight: FontWeight.w600, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    Text(player.pos, style: FCType.mono(size: 11, weight: FontWeight.w700, color: FC.purple300)),
                    Text(' · ${player.rating} OVR · ', style: FCType.mono(size: 11, color: FC.text2)),
                    Flexible(child: Text(player.psn, style: FCType.mono(size: 11, color: FC.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (placed)
            GButton('In', size: 'sm', variant: GBtn.teal, icon: LucideIcons.check, onTap: onTap)
          else
            GButton('Add', size: 'sm', variant: blocked ? GBtn.ghost : GBtn.secondary, icon: LucideIcons.userPlus, onTap: onTap),
        ],
      ),
    );
  }
}
