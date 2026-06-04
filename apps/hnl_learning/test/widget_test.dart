// Unit + widget tests for the content model, core app-state logic, and
// the Arabic alphabet board.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hnl_learning/models/content.dart';
import 'package:hnl_learning/screens/game.dart';
import 'package:hnl_learning/screens/tweaks.dart';
import 'package:hnl_learning/services/image_service.dart';
import 'package:hnl_learning/services/vo_service.dart';
import 'package:hnl_learning/state/app_state.dart';
import 'package:hnl_learning/theme/tokens.dart';

void main() {
  test('all 9 games present (7 mini-games + 2 Arabic-world games)', () {
    expect(kGames.length, 9);
    expect(kGames.map((g) => g.type).toSet().length, 9);
    // The Arabic-world games are explore-only (never join a mission).
    expect(kGames.firstWhere((g) => g.type == GameType.alphabet).mission, isFalse);
    expect(kGames.firstWhere((g) => g.type == GameType.trace).mission, isFalse);
  });

  test('voiceover registry: 14 groups, every line id unique', () {
    final groups = buildVoRegistry();
    expect(groups.length, 14);
    // 45 original + Arabic group (1 instruction + 28 letters) + trace instruction.
    final total = groups.fold<int>(0, (sum, g) => sum + g.lines.length);
    expect(total, 45 + 1 + kArabicLetters.length + 1);
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

  test('multiple children have separate, isolated progress', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    expect(app.children.length, 1);

    app.setAge(5);
    app.award(planetId: 'p1', gainStars: 8);
    expect(app.stars, 8);

    app.addChild(); // child 2 becomes active
    expect(app.children.length, 2);
    expect(app.stars, 0); // fresh, isolated progress
    app.award(gainStars: 3);
    expect(app.stars, 3);

    app.setActiveChild(0); // back to child 1
    expect(app.stars, 8);
    expect(app.planets, contains('p1'));

    app.removeChild(1);
    expect(app.children.length, 1);
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

  testWidgets('Letter tracing renders guide + colour palette without overflow', (tester) async {
    // Render at the real stage size the game always gets (1366×1024).
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
            body: Padding(
              padding: EdgeInsets.fromLTRB(40, 140, 40, 40),
              child: TraceGame(),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700)); // let the intro VO timer fire
    expect(tester.takeException(), isNull);
    expect(find.text('Pick a colour'), findsOneWidget);
  });

  test('skins: Sunshine is the default look and setSkin swaps it', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);

    // Fresh install defaults to the polished "Sunshine" look.
    expect(app.skin, 'sunshine');
    expect(activeSkin.id, 'sunshine');
    final sunshinePaper = C.paper;

    // Switching to Classic swaps the global skin and the tokens follow.
    app.setSkin('classic');
    expect(app.skin, 'classic');
    expect(activeSkin.id, 'classic');
    expect(C.paper, isNot(sunshinePaper));
    expect(app.pal, activeSkin.palette); // accents come from the active skin

    // It persists: a new AppState from the same prefs restores the look.
    final reopened = AppState(prefs);
    expect(reopened.skin, 'classic');
    expect(activeSkin.id, 'classic');

    app.setSkin('sunshine'); // restore default for any later tests
  });

  testWidgets('Tweaks → Look picker lists ready looks and switches on tap', (tester) async {
    // Render at the real stage size the panel is designed for (1366×1024).
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: app),
          ChangeNotifierProvider.value(value: VoService(prefs)),
          ChangeNotifierProvider.value(value: ImageService(prefs)),
        ],
        child: const MaterialApp(home: Scaffold(body: TweaksPanel())),
      ),
    );
    await tester.pump();

    // Both ready looks show as picker cards.
    expect(find.text('Sunshine'), findsOneWidget);
    expect(find.text('Classic'), findsOneWidget);

    // Tapping a look switches the whole-app skin.
    await tester.tap(find.text('Classic'));
    await tester.pump();
    expect(app.skin, 'classic');
    expect(activeSkin.id, 'classic');

    app.setSkin('sunshine'); // restore default
  });
}
