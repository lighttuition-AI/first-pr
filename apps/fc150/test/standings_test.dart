// Pure standings engine — the "backend piece" that turns confirmed results into
// league/cup tables, with the auto-3-0 rule for CPU teams.
import 'package:flutter_test/flutter_test.dart';

import 'package:fc150/data/standings.dart';
import 'package:fc150/models/models.dart';

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

MatchResult _r(String a, String b, int sa, int sb, {String comp = 'pl', String status = 'confirmed'}) =>
    MatchResult(id: '$a-$b', a: a, b: b, sa: sa, sb: sb, comp: comp, when: 'now', status: status);

void main() {
  group('computeLeague', () {
    test('empty roster, not started → 38 empty slots, all zero', () {
      final rows = computeLeague(entrants: const [], results: const [], started: false);
      expect(rows.length, 38);
      expect(rows.every((e) => !e.isFilled), isTrue);
      expect(rows.every((e) => e.pts == 0 && e.played == 0), isTrue);
    });

    test('not started → players fill the top sorted by rating, rest empty', () {
      final rows = computeLeague(
        entrants: [_p('lo', rating: 75), _p('hi', rating: 90)],
        results: const [],
        started: false,
      );
      expect(rows.length, 38);
      expect(rows[0].player?.id, 'hi'); // higher rating ranks first on a tie
      expect(rows[1].player?.id, 'lo');
      expect(rows[0].pts, 0);
      expect(rows[2].isFilled, isFalse); // remaining slots stay empty
    });

    test('a confirmed result feeds the table (3 pts for the winner)', () {
      final rows = computeLeague(
        entrants: [_p('a'), _p('b')],
        results: [_r('a', 'b', 2, 1)],
        started: false,
      );
      final a = rows.firstWhere((e) => e.player?.id == 'a');
      final b = rows.firstWhere((e) => e.player?.id == 'b');
      expect(a.played, 1);
      expect(a.won, 1);
      expect(a.pts, 3);
      expect(a.gd, 1);
      expect(b.pts, 0);
      expect(b.lost, 1);
      expect(rows.indexOf(a) < rows.indexOf(b), isTrue); // winner ranks above
    });

    test('unconfirmed results are ignored', () {
      final rows = computeLeague(
        entrants: [_p('a'), _p('b')],
        results: [_r('a', 'b', 5, 0, status: 'pending')],
        started: false,
      );
      expect(rows.firstWhere((e) => e.player?.id == 'a').played, 0);
    });

    test('draw → 1 point each', () {
      final rows = computeLeague(entrants: [_p('a'), _p('b')], results: [_r('a', 'b', 1, 1)], started: false);
      expect(rows.firstWhere((e) => e.player?.id == 'a').pts, 1);
      expect(rows.firstWhere((e) => e.player?.id == 'b').pts, 1);
    });
  });

  group('auto-3-0 CPU rule', () {
    test('on season start, real players auto-beat each CPU team 3-0', () {
      // 2 real players, 4 slots → 2 CPU teams. Each real player should bank 2
      // auto wins (6 pts, +6 GD) without playing each other.
      final rows = rankPool(
        players: [_p('a'), _p('b')],
        results: const [],
        started: true,
        size: 4,
        cpuNames: const ['CPU One', 'CPU Two'],
      );
      expect(rows.length, 4);
      final a = rows.firstWhere((e) => e.player?.id == 'a');
      expect(a.played, 2);
      expect(a.won, 2);
      expect(a.pts, 6);
      expect(a.gf, 6);
      expect(a.gd, 6);
      // CPU teams sit below with two 0-3 losses each.
      final cpu = rows.where((e) => e.cpu != null).toList();
      expect(cpu.length, 2);
      expect(cpu.first.played, 2);
      expect(cpu.first.lost, 2);
      expect(cpu.first.pts, 0);
      expect(cpu.first.ga, 6);
      // Real players rank above CPU teams.
      expect(rows.take(2).every((e) => e.player != null), isTrue);
    });

    test('not started → no CPU teams, leftover stays empty', () {
      final rows = rankPool(players: [_p('a')], results: const [], started: false, size: 4, cpuNames: const ['X', 'Y', 'Z']);
      expect(rows.where((e) => e.cpu != null), isEmpty);
      expect(rows.where((e) => !e.isFilled).length, 3);
    });
  });

  group('computeGroups', () {
    test('always returns 4 groups of 4 (16 slots)', () {
      final groups = computeGroups(entrants: const [], results: const [], started: false);
      expect(groups.length, 4);
      expect(groups.every((g) => g.length == 4), isTrue);
    });

    test('entrants are seeded across groups (0→A, 1→B, …)', () {
      final groups = computeGroups(
        entrants: [_p('a0', rating: 99), _p('a1', rating: 98), _p('a2', rating: 97), _p('a3', rating: 96), _p('a4', rating: 95)],
        results: const [],
        started: false,
      );
      // a0 and a4 both land in group A (indices 0 and 4).
      final groupA = groups[0].where((e) => e.player != null).map((e) => e.player!.id).toSet();
      expect(groupA.containsAll({'a0', 'a4'}), isTrue);
      expect(groups[1].where((e) => e.player != null).single.player!.id, 'a1');
    });
  });
}
