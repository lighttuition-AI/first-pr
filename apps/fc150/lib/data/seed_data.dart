import 'package:flutter/material.dart';

import '../models/models.dart';

/// FC150 seed data — PlayStation FC26 Challenge Arena. Mirrors
/// frames/AppData.jsx. Seed player is Khadar Agab · Netherlands · ATT · 94 OVR.
/// In production these become Firestore documents.
class Seed {
  Seed._();

  // These start as the bundled defaults and are replaced at launch with live
  // Firestore data (see lib/data/backend.dart). They stay mutable so the
  // backend can swap in real documents while the UI keeps reading `Seed.*`.
  static Player me = Player(
    id: 'p01',
    name: 'KHADAR AGAB',
    short: 'Khadar Agab',
    country: 'NL',
    pos: 'ATT',
    psn: 'AGAB_010',
    rating: 94,
    tier: 'base',
    variant: 'neon',
    stats: const Stats(pac: 92, sho: 95, pas: 78, dri: 90, def: 42, phy: 84),
  );

  // The full approved pool (named + generated). `players` and `roster` are the
  // same list; the league/fixtures reference the first 12 by id.
  static List<Player> players = [
    me,
    Player(id: 'p02', name: 'HODAN ALI', short: 'Hodan Ali', country: 'SO', pos: 'MID', psn: 'HODA_07', rating: 93, stats: const Stats(pac: 84, sho: 80, pas: 91, dri: 88, def: 70, phy: 79)),
    Player(id: 'p03', name: 'GULED FARAH', short: 'Guled Farah', country: 'SO', pos: 'DEF', psn: 'GULED_FC', rating: 91, stats: const Stats(pac: 78, sho: 55, pas: 75, dri: 74, def: 90, phy: 88)),
    Player(id: 'p04', name: 'LIAM DE JONG', short: 'Liam de Jong', country: 'NL', pos: 'ATT', psn: 'LIAM_NL9', rating: 90, stats: const Stats(pac: 90, sho: 88, pas: 76, dri: 86, def: 40, phy: 82)),
    Player(id: 'p05', name: 'NOAH KEITA', short: 'Noah Keita', country: 'SN', pos: 'MID', psn: 'KEITA_X', rating: 89, stats: const Stats(pac: 82, sho: 79, pas: 87, dri: 85, def: 72, phy: 80)),
    Player(id: 'p06', name: 'ADAM OSMAN', short: 'Adam Osman', country: 'SO', pos: 'ATT', psn: 'OSMAN_AD', rating: 88, stats: const Stats(pac: 88, sho: 86, pas: 70, dri: 84, def: 38, phy: 79)),
    Player(id: 'p07', name: 'YUSUF RASHID', short: 'Yusuf Rashid', country: 'SO', pos: 'DEF', psn: 'YR_WALL', rating: 87, stats: const Stats(pac: 75, sho: 50, pas: 72, dri: 70, def: 88, phy: 86)),
    Player(id: 'p08', name: 'MARCO BIANCHI', short: 'Marco Bianchi', country: 'IT', pos: 'MID', psn: 'BIANCHI8', rating: 86, stats: const Stats(pac: 80, sho: 74, pas: 85, dri: 83, def: 68, phy: 77)),
    Player(id: 'p09', name: 'OMAR SHEIKH', short: 'Omar Sheikh', country: 'SO', pos: 'ATT', psn: 'OMAR_S10', rating: 85, stats: const Stats(pac: 86, sho: 83, pas: 68, dri: 82, def: 36, phy: 75)),
    Player(id: 'p10', name: 'KENJI SATO', short: 'Kenji Sato', country: 'JP', pos: 'MID', psn: 'SATO_K', rating: 84, stats: const Stats(pac: 83, sho: 72, pas: 84, dri: 86, def: 64, phy: 70)),
    Player(id: 'p11', name: 'TOMAS NOVAK', short: 'Tomas Novak', country: 'CZ', pos: 'DEF', psn: 'NOVAK_CZ', rating: 83, stats: const Stats(pac: 72, sho: 48, pas: 70, dri: 68, def: 85, phy: 84)),
    Player(id: 'p12', name: 'BILAL HASSAN', short: 'Bilal Hassan', country: 'SO', pos: 'ATT', psn: 'BILAL_H', rating: 82, stats: const Stats(pac: 85, sho: 80, pas: 66, dri: 80, def: 34, phy: 73)),
    ..._generatedRoster(),
  ];

  static Player byId(String id) =>
      players.firstWhere((p) => p.id == id, orElse: () => players.first);

  /// Approved registrants the admin can draft into competitions (= the whole
  /// `players` pool; more register than a competition can hold).
  static List<Player> get roster => players;

  static Stats _statsFor(String pos, int ovr) {
    int c(int v) => v.clamp(34, 99);
    switch (pos) {
      case 'ATT':
        return Stats(pac: c(ovr - 2), sho: c(ovr + 1), pas: c(ovr - 16), dri: c(ovr - 4), def: c(ovr - 48), phy: c(ovr - 12));
      case 'DEF':
        return Stats(pac: c(ovr - 14), sho: c(ovr - 36), pas: c(ovr - 16), dri: c(ovr - 18), def: c(ovr + 1), phy: c(ovr - 2));
      default: // MID
        return Stats(pac: c(ovr - 8), sho: c(ovr - 12), pas: c(ovr + 1), dri: c(ovr - 2), def: c(ovr - 18), phy: c(ovr - 10));
    }
  }

