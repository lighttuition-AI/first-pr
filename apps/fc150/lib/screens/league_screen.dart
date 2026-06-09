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

class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  Color _formColor(String r) => r == 'W' ? FC.success : r == 'D' ? FC.warning : FC.danger;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final comp = app.competition;
    final tab = app.leagueSubTab;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // competition switcher
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
        Text(comp.subtitle, style: FCType.body(size: 12, color: FC.text2)),
        const SizedBox(height: 16),

        if (comp.kind == CompetitionKind.league) ...[
          Segmented(
            tabs: const [MapEntry('table', 'Table'), MapEntry('fixtures', 'Fixtures'), MapEntry('results', 'Results')],
            value: tab,
            onChange: (v) => context.read<AppState>().setLeagueSubTab(v),
          ),
          const SizedBox(height: 16),
          if (tab == 'table') _table(),
          if (tab == 'fixtures')
            for (final f in Seed.fixtures) ...[_fixtureCard(f), const SizedBox(height: 9)],
          if (tab == 'results')
            for (final r in Seed.results) ...[_resultCard(r), const SizedBox(height: 9)],
        ] else ...[
          Segmented(
            tabs: const [MapEntry('groups', 'Groups'), MapEntry('knockout', 'Knockout')],
            value: tab == 'table' || tab == 'fixtures' || tab == 'results' ? 'groups' : tab,
            onChange: (v) => context.read<AppState>().setLeagueSubTab(v),
          ),
          const SizedBox(height: 16),
          if (tab != 'knockout')
            for (final g in comp.groups) ...[_groupCard(g), const SizedBox(height: 16)]
          else
            _knockout(comp),
        ],
      ],
    );
  }

  // =========================================================================
  // LEAGUE (Premier League) — table / fixtures / results
  // =========================================================================
  static const _cols = [22.0, null, 20.0, 26.0, 24.0, 38.0, 28.0];

  Widget _table() {
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
                form: Text('FORM', textAlign: TextAlign.right, style: _hStyle()),
                rating: const SizedBox(),
              ),
            ),
            for (final r in Seed.league) _tableRow(r),
          ],
        ),
      ),
    );
  }

  TextStyle _hStyle() => FCType.body(size: 10, weight: FontWeight.w700, color: FC.textMuted, height: 1);

  Widget _tableRow(LeagueRow r) {
    final p = Seed.byId(r.id);
    final me = r.id == 'p01';
    final zone = r.pos <= 3 ? FC.success : r.pos >= 11 ? FC.danger : Colors.transparent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: me ? FC.purpleTint : Colors.transparent,
        border: const Border(bottom: BorderSide(color: FC.border)),
      ),
      child: Stack(
        children: [
          Positioned(left: -12, top: 0, bottom: 0, child: Center(child: Container(width: 3, height: 24, decoration: BoxDecoration(color: zone, borderRadius: BorderRadius.circular(2))))),
          _rowLayout(
            hash: Text('${r.pos}', style: FCType.mono(size: 13, weight: FontWeight.w700, color: me ? FC.purple300 : FC.text)),
            player: Text.rich(
              TextSpan(children: [
                TextSpan(text: p.short, style: FCType.body(size: 12.5, weight: me ? FontWeight.w700 : FontWeight.w500)),
                if (me) TextSpan(text: ' · you', style: FCType.body(size: 12.5, weight: FontWeight.w600, color: FC.purple300)),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            p: Text('${r.p}', textAlign: TextAlign.center, style: FCType.mono(size: 12, color: FC.text2)),
            gd: Text('${r.gd > 0 ? '+' : ''}${r.gd}', textAlign: TextAlign.center, style: FCType.mono(size: 12, color: r.gd >= 0 ? FC.success : FC.danger)),
            pts: Text('${r.pts}', textAlign: TextAlign.center, style: FCType.mono(size: 13, weight: FontWeight.w700)),
            form: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final f in r.form.sublist(r.form.length - 3))
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Container(width: 6, height: 6, decoration: BoxDecoration(color: _formColor(f), shape: BoxShape.circle)),
                  ),
              ],
            ),
            rating: Text('${p.rating}', textAlign: TextAlign.right, style: FCType.mono(size: 12, weight: FontWeight.w700, color: FC.purple300)),
          ),
        ],
      ),
    );
  }

  Widget _rowLayout({
    required Widget hash,
    required Widget player,
    required Widget p,
    required Widget gd,
    required Widget pts,
    required Widget form,
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
        fixed(_cols[5]!, form),
        const SizedBox(width: 6),
        fixed(_cols[6]!, rating),
      ],
    );
  }

  Widget _fixtureCard(Fixture f) {
    final a = Seed.byId(f.a), b = Seed.byId(f.b);
    return Surface(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Eyebrow('Matchday ${f.md}'),
              Text(f.when, style: FCType.mono(size: 11, color: FC.text2)),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(child: Text(a.short, textAlign: TextAlign.right, style: FCType.body(size: 13.5, weight: FontWeight.w600))),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: FC.border)),
                child: Text('VS', style: FCType.mono(size: 12, weight: FontWeight.w700, color: FC.textMuted)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(b.short, style: FCType.body(size: 13.5, weight: FontWeight.w600))),
            ],
          ),
          if (f.status == 'locked') ...[
            const SizedBox(height: 9),
            const StatusPill('locked'),
          ],
        ],
      ),
    );
  }

  Widget _resultCard(MatchResult r) {
    final a = Seed.byId(r.a), b = Seed.byId(r.b);
    final aWon = r.sa > r.sb;
    return Surface(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(a.short, textAlign: TextAlign.right, style: FCType.body(size: 13.5, weight: aWon ? FontWeight.w700 : FontWeight.w500, color: aWon ? Colors.white : FC.text2))),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(8), border: Border.all(color: FC.borderStrong)),
                child: Text('${r.sa}–${r.sb}', style: FCType.mono(size: 16, weight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(b.short, style: FCType.body(size: 13.5, weight: !aWon ? FontWeight.w700 : FontWeight.w500, color: !aWon ? Colors.white : FC.text2))),
            ],
          ),
          const SizedBox(height: 8),
          StatusPill(r.status == 'noshow' ? 'noshow' : 'confirmed'),
        ],
      ),
    );
  }

  // =========================================================================
  // CUP (Champions League / World Cup) — groups + knockout bracket
  // =========================================================================
  Widget _groupCard(Group g) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(g.name, style: FCType.heading(size: 15, weight: FontWeight.w800)),
        ),
        Surface(
          pad: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FC.rCard),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: FC.border))),
                  child: _groupRowLayout(
                    pos: Text('#', style: _hStyle()),
                    team: Text('TEAM', style: _hStyle()),
                    p: Text('P', textAlign: TextAlign.center, style: _hStyle()),
                    gd: Text('GD', textAlign: TextAlign.center, style: _hStyle()),
                    pts: Text('PTS', textAlign: TextAlign.center, style: _hStyle()),
                  ),
                ),
                for (int i = 0; i < g.rows.length; i++) _groupRow(i + 1, g.rows[i]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const _gcols = [20.0, null, 20.0, 28.0, 26.0];

  Widget _groupRow(int pos, GroupRow r) {
    final me = r.team.name == 'Khadar Agab';
    final qualifies = pos <= 2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: me ? FC.purpleTint : Colors.transparent,
        border: const Border(bottom: BorderSide(color: FC.border)),
      ),
      child: Stack(
        children: [
          Positioned(left: -12, top: 0, bottom: 0, child: Center(child: Container(width: 3, height: 22, decoration: BoxDecoration(color: qualifies ? FC.success : Colors.transparent, borderRadius: BorderRadius.circular(2))))),
          _groupRowLayout(
            pos: Text('$pos', style: FCType.mono(size: 13, weight: FontWeight.w700, color: me ? FC.purple300 : FC.text)),
            team: Row(
              children: [
                FlagBands(width: 16, bands: Seed.flagOf(r.team.country)),
                const SizedBox(width: 7),
                Flexible(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: r.team.name, style: FCType.body(size: 12.5, weight: me ? FontWeight.w700 : FontWeight.w500)),
                      if (me) TextSpan(text: ' · you', style: FCType.body(size: 12.5, weight: FontWeight.w600, color: FC.purple300)),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            p: Text('${r.p}', textAlign: TextAlign.center, style: FCType.mono(size: 12, color: FC.text2)),
            gd: Text('${r.gd > 0 ? '+' : ''}${r.gd}', textAlign: TextAlign.center, style: FCType.mono(size: 12, color: r.gd >= 0 ? FC.success : FC.danger)),
            pts: Text('${r.pts}', textAlign: TextAlign.center, style: FCType.mono(size: 13, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _groupRowLayout({required Widget pos, required Widget team, required Widget p, required Widget gd, required Widget pts}) {
    Widget fixed(double w, Widget c) => SizedBox(width: w, child: c);
    return Row(
      children: [
        fixed(_gcols[0]!, pos),
        const SizedBox(width: 6),
        Expanded(child: team),
        const SizedBox(width: 6),
        fixed(_gcols[2]!, p),
        const SizedBox(width: 6),
        fixed(_gcols[3]!, gd),
        const SizedBox(width: 6),
        fixed(_gcols[4]!, pts),
      ],
    );
  }

  Widget _knockout(Competition comp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final round in comp.rounds) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(round, style: FCType.heading(size: 15, weight: FontWeight.w800)),
          ),
          for (final tie in comp.bracket.where((t) => t.round == round)) ...[
            _tieCard(tie),
            const SizedBox(height: 9),
          ],
          const SizedBox(height: 7),
        ],
      ],
    );
  }

  Widget _tieCard(KnockoutTie t) {
    final played = t.sa != null && t.sb != null;
    final aWon = played && t.sa! > t.sb!;
    final bWon = played && t.sb! > t.sa!;
    final locked = t.status == 'locked';
    return Surface(
      glow: locked,
      borderColor: locked ? const Color(0x4D00D8D6) : null,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _tieTeam(t.a, alignEnd: true, won: aWon, dim: bWon)),
              const SizedBox(width: 10),
              if (played)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(8), border: Border.all(color: FC.borderStrong)),
                  child: Text('${t.sa}–${t.sb}', style: FCType.mono(size: 16, weight: FontWeight.w800)),
                )
              else
                Text('VS', style: FCType.mono(size: 13, weight: FontWeight.w700, color: FC.textMuted)),
              const SizedBox(width: 10),
              Expanded(child: _tieTeam(t.b, alignEnd: false, won: bWon, dim: aWon)),
            ],
          ),
          const SizedBox(height: 9),
          StatusPill(t.status),
        ],
      ),
    );
  }

  Widget _tieTeam(Competitor? c, {required bool alignEnd, required bool won, required bool dim}) {
    final cross = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    if (c == null) {
      return Column(
        crossAxisAlignment: cross,
        children: [Text('TBD', style: FCType.body(size: 13.5, weight: FontWeight.w600, color: FC.textMuted))],
      );
    }
    final me = c.name == 'Khadar Agab';
    final flag = FlagBands(width: 16, bands: Seed.flagOf(c.country));
    final name = Flexible(
      child: Text(c.name,
          maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: FCType.body(size: 13.5, weight: won || me ? FontWeight.w700 : FontWeight.w500, color: dim ? FC.text2 : (me ? FC.purple300 : Colors.white))),
    );
    return Column(
      crossAxisAlignment: cross,
      children: [
        Row(
          mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: alignEnd ? [name, const SizedBox(width: 7), flag] : [flag, const SizedBox(width: 7), name],
        ),
        const SizedBox(height: 2),
        Text('${c.rating} OVR', style: FCType.mono(size: 11, color: FC.text2)),
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
