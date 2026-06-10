// Roster (squad-builder) tests — the admin draft logic: a shared approved pool,
// per-competition placement, and the 38-player Premier League cap. The pool is
// empty at launch, so these inject a small test pool.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fc150/data/backend.dart';
import 'package:fc150/data/seed_data.dart';
import 'package:fc150/models/models.dart';
import 'package:fc150/screens/roster_screen.dart';
import 'package:fc150/state/app_state.dart';
import 'package:fc150/theme/app_theme.dart';

Player _p(int i) => Player(
      id: 't$i', name: 'TEST $i', short: 'Test $i', country: 'NL', pos: 'ATT', psn: 'T$i',
      rating: 90 - i, stats: const Stats(pac: 80, sho: 80, pas: 80, dri: 80, def: 80, phy: 80),
    );

Widget _host() => ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(theme: buildFcTheme(), home: const Scaffold(body: SingleChildScrollView(child: RosterScreen()))),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Backend.rosters.clear();
    Backend.latestBroadcast = null;
    Seed.players = [for (var i = 0; i < 3; i++) _p(i)]; // small test pool
  });

  test('a new competition starts empty and the league caps at 38', () {
    final app = AppState();
    expect(app.rosterFor('pl'), isEmpty);
    expect(app.rosterFor('wc'), isEmpty);

    // Fill the Premier League to its 38 cap with synthetic ids.
    for (var i = 0; i < 40; i++) {
      app.toggleRoster('pl', 'x$i');
    }
    expect(app.rosterFor('pl').length, 38);
    expect(app.isFull('pl'), isTrue);
    expect(app.toggleRoster('pl', 'x999'), isFalse); // refused when full
  });

  testWidgets('Roster screen renders the switcher, capacity meter and pool', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('Roster'), findsOneWidget);
    expect(find.text('Premier League'), findsWidgets);
    expect(find.text('World Cup'), findsOneWidget);
    expect(find.textContaining('/ 38 placed'), findsOneWidget);
    expect(find.text('${Seed.players.length} approved'), findsOneWidget); // 3 approved
  });

  testWidgets('tapping Add places a player and bumps the count', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget); // capacity meter starts at 0
    final add = find.text('Add').first;
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // drain the toast timer
  });
}
