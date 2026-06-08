import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';

class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  Color _formColor(String r) => r == 'W' ? FC.success : r == 'D' ? FC.warning : FC.danger;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tab = app.leagueSubTab;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Premier League · 2025/26', color: FC.purple300),
        const SizedBox(height: 2),
        Text('Season standings', style: FCType.heading(size: 23, weight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Matchday 19 of 38 · half-season cards updated', style: FCType.body(size: 12, color: FC.text2)),
        const SizedBox(height: 16),
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
      ],
    );
  }

  // grid columns: # · Player · P · GD · Pts · Form · rating
  static const _cols = [22.0, null, 20.0, 26.0, 24.0, 38.0, 28.0];

  Widget _table() {
    return Surface(
      pad: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FC.rCard),
        child: Column(
          children: [
            // header
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
}
