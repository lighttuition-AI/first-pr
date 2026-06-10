// End-to-end wiring: AppState.recordResult → Seed.results → standings engine.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fc150/data/seed_data.dart';
import 'package:fc150/data/standings.dart';
import 'package:fc150/models/models.dart';
import 'package:fc150/state/app_state.dart';

Player _p(String id, {int rating = 80}) => Player(
      id: id,
      name: id.toUpperCase(),
      short: id,
      country: 'NL',
      pos: 'ATT',
      psn: id,
      rating: rating,
      stats: const Stats(pac: 70, sho: 70, pas: 70, dri: 70, def: 70, phy: 70),
    );

void main() {
  testWidgets('recording a result feeds the league standings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    Seed.results = [];
    Seed.players = [_p('a', rating: 88), _p('b', rating: 85)];

    final app = AppState();
    await app.recordResult('pl', 'a', 'b', 4, 2);

    // A confirmed result lands in the shared feed.
    expect(Seed.results.length, 1);
    expect(Seed.results.first.status, 'confirmed');
    expect(Seed.results.first.comp, 'pl');

    final rows = computeLeague(
      entrants: [Seed.byId('a'), Seed.byId('b')],
      results: Seed.results.where((r) => r.comp == 'pl').toList(),
      started: false,
    );
    final a = rows.firstWhere((e) => e.player?.id == 'a');
    final b = rows.firstWhere((e) => e.player?.id == 'b');
    expect(a.pts, 3);
    expect(a.gd, 2);
    expect(b.pts, 0);
    expect(rows.indexOf(a) < rows.indexOf(b), isTrue);

    // Clean up shared statics so other tests see a fresh slate.
    Seed.results = [];
    Seed.players = [];
  });
}
