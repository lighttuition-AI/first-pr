// Roster (squad-builder) tests — the admin draft logic: a shared approved pool,
// per-competition placement, and the 38-player Premier League cap.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fc150/data/seed_data.dart';
import 'package:fc150/screens/roster_screen.dart';
import 'package:fc150/state/app_state.dart';
import 'package:fc150/theme/app_theme.dart';

Widget _host() => ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(theme: buildFcTheme(), home: const Scaffold(body: SingleChildScrollView(child: RosterScreen()))),
    );

void main() {
  // AppState restores the last tab from SharedPreferences on construction;
  // give the test binding a mock store so that call doesn't leave a timer.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('approved pool is larger than the Premier League can hold', () {
    expect(Seed.roster.length, greaterThan(AppState.rosterCaps['pl']!));
  });

  test('AppState seeds the league with the 12 named players and caps adds at 38', () {
    final app = AppState();
    expect(app.rosterFor('pl').length, 12);
    expect(app.rosterFor('wc'), isEmpty);

    // Fill the Premier League to its 38 cap from the approved pool.
    for (final p in Seed.roster) {
      app.toggleRoster('pl', p.id);
    }
    expect(app.rosterFor('pl').length, 38);
    expect(app.isFull('pl'), isTrue);

    // Any further add is refused (returns false, nothing changes).
    final leftOut = Seed.roster.firstWhere((p) => !app.isPlaced('pl', p.id));
    expect(app.toggleRoster('pl', leftOut.id), isFalse);
    expect(app.rosterFor('pl').length, 38);
  });

  testWidgets('Roster screen renders the switcher, capacity meter and pool', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('Roster'), findsOneWidget);
    expect(find.text('Premier League'), findsWidgets);
    expect(find.text('World Cup'), findsOneWidget);
    // 12 named players are pre-placed in a 38-cap league.
    expect(find.textContaining('/ 38 placed'), findsOneWidget);
    // Approved pool count chip.
    expect(find.text('${Seed.roster.length} approved'), findsOneWidget);
  });

  testWidgets('tapping Add places a player and bumps the count', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('12'), findsOneWidget); // capacity meter count
    final add = find.text('Add').first;
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pump();
    expect(find.text('13'), findsOneWidget);
    // Let the confirmation toast's timer fire so none are pending at teardown.
    await tester.pump(const Duration(seconds: 2));
  });
}
