import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../data/standings.dart';
import '../flows/competition_picker.dart';
import '../models/competition.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';

/// League / cup standings. Premier League is a fixed 38-row table; the cups are
/// 4 groups of 4 (16 slots). Slots are empty until the admin drafts players;
/// once a season starts, leftover slots become CPU teams that every real player
/// beats 3-0. Real head-to-head results (recorded via the admin Control tab)
/// feed the table through [computeLeague] / [computeGroups].
class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  static const _plSlots = 38;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final comp = app.competition;
    final tab = app.leagueSubTab;
    final meId = app.currentUser.id;
    final isLeague = comp.kind == CompetitionKind.league;
    final started = app.seasonStarted(comp.id);

    final entrants = app.rosterFor(comp.id).map(Seed.byId).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final results = Seed.results.where((r) => r.comp == comp.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CompetitionSelector(
          comp: comp,
          onTap: () async {
            final id = await showCompetitionPicker(context, comp.id);
            if (id != null && context.mounted) context.read<AppState>().setCompetition(id);
          },
        ),
        const SizedBox(height: 14),
        Text(comp.title, style: FCType.heading(size: 23, weight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          isLeague
              ? '${entrants.length}/$_plSlots players · ${started ? 'season live' : 'season hasn’t started'}'
              : '${entrants.length} teams · 4 groups · ${started ? 'season live' : 'draw pending'}',
          style: FCType.body(size: 12, color: FC.text2),
        ),
        const SizedBox(height: 16),
        if (isLeague) ...[
          Segmented(
            tabs: const [MapEntry('table', 'Table'), MapEntry('fixtures', 'Fixtures'), MapEntry('results', 'Results')],
            value: tab == 'groups' || tab == 'knockout' ? 'table' : tab,
            onChange: (v) => context.read<AppState>().setLeagueSubTab(v),
          ),
          const SizedBox(height: 16),
          if (tab == 'fixtures')
            _empty(LucideIcons.calendar, 'No fixtures yet', 'Fixtures appear once the season starts.')
          else if (tab == 'results')
            _resultsList(results)
          else ...[
            if (!started) _notStarted(),
            if (!started) const SizedBox(height: 12),
            _table(computeLeague(entrants: entrants, results: results, started: started, slots: _plSlots), meId),
          ],
        ] else ...[
          Segmented(
            tabs: const [MapEntry('groups', 'Groups'), MapEntry('knockout', 'Knockout')],
            value: tab == 'knockout' ? 'knockout' : 'groups',
            onChange: (v) => context.read<AppState>().setLeagueSubTab(v),
          ),
          const SizedBox(height: 16),
          if (tab == 'knockout')
            _empty(LucideIcons.trophy, 'Bracket not drawn', 'The knockout bracket appears after the group stage.')
          else ...[
            if (!started) _notStarted(),
            if (!started) const SizedBox(height: 12),
            ...() {
              final groups = computeGroups(entrants: entrants, results: results, started: started);
              return [
                for (var g = 0; g < groups.length; g++) ...[
                  _group(String.fromCharCode(65 + g), groups[g], meId),
                  const SizedBox(height: 16),
                ],
              ];
            }(),
          ],
        ],
      ],
    );
  }

  Widget _notStarted() => Surface(
        child: Row(
          children: [
            const Icon(LucideIcons.info, size: 18, color: FC.purple300),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                  'Season hasn’t started — slots stay empty until the admin drafts players, and standings are zero until results come in.',
                  style: FCType.body(size: 12.5, color: FC.text2, height: 1.35)),
            ),
          ],
        ),
      );

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

  Widget _resultsList(List results) {
    if (results.isEmpty) {
      return _empty(LucideIcons.flag, 'No results yet', 'Played matches show up here.');
    }
    return Surface(
      pad: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FC.rCard),
        child: Column(
          children: [
            for (final r in results)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: FC.border))),
                child: Row(
                  children: [
                    Expanded(child: Text(Seed.byId(r.a).short, textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.body(size: 12.5))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('${r.sa} – ${r.sb}', style: FCType.mono(size: 13, weight: FontWeight.w700)),
                    ),
                    Expanded(child: Text(Seed.byId(r.b).short, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.body(size: 12.5))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _hStyle() => FCType.body(size: 10, weight: FontWeight.w700, color: FC.textMuted, height: 1);
  static const _cols = [24.0, null, 22.0, 28.0, 28.0, 30.0];

  Widget _table(List<TableEntry> rows, String meId) {
    return Surface(
      pad: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FC.rCard),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: FC.border))),
              child: _rowLayout(
                Text('#', style: _hStyle()),
                Text('PLAYER', style: _hStyle()),
                Text('P', textAlign: TextAlign.center, style: _hStyle()),
                Text('GD', textAlign: TextAlign.center, style: _hStyle()),
                Text('PTS', textAlign: TextAlign.center, style: _hStyle()),
                const SizedBox(),
              ),
            ),
            for (var i = 0; i < rows.length; i++) _row(i + 1, rows[i], meId),
          ],
        ),
      ),
    );
  }

  Widget _group(String letter, List<TableEntry> rows, String meId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text('Group $letter', style: FCType.heading(size: 15, weight: FontWeight.w800)),
        ),
        Surface(
          pad: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FC.rCard),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) _row(i + 1, rows[i], meId, showRating: false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(int pos, TableEntry e, String meId, {bool showRating = true}) {
    final p = e.player;
    final me = p != null && p.id == meId;
    final Widget name;
    if (p != null) {
      name = Row(children: [
        FlagBands(width: 18, code: p.country),
        const SizedBox(width: 8),
        Flexible(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: p.short, style: FCType.body(size: 12.5, weight: me ? FontWeight.w700 : FontWeight.w500)),
              if (me) TextSpan(text: ' · you', style: FCType.body(size: 12.5, weight: FontWeight.w600, color: FC.purple300)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]);
    } else if (e.cpu != null) {
      name = Row(children: [
        const Icon(LucideIcons.bot, size: 15, color: FC.textMuted),
        const SizedBox(width: 6),
        Flexible(child: Text(e.cpu!, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.body(size: 12.5, color: FC.text2))),
      ]);
    } else {
      name = Text('Empty slot', style: FCType.body(size: 12.5, color: FC.textMuted));
    }
    final muted = !e.isFilled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: me ? FC.purpleTint : Colors.transparent,
        border: const Border(bottom: BorderSide(color: FC.border)),
      ),
      child: _rowLayout(
        Text('$pos', style: FCType.mono(size: 13, weight: FontWeight.w700, color: me ? FC.purple300 : (muted ? FC.textMuted : FC.text))),
        name,
        Text('${e.played}', textAlign: TextAlign.center, style: FCType.mono(size: 12, color: FC.text2)),
        Text(e.gd > 0 ? '+${e.gd}' : '${e.gd}', textAlign: TextAlign.center, style: FCType.mono(size: 12, color: FC.text2)),
        Text('${e.pts}', textAlign: TextAlign.center, style: FCType.mono(size: 13, weight: FontWeight.w700)),
        showRating && p != null
            ? Text('${p.rating}', textAlign: TextAlign.right, style: FCType.mono(size: 12, weight: FontWeight.w700, color: FC.purple300))
            : const SizedBox(),
      ),
    );
  }

  Widget _rowLayout(Widget hash, Widget player, Widget p, Widget gd, Widget pts, Widget rating) {
    Widget fixed(double w, Widget c) => SizedBox(width: w, child: c);
    return Row(
      children: [
        fixed(_cols[0]!, hash),
        const SizedBox(width: 6),
        Expanded(child: player),
        const SizedBox(width: 6),
        fixed(_cols[2]!, p),
        const SizedBox(width: 6),
        fixed(_cols[3]!, gd),
        const SizedBox(width: 6),
        fixed(_cols[4]!, pts),
        const SizedBox(width: 6),
        fixed(_cols[5]!, rating),
      ],
    );
  }
}

/// Tappable competition switcher in the League header.
class _CompetitionSelector extends StatelessWidget {
  final Competition comp;
  final VoidCallback onTap;
  const _CompetitionSelector({required this.comp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: FC.surface,
          borderRadius: BorderRadius.circular(FC.rPill),
          border: Border.all(color: FC.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.trophy, size: 15, color: FC.purple300),
            const SizedBox(width: 8),
            Text('${comp.name} · ${comp.season}',
                style: FCType.body(size: 12, weight: FontWeight.w700, color: FC.text, letterSpacing: 0.04, height: 1)),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronDown, size: 15, color: FC.text2),
          ],
        ),
      ),
    );
  }
}
