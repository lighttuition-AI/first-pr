/// FC150 data models. These mirror the seed shapes in the design handoff
/// (frames/AppData.jsx) and map cleanly onto the suggested Firestore
/// collections (users, cards, challenges, results, leagues) for later.

/// Player attributes. Order on the card fills row-wise: PAC, DRI / SHO, DEF /
/// PAS, PHY. FC26 mapping lives in the README.
class Stats {
  final int pac, sho, pas, dri, def, phy;
  const Stats({
    required this.pac,
    required this.sho,
    required this.pas,
    required this.dri,
    required this.def,
    required this.phy,
  });

  int byKey(String k) => switch (k) {
        'pac' => pac,
        'sho' => sho,
        'pas' => pas,
        'dri' => dri,
        'def' => def,
        'phy' => phy,
        _ => 0,
      };

  /// Used by the "Half-season upgrade" reveal to show the pre-upgrade bars.
  Stats minus(Stats d) => Stats(
        pac: pac - d.pac,
        sho: sho - d.sho,
        pas: pas - d.pas,
        dri: dri - d.dri,
        def: def - d.def,
        phy: phy - d.phy,
      );
}

class Player {
  final String id;
  final String name; // UPPERCASE display name
  final String short; // Title-case short name
  final String country; // ISO code → flag bands
  final String pos; // ATT / MID / DEF
  final String psn;
  final int rating;
  final String tier; // base / platinum / gold / silver
  final String variant; // neon / holo / mono / platinum
  final Stats stats;
  String? photo; // local file path (mutable for the current user)

  Player({
    required this.id,
    required this.name,
    required this.short,
    required this.country,
    required this.pos,
    required this.psn,
    required this.rating,
    this.tier = 'base',
    this.variant = 'neon',
    required this.stats,
    this.photo,
  });

  String get initials =>
      short.split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join();
}

class LeagueRow {
  final int pos;
  final String id;
  final int p, w, d, l, gf, ga, pts;
  final List<String> form;
  const LeagueRow({
    required this.pos,
    required this.id,
    required this.p,
    required this.w,
    required this.d,
    required this.l,
    required this.gf,
    required this.ga,
    required this.pts,
    required this.form,
  });
  int get gd => gf - ga;
}

class Fixture {
  final String id, a, b, when, comp, status;
  final int md;
  const Fixture({
    required this.id,
    required this.a,
    required this.b,
    required this.when,
    required this.comp,
    required this.md,
    required this.status,
  });
}

class MatchResult {
  final String id, a, b, comp, when, status;
  final int sa, sb;
  const MatchResult({
    required this.id,
    required this.a,
    required this.b,
    required this.sa,
    required this.sb,
    required this.comp,
    required this.when,
    required this.status,
  });
}

class Invite {
  final String id, from, mode, when, comp, status;
  const Invite({
    required this.id,
    required this.from,
    required this.mode,
    required this.when,
    required this.comp,
    required this.status,
  });
}

class CareerCard {
  final String id, comp, season, label, variant, tier, date, record;
  final int rating;
  final Stats stats;
  const CareerCard({
    required this.id,
    required this.comp,
    required this.season,
    required this.label,
    required this.variant,
    required this.tier,
    required this.rating,
    required this.date,
    required this.record,
    required this.stats,
  });
}

class AppNotification {
  final String id, kind, text, time;
  final bool unread;
  const AppNotification({
    required this.id,
    required this.kind,
    required this.text,
    required this.time,
    required this.unread,
  });
}

class PendingReg {
  final String id, name, psn, country, when;
  const PendingReg({
    required this.id,
    required this.name,
    required this.psn,
    required this.country,
    required this.when,
  });
  String get initials =>
      name.split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join();
}

class Dispute {
  final String id, a, b, claimA, claimB, when;
  const Dispute({
    required this.id,
    required this.a,
    required this.b,
    required this.claimA,
    required this.claimB,
    required this.when,
  });
}
