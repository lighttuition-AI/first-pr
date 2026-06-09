import 'package:flutter/material.dart';

import '../models/models.dart';

/// FC150 seed data — PlayStation FC26 Challenge Arena. Mirrors
/// frames/AppData.jsx. Seed player is Khadar Agab · Netherlands · ATT · 94 OVR.
/// In production these become Firestore documents.
class Seed {
  Seed._();

  static final Player me = Player(
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

  static final List<Player> players = [
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
  ];

  static Player byId(String id) =>
      players.firstWhere((p) => p.id == id, orElse: () => players.first);

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

  // League table (38-game season — mid-season snapshot).
  static const List<LeagueRow> league = [
    LeagueRow(pos: 1, id: 'p02', p: 19, w: 14, d: 3, l: 2, gf: 41, ga: 16, pts: 45, form: ['W', 'W', 'D', 'W', 'W']),
    LeagueRow(pos: 2, id: 'p01', p: 19, w: 13, d: 4, l: 2, gf: 44, ga: 19, pts: 43, form: ['W', 'W', 'W', 'D', 'W']),
    LeagueRow(pos: 3, id: 'p03', p: 19, w: 12, d: 5, l: 2, gf: 30, ga: 13, pts: 41, form: ['D', 'W', 'W', 'W', 'D']),
    LeagueRow(pos: 4, id: 'p04', p: 19, w: 12, d: 2, l: 5, gf: 38, ga: 22, pts: 38, form: ['W', 'L', 'W', 'W', 'L']),
    LeagueRow(pos: 5, id: 'p05', p: 19, w: 10, d: 6, l: 3, gf: 33, ga: 21, pts: 36, form: ['D', 'W', 'D', 'W', 'W']),
    LeagueRow(pos: 6, id: 'p06', p: 19, w: 10, d: 3, l: 6, gf: 35, ga: 27, pts: 33, form: ['W', 'W', 'L', 'D', 'W']),
    LeagueRow(pos: 7, id: 'p08', p: 19, w: 9, d: 4, l: 6, gf: 29, ga: 25, pts: 31, form: ['L', 'W', 'D', 'W', 'D']),
    LeagueRow(pos: 8, id: 'p07', p: 19, w: 8, d: 5, l: 6, gf: 22, ga: 21, pts: 29, form: ['D', 'D', 'W', 'L', 'W']),
    LeagueRow(pos: 9, id: 'p10', p: 19, w: 7, d: 5, l: 7, gf: 27, ga: 28, pts: 26, form: ['W', 'L', 'D', 'L', 'W']),
    LeagueRow(pos: 10, id: 'p09', p: 19, w: 6, d: 6, l: 7, gf: 25, ga: 28, pts: 24, form: ['D', 'L', 'W', 'D', 'L']),
    LeagueRow(pos: 11, id: 'p11', p: 19, w: 5, d: 5, l: 9, gf: 18, ga: 29, pts: 20, form: ['L', 'D', 'L', 'W', 'L']),
    LeagueRow(pos: 12, id: 'p12', p: 19, w: 3, d: 4, l: 12, gf: 17, ga: 38, pts: 13, form: ['L', 'L', 'D', 'L', 'L']),
  ];

  static const List<Fixture> fixtures = [
    Fixture(id: 'f1', a: 'p01', b: 'p06', when: 'Today · 20:30', comp: 'Premier League', md: 20, status: 'locked'),
    Fixture(id: 'f2', a: 'p03', b: 'p05', when: 'Today · 21:00', comp: 'Premier League', md: 20, status: 'scheduled'),
    Fixture(id: 'f3', a: 'p02', b: 'p04', when: 'Tomorrow · 19:00', comp: 'Premier League', md: 20, status: 'scheduled'),
    Fixture(id: 'f4', a: 'p01', b: 'p09', when: 'Sat · 18:30', comp: 'Premier League', md: 21, status: 'scheduled'),
  ];

  static const List<MatchResult> results = [
    MatchResult(id: 'r1', a: 'p01', b: 'p10', sa: 4, sb: 1, comp: 'Premier League', when: 'Yesterday', status: 'confirmed'),
    MatchResult(id: 'r2', a: 'p02', b: 'p07', sa: 2, sb: 0, comp: 'Premier League', when: 'Yesterday', status: 'confirmed'),
    MatchResult(id: 'r3', a: 'p08', b: 'p03', sa: 1, sb: 1, comp: 'Premier League', when: '2 days ago', status: 'confirmed'),
    MatchResult(id: 'r4', a: 'p06', b: 'p12', sa: 3, sb: 0, comp: 'Premier League', when: '2 days ago', status: 'noshow'),
  ];

  static const List<Invite> invites = [
    Invite(id: 'inv1', from: 'p06', mode: '1v1', when: 'Today · 20:30', comp: 'Friendly', status: 'pending'),
    Invite(id: 'inv2', from: 'p10', mode: '1v1', when: 'Fri · 21:30', comp: 'Friendly', status: 'pending'),
  ];

  static const List<CareerCard> collection = [
    CareerCard(id: 'c1', comp: 'Premier League', season: '2025/26', label: 'Mid-season', variant: 'neon', tier: 'base', rating: 94, date: 'Jun 2026', record: '13W · 4D · 2L', stats: Stats(pac: 92, sho: 95, pas: 78, dri: 90, def: 42, phy: 84)),
    CareerCard(id: 'c2', comp: 'Premier League', season: '2025/26', label: 'Matchday 1', variant: 'neon', tier: 'base', rating: 88, date: 'Aug 2025', record: 'New season', stats: Stats(pac: 86, sho: 88, pas: 72, dri: 84, def: 40, phy: 80)),
    CareerCard(id: 'c3', comp: 'Top 3 · Rank 2', season: '2024/25', label: 'Gold winner', variant: 'platinum', tier: 'gold', rating: 91, date: 'May 2025', record: 'Runner-up', stats: Stats(pac: 89, sho: 90, pas: 74, dri: 87, def: 41, phy: 82)),
    CareerCard(id: 'c4', comp: 'Champions League', season: '2024/25', label: 'Champion', variant: 'holo', tier: 'base', rating: 92, date: 'Apr 2025', record: 'Winner', stats: Stats(pac: 90, sho: 92, pas: 75, dri: 88, def: 42, phy: 83)),
  ];

  static const List<AppNotification> notifs = [
    AppNotification(id: 'n1', kind: 'challenge', text: 'Adam Osman challenged you · Today 20:30', time: '5m', unread: true),
    AppNotification(id: 'n2', kind: 'locked', text: 'Match locked vs Adam Osman', time: '4m', unread: true),
    AppNotification(id: 'n3', kind: 'result', text: 'Result confirmed: you beat Kenji Sato 4–1', time: '1d', unread: false),
    AppNotification(id: 'n4', kind: 'card', text: 'Your card upgraded to 94 OVR (+2)', time: '1d', unread: false),
    AppNotification(id: 'n5', kind: 'top3', text: 'Top 3 announced for Premier League', time: '2d', unread: false),
  ];

  static const List<PendingReg> pendingReg = [
    PendingReg(id: 'pr1', name: 'Ismail Warsame', psn: 'WARSAME_10', country: 'SO', when: '12m ago'),
    PendingReg(id: 'pr2', name: 'Sven Eriksson', psn: 'SVEN_E', country: 'SE', when: '1h ago'),
    PendingReg(id: 'pr3', name: 'Diego Santos', psn: 'SANTOS_BR', country: 'BR', when: '3h ago'),
  ];

  static const List<Dispute> disputes = [
    Dispute(id: 'd1', a: 'p06', b: 'p12', claimA: '3–0 win', claimB: 'No-show, replay', when: '20m ago'),
  ];
}
