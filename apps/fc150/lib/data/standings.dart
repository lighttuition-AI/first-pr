import '../models/models.dart' show MatchResult, Player;
import 'seed_data.dart';

/// One row in a standings table: a real drafted player, an auto-generated CPU
/// team (filler when a season starts with empty slots), or an empty slot.
///
/// Points are 3/win, 1/draw. Stats are derived from confirmed [MatchResult]s
/// plus the auto-3-0 rule for CPU teams (see [rankPool]).
class TableEntry {
  final Player? player; // real player, or null for CPU / empty
  final String? cpu; // CPU team name, or null
  final int played, won, drawn, lost, gf, ga;

  const TableEntry({
    this.player,
    this.cpu,
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.gf = 0,
    this.ga = 0,
  });

  const TableEntry.empty()
      : player = null,
        cpu = null,
        played = 0,
        won = 0,
        drawn = 0,
        lost = 0,
        gf = 0,
        ga = 0;

  int get gd => gf - ga;
  int get pts => won * 3 + drawn;
  bool get isFilled => player != null || cpu != null;
}

class _Acc {
  int played = 0, won = 0, drawn = 0, lost = 0, gf = 0, ga = 0;
}

int _compare(TableEntry x, TableEntry y) {
  final byPts = y.pts.compareTo(x.pts);
  if (byPts != 0) return byPts;
  final byGd = y.gd.compareTo(x.gd);
  if (byGd != 0) return byGd;
  final byGf = y.gf.compareTo(x.gf);
  if (byGf != 0) return byGf;
  // On a dead tie, real players rank above CPU teams.
  final xr = x.player != null ? 0 : 1;
  final yr = y.player != null ? 0 : 1;
  if (xr != yr) return xr - yr;
  if (x.player != null && y.player != null) {
    final byRating = y.player!.rating.compareTo(x.player!.rating);
    if (byRating != 0) return byRating;
    return x.player!.short.compareTo(y.player!.short);
  }
  return (x.cpu ?? '').compareTo(y.cpu ?? '');
}

/// Rank a pool of [size] slots.
///
/// Real [players] earn results from confirmed head-to-head [results] (only
/// matches where both sides are in this pool count). When [started] is true and
/// the pool isn't full, the leftover slots become CPU teams (named from
/// [cpuNames]) — every real player is auto-credited a **3-0 win** over each CPU
/// team, and each CPU team takes a 0-3 loss to every real player. Empty slots
/// pad the bottom when the season hasn't started.
List<TableEntry> rankPool({
  required List<Player> players,
  required List<MatchResult> results,
  required bool started,
  required int size,
  required List<String> cpuNames,
}) {
  final ids = players.map((p) => p.id).toSet();
  final acc = {for (final p in players) p.id: _Acc()};

  for (final r in results) {
    if (r.status != 'confirmed') continue;
    if (r.a == r.b || !ids.contains(r.a) || !ids.contains(r.b)) continue;
    final a = acc[r.a]!;
    final b = acc[r.b]!;
    a.gf += r.sa;
    a.ga += r.sb;
    b.gf += r.sb;
    b.ga += r.sa;
    a.played++;
    b.played++;
    if (r.sa > r.sb) {
      a.won++;
      b.lost++;
    } else if (r.sa < r.sb) {
      b.won++;
      a.lost++;
    } else {
      a.drawn++;
      b.drawn++;
    }
  }

  final cpuCount = started ? (size - players.length).clamp(0, size) : 0;
  // Every real player auto-wins 3-0 against each CPU team.
  if (cpuCount > 0) {
    for (final p in players) {
      final a = acc[p.id]!;
      a.played += cpuCount;
      a.won += cpuCount;
      a.gf += 3 * cpuCount;
    }
  }

  final real = [
    for (final p in players)
      TableEntry(
        player: p,
        played: acc[p.id]!.played,
        won: acc[p.id]!.won,
        drawn: acc[p.id]!.drawn,
        lost: acc[p.id]!.lost,
        gf: acc[p.id]!.gf,
        ga: acc[p.id]!.ga,
      ),
  ];
  final cpu = [
    for (var i = 0; i < cpuCount; i++)
      TableEntry(
        cpu: i < cpuNames.length ? cpuNames[i] : 'CPU ${i + 1}',
        played: players.length,
        lost: players.length,
        ga: 3 * players.length,
      ),
  ];

  final ranked = [...real, ...cpu]..sort(_compare);
  final fillCount = (size - ranked.length).clamp(0, size);
  return [...ranked, for (var i = 0; i < fillCount; i++) const TableEntry.empty()].take(size).toList();
}

/// Premier League standings — a single [slots]-row table (38 by default).
List<TableEntry> computeLeague({
  required List<Player> entrants,
  required List<MatchResult> results,
  required bool started,
  int slots = 38,
}) {
  final pool = entrants.take(slots).toList();
  final cpuNames = [for (var i = pool.length; i < slots; i++) Seed.autoTeamName(i)];
  return rankPool(players: pool, results: results, started: started, size: slots, cpuNames: cpuNames);
}

/// Cup standings — [groups] groups of [perGroup] (4×4 = 16 by default). Entrants
/// are seeded across the groups (0→A, 1→B, 2→C, 3→D, 4→A …) so the strongest
/// players are spread out. Returns one ranked list per group.
List<List<TableEntry>> computeGroups({
  required List<Player> entrants,
  required List<MatchResult> results,
  required bool started,
  int groups = 4,
  int perGroup = 4,
}) {
  final cap = groups * perGroup;
  return [
    for (var g = 0; g < groups; g++)
      rankPool(
        players: [for (var i = g; i < entrants.length && i < cap; i += groups) entrants[i]],
        results: results,
        started: started,
        size: perGroup,
        cpuNames: [for (var k = 0; k < perGroup; k++) Seed.autoTeamName(g * perGroup + k)],
      ),
  ];
}
