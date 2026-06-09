// Home screen — upcoming matches are grouped by competition (not a single card).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fc150/screens/home_screen.dart';
import 'package:fc150/state/app_state.dart';
import 'package:fc150/theme/app_theme.dart';

void main() {
  testWidgets('Upcoming matches are grouped by competition', (tester) async {
    // Google Fonts can't fetch in tests; the wider fallback font reports a few
    // px of layout overflow on the card. Ignore those reports; fail on anything else.
    final recordError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) return;
      recordError?.call(details);
    };
    addTearDown(() => FlutterError.onError = recordError);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        theme: buildFcTheme(),
        home: const Scaffold(body: SingleChildScrollView(padding: EdgeInsets.all(20), child: HomeScreen())),
      ),
    ));
    await tester.pump();

    // Grouped section header + per-competition group labels (Eyebrow uppercases).
    expect(find.text('Upcoming matches'), findsOneWidget);
    expect(find.text('PREMIER LEAGUE'), findsWidgets);
    expect(find.text('CHAMPIONS LEAGUE'), findsWidgets);
    expect(find.text('WORLD CUP'), findsWidgets);
    // The old single VS card title is gone.
    expect(find.text('Upcoming match'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
  });
}
