import '../models/competition.dart';

/// Seed competitions. Premier League is a season-long league (renders from the
/// existing Seed league/fixtures/results). Champions League and World Cup are
/// cups with a group stage + a knockout bracket.
class Comps {
  Comps._();

  // ---- competitors (short name, ISO country, rating) ----
  static const _khadar = Competitor('Khadar Agab', 'NL', 94);
  static const _hodan = Competitor('Hodan Ali', 'SO', 93);
  static const _guled = Competitor('Guled Farah', 'SO', 91);
  static const _liam = Competitor('Liam de Jong', 'NL', 90);
  static const _noah = Competitor('Noah Keita', 'SN', 89);
  static const _adam = Competitor('Adam Osman', 'SO', 88);
  static const _yusuf = Competitor('Yusuf Rashid', 'SO', 87);
  static const _marco = Competitor('Marco Bianchi', 'IT', 86);
  static const _omar = Competitor('Omar Sheikh', 'SO', 85);
  static const _kenji = Competitor('Kenji Sato', 'JP', 84);
  static const _tomas = Competitor('Tomas Novak', 'CZ', 83);
  static const _bilal = Competitor('Bilal Hassan', 'SO', 82);
  // World Cup guest teams
  static const _joao = Competitor('João Pedro', 'PT', 89);
  static const _erik = Competitor('Erik Larsson', 'SE', 86);
  static const _carlos = Competitor('Carlos Mendez', 'MX', 84);
  static const _yuki = Competitor('Yuki Tanaka', 'JP', 83);

  static GroupRow _r(Competitor c, int w, int d, int l, int gf, int ga) =>
      GroupRow(c, p: w + d + l, w: w, d: d, l: l, gf: gf, ga: ga, pts: w * 3 + d);

  // ---------------------------------------------------------------------------
  static const premierLeague = Competition(
    id: 'pl',
    name: 'Premier League',
    season: '2025/26',
    title: 'Season standings',
    subtitle: 'Matchday 19 of 38 · half-season cards updated',
    kind: CompetitionKind.league,
  );

  // ---------------------------------------------------------------------------
  static final championsLeague = Competition(
    id: 'ucl',
    name: 'Champions League',
    season: '2025/26',
    title: 'Knockout phase',
    subtitle: '8 teams · 2 groups · semi-finals live',
    kind: CompetitionKind.cup,
    groups: [
      Group('Group A', [
        _r(_khadar, 3, 0, 0, 8, 2),
        _r(_adam, 2, 0, 1, 5, 4),
        _r(_liam, 1, 0, 2, 4, 5),
        _r(_marco, 0, 0, 3, 2, 8),
      ]),
      Group('Group B', [
        _r(_hodan, 2, 1, 0, 6, 2),
        _r(_guled, 2, 0, 1, 5, 3),
        _r(_noah, 1, 1, 1, 4, 4),
        _r(_yusuf, 0, 0, 3, 1, 7),
      ]),
    ],
    bracket: [
      KnockoutTie(round: 'Semi-finals', a: _khadar, b: _guled, sa: 3, sb: 1, status: 'confirmed'),
      KnockoutTie(round: 'Semi-finals', a: _hodan, b: _adam, status: 'locked'),
      KnockoutTie(round: 'Final', status: 'scheduled'),
    ],
  );

  // ---------------------------------------------------------------------------
  static final worldCup = Competition(
    id: 'wc',
    name: 'World Cup',
    season: '2026',
    title: 'Group stage & bracket',
    subtitle: '16 teams · 4 groups · quarter-finals live',
    kind: CompetitionKind.cup,
    groups: [
      Group('Group A', [
        _r(_khadar, 3, 0, 0, 7, 1),
        _r(_joao, 2, 0, 1, 5, 3),
        _r(_noah, 1, 0, 2, 3, 4),
        _r(_kenji, 0, 0, 3, 1, 8),
      ]),
      Group('Group B', [
        _r(_hodan, 2, 1, 0, 6, 2),
        _r(_adam, 2, 0, 1, 5, 3),
        _r(_erik, 1, 1, 1, 3, 3),
        _r(_tomas, 0, 0, 3, 1, 7),
      ]),
      Group('Group C', [
        _r(_guled, 2, 1, 0, 6, 2),
        _r(_yusuf, 1, 2, 0, 4, 2),
        _r(_carlos, 1, 0, 2, 3, 4),
        _r(_bilal, 0, 1, 2, 2, 7),
      ]),
      Group('Group D', [
        _r(_liam, 2, 1, 0, 5, 2),
        _r(_marco, 2, 0, 1, 4, 3),
        _r(_omar, 1, 0, 2, 3, 4),
        _r(_yuki, 0, 1, 2, 2, 5),
      ]),
    ],
    bracket: [
      KnockoutTie(round: 'Quarter-finals', a: _khadar, b: _adam, sa: 4, sb: 2, status: 'confirmed'),
      KnockoutTie(round: 'Quarter-finals', a: _guled, b: _marco, status: 'locked'),
      KnockoutTie(round: 'Quarter-finals', a: _hodan, b: _joao, sa: 2, sb: 0, status: 'confirmed'),
      KnockoutTie(round: 'Quarter-finals', a: _liam, b: _yusuf, status: 'scheduled'),
      KnockoutTie(round: 'Semi-finals', a: _khadar, status: 'scheduled'),
      KnockoutTie(round: 'Semi-finals', a: _hodan, status: 'scheduled'),
      KnockoutTie(round: 'Final', status: 'scheduled'),
    ],
  );

  static final List<Competition> all = [premierLeague, championsLeague, worldCup];

  static Competition byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => premierLeague);
}
