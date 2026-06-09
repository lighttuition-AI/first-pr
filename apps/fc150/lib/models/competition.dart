/// Competition models — a competition is either a season-long **league**
/// (Premier League: table / fixtures / results) or a knockout **cup**
/// (Champions League / World Cup: group stage + knockout bracket).

enum CompetitionKind { league, cup }

/// A tournament entrant. Decoupled from the 12-player roster so cups can include
/// guest teams. For league competitions the screen reads the existing Seed data.
class Competitor {
  final String name; // short, Title-case
  final String country; // ISO → flag bands
  final int rating;
  const Competitor(this.name, this.country, this.rating);

  String get initials =>
      name.split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join();
}

class GroupRow {
  final Competitor team;
  final int p, w, d, l, gf, ga, pts;
  const GroupRow(this.team, {required this.p, required this.w, required this.d, required this.l, required this.gf, required this.ga, required this.pts});
  int get gd => gf - ga;
}

class Group {
  final String name; // "Group A"
  final List<GroupRow> rows; // pre-sorted by standing
  const Group(this.name, this.rows);
}

/// One knockout tie. [a]/[b] are null when the slot is still "TBD".
class KnockoutTie {
  final String round; // "Quarter-finals" / "Semi-finals" / "Final"
  final Competitor? a, b;
  final int? sa, sb;
  final String status; // confirmed / locked / scheduled
  const KnockoutTie({required this.round, this.a, this.b, this.sa, this.sb, required this.status});
}

class Competition {
  final String id; // pl / ucl / wc
  final String name; // "Champions League"
  final String season; // "2025/26"
  final String title; // screen H2
  final String subtitle;
  final CompetitionKind kind;
  final List<Group> groups; // cup only
  final List<KnockoutTie> bracket; // cup only

  const Competition({
    required this.id,
    required this.name,
    required this.season,
    required this.title,
    required this.subtitle,
    required this.kind,
    this.groups = const [],
    this.bracket = const [],
  });

  bool get isCup => kind == CompetitionKind.cup;

  /// Distinct knockout rounds, in order of appearance.
  List<String> get rounds {
    final out = <String>[];
    for (final t in bracket) {
      if (!out.contains(t.round)) out.add(t.round);
    }
    return out;
  }
}