  static List<Player> _generatedRoster() {
    // (short name, ISO country) — countries map onto the flag bands above.
    const names = <(String, String)>[
      ('Aron Visser', 'NL'), ('Mateo Rossi', 'IT'), ('Daud Jama', 'SO'),
      ('Lars Berg', 'SE'), ('Hiro Mori', 'JP'), ('Pavel Dvorak', 'CZ'),
      ('Bruno Alves', 'BR'), ('Tiago Costa', 'PT'), ('Luis Reyes', 'MX'),
      ('Mamadou Diop', 'SN'), ('Sem Bakker', 'NL'), ('Gianni Conti', 'IT'),
      ('Said Nur', 'SO'), ('Felix Holm', 'SE'), ('Ren Kato', 'JP'),
      ('Jan Kucera', 'CZ'), ('Caio Lima', 'BR'), ('Diogo Faria', 'PT'),
      ('Mateo Cruz', 'MX'), ('Ousmane Ba', 'SN'), ('Tim Mulder', 'NL'),
      ('Enzo Greco', 'IT'), ('Abdi Yusuf', 'SO'), ('Nils Sand', 'SE'),
      ('Sota Abe', 'JP'), ('Petr Marek', 'CZ'), ('Rafael Souza', 'BR'),
      ('Hugo Pinto', 'PT'), ('Ivan Lopez', 'MX'), ('Cheikh Fall', 'SN'),
      ('Daan Smit', 'NL'), ('Luca Ferri', 'IT'), ('Farah Aden', 'SO'),
      ('Emil Lund', 'SE'), ('Kenta Ito', 'JP'), ('Milan Horak', 'CZ'),
      ('Pedro Rocha', 'BR'), ('Andre Melo', 'PT'),
    ];
    const positions = ['ATT', 'MID', 'DEF'];
    return [
      for (var i = 0; i < names.length; i++)
        _mkPlayer(i, names[i], positions[i % 3]),
    ];
  }

  static Player _mkPlayer(int i, (String, String) n, String pos) {
    final ovr = 86 - i; // 86 down to ~49 — below the named roster
    final psn = n.$1.toUpperCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^A-Z_]'), '');
    return Player(
      id: 'r${(i + 13).toString().padLeft(2, '0')}',
      name: n.$1.toUpperCase(),
      short: n.$1,
      country: n.$2,
      pos: pos,
      psn: psn,
      rating: ovr,
      stats: _statsFor(pos, ovr),
    );
  }

  /// Simple geometric horizontal flag bands (original art, not official).
  static const Map<String, List<Color>> flags = {
    'NL': [Color(0xFFAE1C28), Color(0xFFFFFFFF), Color(0xFF21468B)],
    'SO': [Color(0xFF4189DD), Color(0xFF4189DD), Color(0xFF4189DD)],
    'SN': [Color(0xFF00853F), Color(0xFFFDEF42), Color(0xFFE31B23)],
    'IT': [Color(0xFF009246), Color(0xFFFFFFFF), Color(0xFFCE2B37)],
    'JP': [Color(0xFFFFFFFF), Color(0xFFBC002D), Color(0xFFFFFFFF)],
    'CZ': [Color(0xFF11457E), Color(0xFFFFFFFF), Color(0xFFD7141A)],
    'SE': [Color(0xFF006AA7), Color(0xFFFECC00), Color(0xFF006AA7)],
    'BR': [Color(0xFF009C3B), Color(0xFFFFDF00), Color(0xFF009C3B)],
    'PT': [Color(0xFF046A38), Color(0xFFDA291C), Color(0xFFFFE900)],
    'MX': [Color(0xFF006847), Color(0xFFFFFFFF), Color(0xFFCE1126)],
  };

  static List<Color> flagOf(String code) => flags[code] ?? flags['NL']!;

  /// Country flag as an OS emoji (e.g. 'NL' → 🇳🇱); null for invalid codes.
  static String? flagEmoji(String code) {
    final cc = code.trim().toUpperCase();
    if (cc.length != 2 || !RegExp(r'^[A-Z]{2}$').hasMatch(cc)) return null;
    return String.fromCharCodes([0x1F1E6 + cc.codeUnitAt(0) - 65, 0x1F1E6 + cc.codeUnitAt(1) - 65]);
  }

  // Match/season data is empty at launch — nothing has been played yet. Live
  // data comes from Firestore (backend.dart); these are the clean-slate fallback.
  // League/cup standings are built from the accepted rosters (zeroed) by the
  // League screen until the admin starts a season and results come in.
  static List<LeagueRow> league = [];
  static List<Fixture> fixtures = [];
  static List<MatchResult> results = [];
  static List<Invite> invites = [];
  static const List<CareerCard> collection = [];
  static const List<AppNotification> notifs = [];
  static List<PendingReg> pendingReg = [];
  static List<Dispute> disputes = [];
}
