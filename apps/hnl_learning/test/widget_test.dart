// Unit + widget tests for the content model, core app-state logic, and
// the Arabic alphabet board.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hnl_learning/models/content.dart';
import 'package:hnl_learning/screens/game.dart';
import 'package:hnl_learning/services/image_service.dart';
import 'package:hnl_learning/services/vo_service.dart';
import 'package:hnl_learning/state/app_state.dart';

void main() {
  test('all 8 games are present (7 mini-games + Arabic alphabet)', () {
    expect(kGames.length, 8);
    expect(kGames.map((g) => g.type).toSet().length, 8);
    // The alphabet board is explore-only (never joins a mission).
    expect(kGames.firstWhere((g) => g.type == GameType.alphabet).mission, isFalse);
  });

  test('voiceover registry: 13 groups, every line id unique', () {
    final groups = buildVoRegistry();
    expect(groups.length, 13);
    // 45 original lines + the Arabic group (1 instruction + 28 letters).
    final total = groups.fold<int>(0, (sum, g) => sum + g.lines.length);
    expect(total, 45 + 1 + kArabicLetters.length);
    final ids = groups.expand((g) => g.lines.map((l) => l.id)).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('Arabic world has 28 recordable letters', () {
    expect(kArabicLetters.length, 28);
    final arabicGroup = buildVoRegistry().firstWhere((g) => g.group == 'Arabic Letters');
    for (final l in kArabicLetters) {
      expect(arabicGroup.lines.any((line) => line.id == l.id), isTrue);
    }
  });

  test('image registry: 11 groups, 79 unique slots (one upload syncs everywhere)', () {
    final groups = buildImgRegistry();
    expect(groups.length, 11);
    // 78 + the new Arabic world icon. Shared emoji appear in multiple game
    // groups but share ONE slot id, so one upload applies everywhere.
    final uniqueIds = groups.expand((g) => g.items.map((s) => s.id)).toSet();
    expect(uniqueIds.length, 79);
  });

  test('planets: 9 total; the 7 reward-bearing games map to unique planets', () {
    expect(kPlanets.length, 9);
    final rewards = kGames.map((g) => g.reward).where((r) => r.isNotEmpty).toList();
    expect(rewards.length, 7);
    expect(rewards.toSet().length, rewards.length);
  });

  test('mission builds a 3–4 game queue from chosen topics', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs)..topics = ['logic', 'counting'];
    final queue = app.missionGames();
    expect(queue.length, inInclusiveRange(3, 4));
    expect(queue.toSet().length, queue.length); // no duplicates
  });

  test('award grants stars, a planet, and skill xp', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    app.award(planetId: 'p1', gainStars: 8, topic: 'logic');
    expect(app.stars, 8);
    expect(app.planets, contains('p1'));
    expect(app.skillXp['logic'], 1);
  });

  testWidgets('Arabic alphabet board renders glyphs with no overflow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppState(prefs)),
          ChangeNotifierProvider.value(value: VoService(prefs)),
          ChangeNotifierProvider.value(value: ImageService(prefs)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 1280, height: 800, child: AlphabetBoard()),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    // First letter (Alif) sits top-right of the RTL grid and is on-screen.
    expect(find.text('أ'), findsOneWidget);
  });
}
