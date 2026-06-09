import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/competitions.dart';
import '../data/seed_data.dart';
import '../models/competition.dart';
import '../models/models.dart';

/// Lightweight app state. In production this is backed by Firebase Auth +
/// Firestore; here it holds the seed current-user, the persisted active tab,
/// the league sub-tab deep-link, and the per-session Top-3 flag.
class AppState extends ChangeNotifier {
  AppState() {
    _restore();
  }

  final Player currentUser = Seed.me;

  int _activeTab = 0; // 0 Home · 1 Arena · 2 League · 3 Cards · 4 Roster · 5 Admin
  int get activeTab => _activeTab;

  // ---- Admin roster drafting -------------------------------------------------
  // Which approved players the admin has placed into each competition. More
  // players register than a competition can hold, so this is the admin's pick.
  // In production these become the competition's entrant documents.
  static const Map<String, int> rosterCaps = {'pl': 38, 'wc': 32};

  final Map<String, Set<String>> _rosters = {
    // Start with the 12 named players already placed in the league.
    'pl': {for (final p in Seed.players) p.id},
    'wc': <String>{},
  };

  Set<String> rosterFor(String compId) => _rosters.putIfAbsent(compId, () => <String>{});
  int capOf(String compId) => rosterCaps[compId] ?? 38;
  bool isPlaced(String compId, String playerId) => rosterFor(compId).contains(playerId);
  bool isFull(String compId) => rosterFor(compId).length >= capOf(compId);

  /// Toggle a player in/out of a competition. Returns false (without changing
  /// anything) when adding would exceed the cap, so the UI can warn.
  bool toggleRoster(String compId, String playerId) {
    final set = rosterFor(compId);
    if (set.remove(playerId)) {
      notifyListeners();
      return true;
    }
    if (set.length >= capOf(compId)) return false; // full
    set.add(playerId);
    notifyListeners();
    return true;
  }

  String _leagueSubTab = 'table';
  String get leagueSubTab => _leagueSubTab;

  // Active competition shown on the League screen (pl / ucl / wc).
  String _competitionId = 'pl';
  Competition get competition => Comps.byId(_competitionId);

  bool top3Seen = false;

  // ---- Admin auth (prototype) -----------------------------------------------
  // In production this is Firebase Auth + a custom "admin" claim. Here two fixed
  // admin accounts unlock the Admin + Roster tabs; everyone else is a player and
  // never sees them.
  static const Set<String> adminEmails = {'admin@fc150.com', 'admin2@fc150.com'};
  static const String adminPassword = '150!2026*fc';

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;
  bool _adminTouched = false; // guard: don't let a late prefs load clobber a session change

  /// Validate credentials and, on success, unlock the admin tabs. Returns whether
  /// the login was accepted.
  bool tryAdminLogin(String email, String password) {
    final ok = adminEmails.contains(email.trim().toLowerCase()) && password == adminPassword;
    if (ok) {
      _adminTouched = true;
      _isAdmin = true;
      _prefs?.setBool('isAdmin', true);
      notifyListeners();
    }
    return ok;
  }

  void logoutAdmin() {
    _adminTouched = true;
    _isAdmin = false;
    _prefs?.setBool('isAdmin', false);
    if (_activeTab > 3) _activeTab = 0; // leave the now-hidden admin-only tabs
    notifyListeners();
  }

  /// QA/testing convenience (compile-time hooks only).
  void setAdmin(bool v) {
    _adminTouched = true;
    _isAdmin = v;
    notifyListeners();
  }

  // ---- Broadcast ------------------------------------------------------------
  // Admin pushes a message; every player gets it as a popup the next time they
  // open the app. Tracked by id so it shows exactly once per device.
  String? _broadcastMsg;
  int _broadcastId = 0;
  int _lastSeenBroadcast = 0;

  String? get pendingBroadcast =>
      (_broadcastMsg != null && _broadcastMsg!.isNotEmpty && _broadcastId != _lastSeenBroadcast) ? _broadcastMsg : null;

  void pushBroadcast(String msg) {
    _broadcastMsg = msg.trim();
    _broadcastId = DateTime.now().millisecondsSinceEpoch;
    _prefs?.setString('broadcastMsg', _broadcastMsg!);
    _prefs?.setInt('broadcastId', _broadcastId);
    notifyListeners();
  }

  void markBroadcastSeen() {
    _lastSeenBroadcast = _broadcastId;
    _prefs?.setInt('lastSeenBroadcast', _broadcastId);
  }

  SharedPreferences? _prefs;
  bool _tabTouched = false; // guard: don't let a late prefs load clobber a deep-link

  bool _restored = false;
  bool get restored => _restored;

  Future<void> _restore() async {
    _prefs = await SharedPreferences.getInstance();
    // Only apply the persisted tab if the user (or a deep-link) hasn't navigated yet.
    if (!_tabTouched) _activeTab = _prefs?.getInt('activeTab') ?? 0;
    if (!_adminTouched) _isAdmin = _prefs?.getBool('isAdmin') ?? false;
    _broadcastMsg = _prefs?.getString('broadcastMsg');
    _broadcastId = _prefs?.getInt('broadcastId') ?? 0;
    _lastSeenBroadcast = _prefs?.getInt('lastSeenBroadcast') ?? 0;
    _restored = true;
    notifyListeners();
  }

  void setTab(int i, {String? leagueSubTab}) {
    _tabTouched = true;
    _activeTab = i;
    if (leagueSubTab != null) _leagueSubTab = leagueSubTab;
    _prefs?.setInt('activeTab', i);
    notifyListeners();
  }

  void setLeagueSubTab(String t) {
    _leagueSubTab = t;
    notifyListeners();
  }

  /// Switch competition and reset the sub-tab to that format's default.
  void setCompetition(String id) {
    _competitionId = id;
    _leagueSubTab = Comps.byId(id).isCup ? 'groups' : 'table';
    notifyListeners();
  }

  void setPhoto(String? path) {
    currentUser.photo = path;
    notifyListeners();
  }
}
