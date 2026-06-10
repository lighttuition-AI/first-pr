// Admin auth, broadcast and competition-shape tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fc150/data/competitions.dart';
import 'package:fc150/data/seed_data.dart';
import 'package:fc150/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('only the provisioned admin credentials unlock admin mode', () {
    final app = AppState();
    expect(app.isAdmin, isFalse);

    expect(app.tryAdminLogin('player@somewhere.com', 'whatever'), isFalse);
    expect(app.tryAdminLogin('admin@fc150.com', 'wrong'), isFalse);
    expect(app.isAdmin, isFalse);

    expect(app.tryAdminLogin('admin@fc150.com', '150!2026*fc'), isTrue);
    expect(app.isAdmin, isTrue);

    // Second admin account works too; e-mail match is case-insensitive.
    final app2 = AppState();
    expect(app2.tryAdminLogin('ADMIN2@FC150.COM', '150!2026*fc'), isTrue);

    app.logoutAdmin();
    expect(app.isAdmin, isFalse);
  });

  test('broadcast is pending until marked seen', () {
    final app = AppState();
    expect(app.pendingBroadcast, isNull);

    app.pushBroadcast('Season 3 starts Friday!');
    expect(app.pendingBroadcast, 'Season 3 starts Friday!');

    app.markBroadcastSeen();
    expect(app.pendingBroadcast, isNull);
  });

  test('a fresh player starts clean — no invites, challenges or history', () {
    final app = AppState();
    expect(app.invites, isEmpty);
    expect(app.activeChallenges, isEmpty);
    expect(app.matchHistory, isEmpty);
    expect(Seed.league, isEmpty);
    expect(Seed.fixtures, isEmpty);
  });

  test('submitting a result moves a challenge from active to history', () {
    final app = AppState();
    app.addChallenge('p06', '1v1', 'Today · 20:30');
    expect(app.activeChallenges.length, 1);
    expect(app.matchHistory, isEmpty);

    app.submitResult('p06', 3, 1);
    expect(app.activeChallenges, isEmpty);
    expect(app.matchHistory.length, 1);
    expect(app.matchHistory.first['sa'], 3);
  });

  test('the roster supports Premier League, Champions League and World Cup', () {
    expect(AppState.rosterCaps.keys.toSet(), {'pl', 'ucl', 'wc'});
  });

  test('friendly record tracks played / won / drawn / lost', () {
    final app = AppState();
    expect(app.friendlyPlayed, 0);
    app.recordFriendlyResult('win');
    app.recordFriendlyResult('win');
    app.recordFriendlyResult('draw');
    app.recordFriendlyResult('loss');
    expect(app.friendlyPlayed, 4);
    expect(app.friendlyWon, 2);
    expect(app.friendlyDrawn, 1);
    expect(app.friendlyLost, 1);
  });

  test('Champions League has four groups like the World Cup', () {
    expect(Comps.championsLeague.groups.length, 4);
    expect(Comps.worldCup.groups.length, 4);
    // 4 groups of 4 = 16 teams.
    final teams = Comps.championsLeague.groups.fold<int>(0, (n, g) => n + g.rows.length);
    expect(teams, 16);
  });
}
