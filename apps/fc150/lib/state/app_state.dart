import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/competitions.dart';
import '../data/seed_data.dart';
import '../models/competition.dart';
import '../models/models.dart';

/// App state, persisted to the device so a player's data survives close/reopen.
///
/// Everything mutable here is written to [SharedPreferences] as it changes and
/// reloaded on launch in [_restore]: the active tab + competition, the card
/// photo, admin sign-in, broadcasts, the admin roster draft, which invitations
/// were accepted/declined, and the player's friendly-challenge record.
///
/// This is single-device persistence. A real multi-user backend (Firebase Auth
/// + Firestore + Storage) is the next milestone — see PROJECT_NOTES "Roadmap".
class AppState extends ChangeNotifier {
  AppState() {
    _restore();
  }

  final Player currentUser = Seed.me;

  int _activeTab = 0; // 0 Home · 1 Arena · 2 League · 3 Cards · 4 Roster · 5 Control
  int get activeTab => _activeTab;

  // ---- Admin roster drafting -------------------------------------------------
  static const Map<String, int> rosterCaps = {'pl': 38, 'ucl': 32, 'wc': 32};

  final Map<String, Set<String>> _rosters = {
    'pl': {for (final p in Seed.players) p.id},
    'ucl': <String>{},
    'wc': <String>{},
  };

  Set<String> rosterFor(String compId) => _rosters.putIfAbsent(compId, () => <String>{});
  int capOf(String compId) => rosterCaps[compId] ?? 38;
  bool isPlaced(String compId, String playerId) => rosterFor(compId).contains(playerId);
  bool isFull(String compId) => rosterFor(compId).length >= capOf(compId);

  bool toggleRoster(String compId, String playerId) {
    final set = rosterFor(compId);
    if (set.remove(playerId)) {
      _saveRosters();
      notifyListeners();
      return true;
    }
    if (set.length >= capOf(compId)) return false; // full
    set.add(playerId);
    _saveRosters();
    notifyListeners();
    return true;
  }

  void _saveRosters() => _prefs?.setString('rosters', jsonEncode(_rosters.map((k, v) => MapEntry(k, v.toList()))));

  String _leagueSubTab = 'table';
  String get leagueSubTab => _leagueSubTab;

  String _competitionId = 'pl';
  Competition get competition => Comps.byId(_competitionId);

  bool top3Seen = false;

