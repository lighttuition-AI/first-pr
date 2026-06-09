import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/models.dart';
import 'seed_data.dart';

/// Firebase backend. Initialises Firestore, loads the shared collections into
/// the `Seed.*` lists the UI reads, and writes admin changes back. Everything is
/// wrapped so a network/Firebase failure falls back to the bundled seed content
/// — the app always works, even offline; it just isn't live.
class Backend {
  Backend._();

  static bool ready = false;
  static FirebaseFirestore? _db;

  /// Roster draft per competition (loaded from `rosters/*`).
  static final Map<String, Set<String>> rosters = {};

  /// Most recent broadcast, for cross-device delivery.
  static ({String message, int id})? latestBroadcast;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _db = FirebaseFirestore.instance;
      ready = true;
    } catch (_) {
      ready = false; // fall back to bundled seed
    }
  }

  /// Load shared data from Firestore into `Seed.*`. No-op (keeps bundled seed)
  /// if Firebase isn't ready, the DB is empty, or anything throws.
  static Future<void> load() async {
    if (!ready || _db == null) return;
    try {
      final db = _db!;
      final snaps = await Future.wait([
        db.collection('players').get(),
        db.collection('league').get(),
        db.collection('fixtures').get(),
        db.collection('results').get(),
        db.collection('invites').get(),
        db.collection('disputes').get(),
        db.collection('pendingReg').get(),
        db.collection('rosters').get(),
        db.collection('broadcasts').orderBy('createdAt', descending: true).limit(1).get(),
      ]);

      final playerDocs = snaps[0].docs;
      if (playerDocs.isEmpty) return; // empty DB → keep bundled seed

      final players = playerDocs.map((d) => Player.fromMap(d.data())).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      Seed.players = players;
      Seed.me = players.firstWhere((p) => p.id == 'p01', orElse: () => players.first);

      List<T> rows<T>(QuerySnapshot<Map<String, dynamic>> s, T Function(Map<String, dynamic>) f) =>
          s.docs.map((d) => f(d.data())).toList();

      final lg = rows(snaps[1], LeagueRow.fromMap)..sort((a, b) => a.pos.compareTo(b.pos));
      if (lg.isNotEmpty) Seed.league = lg;
      final fx = rows(snaps[2], Fixture.fromMap);
      if (fx.isNotEmpty) Seed.fixtures = fx;
      final rs = rows(snaps[3], MatchResult.fromMap);
      if (rs.isNotEmpty) Seed.results = rs;
      final inv = rows(snaps[4], Invite.fromMap);
      Seed.invites = inv; // may legitimately be empty
      Seed.disputes = rows(snaps[5], Dispute.fromMap);
      Seed.pendingReg = rows(snaps[6], PendingReg.fromMap);

      rosters.clear();
      for (final d in snaps[7].docs) {
        rosters[d.id] = ((d.data()['playerIds'] as List?)?.cast<String>() ?? const []).toSet();
      }

      final bdocs = snaps[8].docs;
      if (bdocs.isNotEmpty) {
        final m = bdocs.first.data();
        latestBroadcast = (message: m['message'] as String, id: (m['createdAt'] as num?)?.toInt() ?? 0);
      }
    } catch (_) {
      // keep whatever loaded; bundled seed covers the rest
    }
  }

  static Future<void> setRoster(String comp, Set<String> ids) async {
    rosters[comp] = ids;
    if (!ready || _db == null) return;
    try {
      await _db!.collection('rosters').doc(comp).set({'playerIds': ids.toList()});
    } catch (_) {}
  }

  static Future<void> pushBroadcast(String message) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    latestBroadcast = (message: message, id: id);
    if (!ready || _db == null) return;
    try {
      await _db!.collection('broadcasts').add({'message': message, 'createdAt': id});
    } catch (_) {}
  }
}
