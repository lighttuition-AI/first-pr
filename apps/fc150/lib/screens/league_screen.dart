import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../flows/competition_picker.dart';
import '../models/competition.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';

/// League / cup standings. At launch nothing has been played, so standings are
/// the admin-accepted roster with zeroed stats (P/GD/PTS = 0). Fixtures, results
/// and the knockout bracket fill in once the admin starts the season.
class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final comp = app.competition;
    final tab = app.leagueSubTab;
    final meId = app.currentUser.id;
    final isLeague = comp.kind == CompetitionKind.league;

    // Accepted entrants (the admin's roster for this competition), zeroed.
    final entrants = app.rosterFor(comp.id).map(Seed.byId).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

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
          isLeague ? '${entrants.length} players · season hasn’t started' : '${entrants.length} teams · draw pending',
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
            _empty(LucideIcons.calendar, 'No fixtures yet', 'Fixtures appear once the admin starts the season.')
          else if (tab == 'results')
            _empty(LucideIcons.flag, 'No results yet', 'Played matches show up here.')
          else ...[
            _notStarted(),
            const SizedBox(height: 12),
            _standings(entrants, meId),
          ],
        ] else ...[
          Segmented(
            tabs: const [MapEntry('groups', 'Standings'), MapEntry('knockout', 'Knockout')],
            value: tab == 'knockout' ? 'knockout' : 'groups',
            onChange: (v) => context.read<AppState>().setLeagueSubTab(v),
          ),
          const SizedBox(height: 16),
          if (tab == 'knockout')
            _empty(LucideIcons.trophy, 'Bracket not drawn', 'The knockout bracket appears after the group stage.')
          else ...[
            _notStarted(),
            const SizedBox(height: 12),
            _standings(entrants, meId),
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
              child: Text('Season hasn’t started — standings stay at zero until games are played.',
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

  // ---- Standings table (zeroed) --------------------------------------------
  static const _cols = [22.0, null, 22.0, 28.0, 28.0, 30.0];

  TextStyle _hStyle() => FCType.body(size: 10, weight: FontWeight.w700, color: FC.textMuted, height: 1);

  Widget _standings(List<Player> entrants, String meId) {
    if (entrants.isEmpty) {
      return _empty(LucideIcons.users, 'No players yet', 'Players appear here once the admin accepts them.');
    }
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
                hash: Text('#', style: _hStyle()),
                player: Text('PLAYER', style: _hStyle()),
                p: Text('P', textAlign: TextAlign.center, style: _hStyle()),
                gd: Text('GD', textAlign: TextAlign.center, style: _hStyle()),
                pts: Text('PTS', textAlign: TextAlign.center, style: _hStyle()),
                rating: const SizedBox(),
              ),
            ),
            for (int i = 0; i < entrants.length; i++) _row(i + 1, entrants[i], meId),
          ],
        ),
      ),
    );
  }

  Widget _row(int pos, Player p, String meId) {
    final me = p.id == meId;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: me ? FC.purpleTint : Colors.transparent,
        border: const Border(bottom: BorderSide(color: FC.border)),
      ),
      child: _rowLayout(
        hash: Text('$pos', style: FCType.mono(size: 13, weight: FontWeight.w700, color: me ? FC.purple300 : FC.text)),
        player: Row(
          children: [
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
          ],
        ),
        p: Text('0', textAlign: TextAlign.center, style: FCType.mono(size: 12, color: FC.text2)),
        gd: Text('0', textAlign: TextAlign.center, style: FCType.mono(size: 12, color: FC.text2)),
        pts: Text('0', textAlign: TextAlign.center, style: FCType.mono(size: 13, weight: FontWeight.w700)),
        rating: Text('${p.rating}', textAlign: TextAlign.right, style: FCType.mono(size: 12, weight: FontWeight.w700, color: FC.purple300)),
      ),
    );
  }

  Widget _rowLayout({
    required Widget hash,
    required Widget player,
    required Widget p,
    required Widget gd,
    required Widget pts,
    required Widget rating,
  }) {
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
