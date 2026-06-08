import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_data.dart';
import '../models/models.dart';

/// Lightweight app state. In production this is backed by Firebase Auth +
/// Firestore; here it holds the seed current-user, the persisted active tab,
/// the league sub-tab deep-link, and the per-session Top-3 flag.
class AppState extends ChangeNotifier {
  AppState() {
    _restore();
  }

  final Player currentUser = Seed.me;

  int _activeTab = 0; // 0 Home · 1 Arena · 2 League · 3 Cards · 4 Admin
  int get activeTab => _activeTab;

  String _leagueSubTab = 'table';
  String get leagueSubTab => _leagueSubTab;

  bool top3Seen = false;

  SharedPreferences? _prefs;
  bool _tabTouched = false; // guard: don't let a late prefs load clobber a deep-link

  Future<void> _restore() async {
    _prefs = await SharedPreferences.getInstance();
    // Only apply the persisted tab if the user (or a deep-link) hasn't navigated yet.
    if (!_tabTouched) _activeTab = _prefs?.getInt('activeTab') ?? 0;
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

  void setPhoto(String? path) {
    currentUser.photo = path;
    notifyListeners();
  }
}