  // ---- Admin auth (prototype) -----------------------------------------------
  // In production this is Firebase Auth + a custom "admin" claim. Two fixed
  // accounts unlock the management tabs; everyone else is a player.
  static const Set<String> adminEmails = {'admin@fc150.com', 'admin2@fc150.com'};
  static const String adminPassword = '150!2026*fc';

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;
  bool _adminTouched = false;

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
    if (_activeTab > 3) _activeTab = 0;
    notifyListeners();
  }

  void setAdmin(bool v) {
    _adminTouched = true;
    _isAdmin = v;
    notifyListeners();
  }

  // ---- Broadcast ------------------------------------------------------------
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

  // ---- Challenge invitations -------------------------------------------------
  final List<Invite> _invites = List.of(Seed.invites);
  List<Invite> get invites => List.unmodifiable(_invites);

  final List<Invite> _acceptedFriendlies = [];
  List<Invite> get acceptedFriendlies => List.unmodifiable(_acceptedFriendlies);

  void acceptInvite(Invite inv) {
    _invites.removeWhere((i) => i.id == inv.id);
    if (_acceptedFriendlies.every((i) => i.id != inv.id)) _acceptedFriendlies.add(inv);
    _saveInvites();
    notifyListeners();
  }

  void declineInvite(Invite inv) {
    _invites.removeWhere((i) => i.id == inv.id);
    _saveInvites();
    notifyListeners();
  }

  void _saveInvites() {
    final accepted = _acceptedFriendlies.map((i) => i.id).toList();
    final live = _invites.map((i) => i.id).toSet();
    final declined = [
      for (final i in Seed.invites)
        if (!live.contains(i.id) && !accepted.contains(i.id)) i.id,
    ];
    _prefs?.setStringList('invitesAccepted', accepted);
    _prefs?.setStringList('invitesDeclined', declined);
  }

  // ---- Friendly-challenge record (drives the Friendly card) ------------------
  // Ranking is by games *played* — volume wins — then by results.
  int _fPlayed = 0, _fWon = 0, _fDrawn = 0, _fLost = 0;
  int get friendlyPlayed => _fPlayed;
  int get friendlyWon => _fWon;
  int get friendlyDrawn => _fDrawn;
  int get friendlyLost => _fLost;

  /// Record a friendly result. [outcome] is 'win' | 'draw' | 'loss'.
  void recordFriendlyResult(String outcome) {
    _fPlayed++;
    if (outcome == 'win') {
      _fWon++;
    } else if (outcome == 'draw') {
      _fDrawn++;
    } else {
      _fLost++;
    }
    _saveFriendly();
    notifyListeners();
  }

  /// Complete an accepted friendly with a result — removes it from upcoming and
  /// updates the record.
  void completeFriendly(Invite inv, String outcome) {
    _acceptedFriendlies.removeWhere((i) => i.id == inv.id);
    _saveInvites();
    recordFriendlyResult(outcome); // saves friendly + notifies
  }

  void _saveFriendly() => _prefs?.setString('friendly', jsonEncode({'p': _fPlayed, 'w': _fWon, 'd': _fDrawn, 'l': _fLost}));

  // ---- Persistence -----------------------------------------------------------
  SharedPreferences? _prefs;
  bool _tabTouched = false;
  bool _restored = false;
  bool get restored => _restored;

  Future<void> _restore() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;

    if (!_tabTouched) _activeTab = p.getInt('activeTab') ?? 0;
    _competitionId = p.getString('competitionId') ?? 'pl';
    if (!_adminTouched) _isAdmin = p.getBool('isAdmin') ?? false;

    _broadcastMsg = p.getString('broadcastMsg');
    _broadcastId = p.getInt('broadcastId') ?? 0;
    _lastSeenBroadcast = p.getInt('lastSeenBroadcast') ?? 0;

    currentUser.photo = p.getString('photo');

    // Roster draft.
    final rostersJson = p.getString('rosters');
    if (rostersJson != null) {
      final decoded = jsonDecode(rostersJson) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _rosters[entry.key] = {for (final id in (entry.value as List)) id as String};
      }
    }

    // Invitations.
    final accepted = p.getStringList('invitesAccepted') ?? const [];
    final declined = (p.getStringList('invitesDeclined') ?? const []).toSet();
    if (accepted.isNotEmpty || declined.isNotEmpty) {
      _acceptedFriendlies
        ..clear()
        ..addAll(Seed.invites.where((i) => accepted.contains(i.id)));
      _invites
        ..clear()
        ..addAll(Seed.invites.where((i) => !accepted.contains(i.id) && !declined.contains(i.id)));
    }

    // Friendly record.
    final friendlyJson = p.getString('friendly');
    if (friendlyJson != null) {
      final f = jsonDecode(friendlyJson) as Map<String, dynamic>;
      _fPlayed = f['p'] ?? 0;
      _fWon = f['w'] ?? 0;
      _fDrawn = f['d'] ?? 0;
      _fLost = f['l'] ?? 0;
    }

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

  void setCompetition(String id) {
    _competitionId = id;
    _leagueSubTab = Comps.byId(id).isCup ? 'groups' : 'table';
    _prefs?.setString('competitionId', id);
    notifyListeners();
  }

  void setPhoto(String? path) {
    currentUser.photo = path;
    if (path == null) {
      _prefs?.remove('photo');
    } else {
      _prefs?.setString('photo', path);
    }
    notifyListeners();
  }
}
