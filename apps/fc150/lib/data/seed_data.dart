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

  // The approved player pool. Empty at launch — populated from Firestore as real
  // players register and the admin accepts them (backend.dart). `me` is the
  // local guest identity used only for "Explore as guest".
  static List<Player> players = [];

  static Player byId(String id) =>
      players.firstWhere((p) => p.id == id, orElse: () => me);

  /// Approved registrants the admin can draft into competitions (= the `players`
  /// pool). Empty until real players are accepted.
  static List<Player> get roster => players;

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
