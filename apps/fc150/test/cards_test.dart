// Cards screen — trophies are shown with the date won (so repeated wins of the
// same cup are distinct), and the empty state otherwise.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fc150/data/seed_data.dart';
import 'package:fc150/screens/cards_screen.dart';
import 'package:fc150/state/app_state.dart';
import 'package:fc150/theme/app_theme.dart';

Widget _host() => ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(theme: buildFcTheme(), home: const Scaffold(body: SingleChildScrollView(child: CardsScreen()))),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Seed.me.trophies = const [];
    FlutterError.onError = (d) {
      if (d.exceptionAsString().contains('A RenderFlex overflowed')) return;
      FlutterError.presentError(d);
    };
  });

  testWidgets('no trophies → empty state', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();
    expect(find.text('Trophies'), findsOneWidget);
    expect(find.text('No trophies yet'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('won trophies show the competition and date', (tester) async {
    Seed.me.trophies = [
      {'comp': 'Premier League', 'date': '2026-06-10', 'at': 1},
      {'comp': 'Premier League', 'date': '2026-12-01', 'at': 2}, // same cup, different date
      {'comp': 'World Cup', 'date': '2026-08-15', 'at': 3},
    ];
    await tester.pumpWidget(_host());
    await tester.pump();
    expect(find.text('Premier League champion'), findsNWidgets(2));
    expect(find.text('World Cup champion'), findsOneWidget);
    expect(find.text('Won 2026-06-10'), findsOneWidget);
    expect(find.text('Won 2026-12-01'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
