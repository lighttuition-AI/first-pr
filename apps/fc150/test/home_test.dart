// Home screen — upcoming matches are grouped by competition (not a single card).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fc150/data/seed_data.dart';
import 'package:fc150/models/models.dart';
import 'package:fc150/screens/home_screen.dart';
import 'package:fc150/state/app_state.dart';
import 'package:fc150/theme/app_theme.dart';
import 'package:fc150/widgets/fc_card.dart';

void main() {
  testWidgets('a fresh player Home is clean — no demo invites or upcoming matches', (tester) async {
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

    // Clean launch: no dummy invitations or matches; only the always-present
    // Quick actions section shows.
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Challenge invitations'), findsNothing);
    expect(find.text('Upcoming matches'), findsNothing);
    expect(find.text('Upcoming match'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('the player card shows the country flag emoji', (tester) async {
    final recordError = FlutterError.onError;
    FlutterError.onError = (d) {
      if (d.exceptionAsString().contains('A RenderFlex overflowed')) return;
      recordError?.call(d);
    };
    addTearDown(() => FlutterError.onError = recordError);

    await tester.pumpWidget(MaterialApp(
      theme: buildFcTheme(),
      home: const Scaffold(
        body: Center(
          child: FCCard(rating: 80, name: 'TEST PLAYER', pos: 'ATT', psn: 'X', country: 'NL', stats: Stats(pac: 78, sho: 81, pas: 64, dri: 76, def: 34, phy: 68)),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text(Seed.flagEmoji('NL')!), findsOneWidget); // 🇳🇱 rendered in the flag box
    await tester.pump(const Duration(seconds: 1));
  });
}
