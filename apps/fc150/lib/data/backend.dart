import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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

  /// True once a Firebase Auth session exists (anonymous or admin).
  static bool get signedIn => ready && FirebaseAuth.instance.currentUser != null;

  /// The signed-in player's own profile (`players/{uid}`), or null for
  /// anonymous/guest sessions (who use the seed identity).
  static Player? currentPlayer;

  /// Whether a real (non-anonymous) account is signed in.
  static bool get isRegistered {
    final u = ready ? FirebaseAuth.instance.currentUser : null;
    return u != null && !u.isAnonymous;
  }

  static int _ratingFor(String pos) => 80;

  static Stats _starterStats(String pos) {
    int c(int v) => v.clamp(34, 99);
    const ovr = 80;
    switch (pos) {
      case 'ATT':
        return Stats(pac: c(ovr - 2), sho: c(ovr + 1), pas: c(ovr - 16), dri: c(ovr - 4), def: c(ovr - 48), phy: c(ovr - 12));
      case 'DEF':
        return Stats(pac: c(ovr - 14), sho: c(ovr - 36), pas: c(ovr - 16), dri: c(ovr - 18), def: c(ovr + 1), phy: c(ovr - 2));
      default:
        return Stats(pac: c(ovr - 8), sho: c(ovr - 12), pas: c(ovr + 1), dri: c(ovr - 2), def: c(ovr - 18), phy: c(ovr - 10));
    }
  }

  static String _friendlyAuthError(String code) => switch (code) {
        'email-already-in-use' => 'That email already has an account — try signing in.',
        'invalid-email' => "That email doesn't look right.",
        'weak-password' => 'Pick a password with at least 6 characters.',
        'operation-not-allowed' => 'Email sign-in isn\'t enabled yet.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Wrong email or password.',
        'network-request-failed' => 'No connection — check your network.',
        _ => 'Something went wrong. Please try again.',
      };

  /// Create a new player account + their `players/{uid}` doc, and a pending
  /// registration for the admin to approve. Returns (ok, error?).
  static Future<({bool ok, String? error})> register({
    required String email,
    required String password,
    required String name,
    required String psn,
    required String pos,
    required String country,
  }) async {
    if (!ready || _db == null) return (ok: false, error: 'No connection to the server.');
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.trim(), password: password);
      final uid = cred.user!.uid;
      final player = Player(
        id: uid, name: name.trim().toUpperCase(), short: name.trim(), country: country,
        pos: pos, psn: psn.trim(), rating: _ratingFor(pos), stats: _starterStats(pos),
      );
      await _db!.collection('players').doc(uid).set(player.toMap());
      await _db!.collection('pendingReg').doc(uid).set({'id': uid, 'name': name.trim(), 'psn': psn.trim(), 'country': country, 'when': 'just now'});
      currentPlayer = player;
      return (ok: true, error: null);
    } on FirebaseAuthException catch (e) {
      return (ok: false, error: _friendlyAuthError(e.code));
    } catch (_) {
      return (ok: false, error: 'Something went wrong. Please try again.');
    }
  }

  /// Sign in to an existing account and load the player's profile.
  static Future<({bool ok, String? error})> signIn({required String email, required String password}) async {
    if (!ready || _db == null) return (ok: false, error: 'No connection to the server.');
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.trim(), password: password);
      final p = await loadCurrentPlayer();
      if (p == null) return (ok: true, error: null); // admin or profile-less account
      return (ok: true, error: null);
    } on FirebaseAuthException catch (e) {
      return (ok: false, error: _friendlyAuthError(e.code));
    } catch (_) {
      return (ok: false, error: 'Something went wrong. Please try again.');
    }
  }

  /// Load the signed-in (non-anonymous) user's player profile from Firestore.
  static Future<Player?> loadCurrentPlayer() async {
    if (!ready || _db == null) return null;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null || u.isAnonymous) return null;
    try {
      final doc = await _db!.collection('players').doc(u.uid).get();
      if (doc.exists) {
        currentPlayer = Player.fromMap(doc.data()!);
        return currentPlayer;
      }
    } catch (_) {}
    return null;
  }

  /// Bumped on sign-out so the root gate returns to onboarding.
  static final ValueNotifier<int> session = ValueNotifier<int>(0);

  static Future<void> signOut() async {
    currentPlayer = null;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    session.value++;
  }

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _db = FirebaseFirestore.instance;
      ready = true;
      // Give every device an authenticated session. Best-effort: if the
      // Anonymous provider isn't enabled in the Firebase console yet, this throws
      // and we carry on (reads still work under the current rules).
      try {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }
      } catch (_) {}
    } catch (_) {
      ready = false; // fall back to bundled seed
    }
  }

  /// Real admin sign-in (fire-and-forget). The caller has already checked the
  /// credentials locally; this establishes a Firebase Auth session for the admin
  /// account (creating it on first use). No-op if Email/Password isn't enabled.
  static Future<void> adminSignIn(String email, String password) async {
    if (!ready) return;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        } catch (_) {}
      }
    } catch (_) {}
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
