// Admin auth, broadcast and competition-shape tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fc150/data/competitions.dart';
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

  test('accepting an invite moves it to upcoming friendlies; declining just removes it', () {
    final app = AppState();
    expect(app.invites, isNotEmpty);
    final accept = app.invites.first;
    final decline = app.invites.last;

    app.acceptInvite(accept);
    expect(app.invites.any((i) => i.id == accept.id), isFalse);
    expect(app.acceptedFriendlies.any((i) => i.id == accept.id), isTrue);

    app.declineInvite(decline);
    expect(app.invites.any((i) => i.id == decline.id), isFalse);
    expect(app.acceptedFriendlies.any((i) => i.id == decline.id), isFalse);
  });

  test('the roster supports Premier League, Champions League and World Cup', () {
    expect(AppState.rosterCaps.keys.toSet(), {'pl', 'ucl', 'wc'});
  });

  test('Champions League has four groups like the World Cup', () {
    expect(Comps.championsLeague.groups.length, 4);
    expect(Comps.worldCup.groups.length, 4);
    // 4 groups of 4 = 16 teams.
    final teams = Comps.championsLeague.groups.fold<int>(0, (n, g) => n + g.rows.length);
    expect(teams, 16);
  });
}
