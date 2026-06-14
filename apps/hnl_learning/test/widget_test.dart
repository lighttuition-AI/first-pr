// Unit + widget tests for the content model, core app-state logic, and
// the Arabic alphabet board.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hnl_learning/models/animals.dart';
import 'package:hnl_learning/models/content.dart';
import 'package:hnl_learning/models/produce.dart';
import 'package:hnl_learning/models/story.dart';
import 'package:hnl_learning/screens/animal_quiz.dart';
import 'package:hnl_learning/screens/game.dart';
import 'package:hnl_learning/screens/produce_quiz.dart';
import 'package:hnl_learning/screens/tweaks.dart';
import 'package:hnl_learning/screens/voice_studio.dart';
import 'package:hnl_learning/services/gif_service.dart';
import 'package:hnl_learning/services/image_service.dart';
import 'package:hnl_learning/services/vo_service.dart';
import 'package:hnl_learning/state/app_state.dart';
import 'package:hnl_learning/theme/tokens.dart';
import 'package:hnl_learning/widgets/common.dart';
import 'package:hnl_learning/widgets/game_icons.dart';
import 'package:hnl_learning/widgets/scene.dart';
import 'package:hnl_learning/widgets/sea.dart';
import 'package:hnl_learning/widgets/story_art.dart';
import 'package:hnl_learning/widgets/village.dart';

void main() {
  test('all 44 games present (Logic 12 + Galaxy 12 + Discovery 13 + Arabic 5 + produce 2)', () {
    expect(kGames.length, 44);
    // 13 distinct types — Fruits + Veggies share produceQuiz; the 10 themed
    // Flip & Match games all reuse GameType.memory.
    expect(kGames.map((g) => g.type).toSet().length, 13);
    // The 10 themed Flip & Match games live in Discovery World, explore-only.
    expect(gamesInWorld('discovery').where((g) => g.type == GameType.memory).length, 11);
    expect(kGames.where((g) => g.id.startsWith('mem-')).every((g) => !g.mission), isTrue);
    // Logic Lab has 6 "Which one?" (pick) + 6 "Sort it out" (sort); Number
    // Galaxy has 6 "Count & drop" (count) + 6 "Finish the pattern" (pattern).
    expect(gamesInWorld('logic').where((g) => g.type == GameType.pick).length, 6);
    expect(gamesInWorld('logic').where((g) => g.type == GameType.sort).length, 6);
    expect(gamesInWorld('galaxy').where((g) => g.type == GameType.count).length, 6);
    expect(gamesInWorld('galaxy').where((g) => g.type == GameType.pattern).length, 6);
    // The Arabic-world games are explore-only (never join a mission).
    expect(kGames.firstWhere((g) => g.type == GameType.alphabet).mission, isFalse);
    expect(kGames.firstWhere((g) => g.type == GameType.trace).mission, isFalse);
    expect(kGames.firstWhere((g) => g.type == GameType.arabicOrder).mission, isFalse);
    expect(kGames.firstWhere((g) => g.type == GameType.arabicFlip).mission, isFalse);
    expect(kGames.firstWhere((g) => g.type == GameType.arabicSounds).mission, isFalse);
    // All five Arabic games live in the Arabic world.
    expect(gamesInWorld('arabic').length, 5);
    expect(gamesInWorld('produce').length, 2); // Fruits + Veggies
    expect(kGames.firstWhere((g) => g.type == GameType.produceQuiz).mission, isFalse);
  });

  test('every game has a bespoke custom icon (no fallback emoji)', () {
    for (final g in kGames) {
      expect(customGameIcon(g.id), isNotNull, reason: '${g.id} should have a custom icon');
    }
  });

  testWidgets('all custom game icons render with no overflow', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Wrap(
            children: [for (final g in kGames) customGameIcon(g.id, size: 52)!],
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(IconTile), findsNWidgets(kGames.length));
  });

  test('voiceover registry: 54 groups, every line id unique', () {
    final groups = buildVoRegistry();
    expect(groups.length, 54); // 44 games + 5 flow + Story music + 3 stories + rewards
    // 45 original + Splash (1 bg music + 3 names) + alphabet group (1 instruction
    // + 28 letters) + trace + order + sounds instructions + flip group (1
    // instruction + its OWN 28 letters) + 2 produce instructions + 10 Flip &
    // Match instructions + 35 new Logic/Galaxy round instructions (pick 10 +
    // sort 5 + count 10 + pattern 10). (The 84 harakat sounds live in their own
    // Studio section, not the flat registry.)
    final total = groups.fold<int>(0, (sum, g) => sum + g.lines.length);
    // + 1 Story-music line + 34 story-narration lines (Fox&Lion 12, Lion&Mouse
    // 12, Proud Camel 10 — each scene × Somali + English).
    expect(total, 45 + 1 + 3 + 1 + kArabicLetters.length + 1 + 1 + 1 + (1 + kArabicLetters.length) + 2 + 10 + 35 + 1 + 34);
    final ids = groups.expand((g) => g.lines.map((l) => l.id)).toList();
    expect(ids.toSet().length, ids.length);
    // the splash names are recordable
    expect(groups.any((g) => g.group == 'Splash screen'), isTrue);
    // the flip game carries its own 28 letter recordings (distinct ids)
    final flipGroup = groups.firstWhere((g) => g.group == 'Flip the Letters');
    for (final l in kArabicLetters) {
      expect(flipGroup.lines.any((line) => line.id == flipVoId(l)), isTrue);
      expect(flipVoId(l) == l.id, isFalse); // separate from the alphabet board
    }
  });

  test('Arabic world has 28 recordable letters', () {
    expect(kArabicLetters.length, 28);
    final arabicGroup = buildVoRegistry().firstWhere((g) => g.group == 'Arabic Letters');
    for (final l in kArabicLetters) {
      expect(arabicGroup.lines.any((line) => line.id == l.id), isTrue);
    }
  });

  testWidgets('Arabic letter-order game: 28 boxes + 28 shuffled tiles, no overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppState(prefs)),
          ChangeNotifierProvider.value(value: VoService(prefs)),
          ChangeNotifierProvider.value(value: GifService(prefs)),
          ChangeNotifierProvider.value(value: FxController()),
        ],
        child: const MaterialApp(home: Scaffold(body: ArabicOrderGame())),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull); // no overflow
    expect(find.text('Placed 0 / 28'), findsOneWidget);
    // 28 empty target boxes + 28 shuffled draggable letter tiles.
    expect(find.byType(DragTarget<int>), findsNWidgets(kArabicLetters.length));
    expect(find.byType(Draggable<int>), findsNWidgets(kArabicLetters.length));
  });

  test('Arabic harakat: 28 letters × 3 vowels = 84 unique recordable sounds', () {
    expect(kHarakatLetters.length, 28);
    expect(kHarakatForms.length, 84);
    final ids = kHarakatForms.map((f) => f.id).toList();
    expect(ids.toSet().length, 84, reason: 'every vowelled form has a unique id');
    // Sound ids must NOT collide with the alphabet board / flip game ids, so
    // recording a syllable never overwrites a whole-letter recording.
    final letterIds = kArabicLetters.map((l) => l.id).toSet();
    expect(ids.where(letterIds.contains), isEmpty);
    // Each form's id is its letter's id + a vowel suffix, and each glyph carries
    // a diacritic (base consonant + one combining mark = 2+ code units).
    for (final h in kHarakatLetters) {
      expect(h.forms.length, 3);
      for (final f in h.forms) {
        expect(f.id.startsWith('${h.id}-'), isTrue);
        expect(f.glyph.runes.length, greaterThanOrEqualTo(2));
      }
    }
  });

  testWidgets('Flip the Letters: 28 cards render face-down, Alif present, no overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppState(prefs)),
          ChangeNotifierProvider.value(value: VoService(prefs)),
          ChangeNotifierProvider.value(value: GifService(prefs)),
          ChangeNotifierProvider.value(value: FxController()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Padding(padding: EdgeInsets.fromLTRB(40, 140, 40, 40), child: ArabicFlipGame()),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull); // fits the stage, no overflow
    // Every card starts "turned around" → 28 flip-hint icons on the back faces.
    expect(find.byIcon(Icons.cached_rounded), findsNWidgets(kArabicLetters.length));
    expect(find.text('Flipped 0 / 28'), findsOneWidget);
    expect(find.text('أ'), findsOneWidget); // Alif's card
  });

  testWidgets('Letter Sounds: the 84-cell harakat grid renders without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppState(prefs)),
          ChangeNotifierProvider.value(value: VoService(prefs)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Padding(padding: EdgeInsets.fromLTRB(40, 140, 40, 40), child: ArabicSoundsGame()),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull); // 4×7 cards, 3 cells each, all fit
    // Baa's three vowel forms (بَ بِ بُ) each render as their own tappable cell.
    expect(find.text(kHarakatLetters[1].forms[0].glyph), findsOneWidget); // بَ
    expect(find.text(kHarakatLetters[1].forms[1].glyph), findsOneWidget); // بِ
    expect(find.text(kHarakatLetters[1].forms[2].glyph), findsOneWidget); // بُ
  });

  test('image registry: 41 groups, unique slots (one upload syncs everywhere)', () {
    final groups = buildImgRegistry();
    expect(groups.length, 41); // + the 20 new Logic/Galaxy games
    // Shared emoji appear in multiple game groups but share ONE slot id, so one
    // upload applies everywhere.
    final uniqueIds = groups.expand((g) => g.items.map((s) => s.id)).toSet();
    expect(uniqueIds.length, 147); // 121 + 25 game slots + the Story island emoji
  });

  test('planets: 9 total; 17 reward-bearing games span all 9 planets', () {
    expect(kPlanets.length, 9);
    final rewards = kGames.map((g) => g.reward).where((r) => r.isNotEmpty).toList();
    // 7 original mini-games + 10 themed Flip & Match games.
    expect(rewards.length, 17);
    // The 10 Flip & Match games intentionally REUSE the 9 planets (cycling),
    // so rewards are no longer all-unique — but every planet is still used.
    expect(rewards.toSet().length, 9);
    // Every reward names a real planet (no dangling ids).
    for (final r in rewards) {
      expect(kPlanets.any((p) => p.id == r), isTrue, reason: '$r must be a real planet');
    }
  });

  test('Animals: the island world exists with a giraffe icon', () {
    final animals = kWorlds.firstWhere((w) => w.id == 'animals');
    expect(animals.emoji, '🦒');
    expect(kWorlds.length, 7); // + Fruit & Veggies + Story Time
  });

  test('Fruit & Veggies: world, two games, distinct-emoji pools', () {
    final w = kWorlds.firstWhere((w) => w.id == 'produce');
    expect(w.name, 'Fruit & Veggies');
    expect(kFruits.isNotEmpty && kVeggies.isNotEmpty, isTrue);
    // ids are globally unique and every item has an emoji + a Somali name.
    final ids = [...kFruits, ...kVeggies].map((p) => p.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final p in [...kFruits, ...kVeggies]) {
      expect(p.emoji.isNotEmpty && p.so.isNotEmpty, isTrue, reason: p.en);
    }
    // distinct emoji within each category (so a child can tell them apart).
    expect(kFruits.map((p) => p.emoji).toSet().length, kFruits.length);
    expect(kVeggies.map((p) => p.emoji).toSet().length, kVeggies.length);
  });

  test('Fruit & Veggies: startProduce builds a shuffled session (≤20)', () async {
    SharedPreferences.setMockInitialValues({});
    final app = AppState(await SharedPreferences.getInstance());
    app.startProduce('fruit');
    expect(app.currentProduceCat, 'fruit');
    expect(app.produceQueue.isNotEmpty, isTrue);
    expect(app.produceQueue.length <= 20, isTrue);
    expect(app.produceQueue.every((p) => kFruits.contains(p)), isTrue);
  });

  testWidgets('Fruit quiz shows the big picture + English/Somali buttons', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    app.startProduce('fruit');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: app),
          ChangeNotifierProvider.value(value: VoService(prefs)),
          ChangeNotifierProvider.value(value: ImageService(prefs)),
          ChangeNotifierProvider.value(value: FxController()),
        ],
        child: const MaterialApp(home: Scaffold(body: ProduceQuiz(category: 'fruit'))),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull); // no overflow
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Somali'), findsOneWidget);
    expect(find.text(app.currentProduce!.en), findsOneWidget);
  });

  testWidgets('Recording is grown-ups-only: tapping a mic shows the 1-2-3-4 lock', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    app.startProduce('fruit');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: app),
          ChangeNotifierProvider.value(value: VoService(prefs)),
          ChangeNotifierProvider.value(value: ImageService(prefs)),
          ChangeNotifierProvider.value(value: FxController()),
        ],
        child: const MaterialApp(home: Scaffold(body: ProduceQuiz(category: 'fruit'))),
      ),
    );
    await tester.pump();

    // A fresh item has no recording yet, so the mic shows its record icon.
    expect(app.showGate, isFalse);
    await tester.tap(find.byIcon(Icons.mic_rounded).first);
    await tester.pump();

    // Tapping it must raise the grown-up lock, NOT start recording straight away.
    expect(app.showGate, isTrue);
  });

  testWidgets('Flip & Match: a themed 6-pair memory game lays out 12 cards, no overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    // All 10 new games share GameType.memory and live in Discovery World.
    final game = kGames.firstWhere((g) => g.id == 'mem-animals');
    expect(game.type, GameType.memory);
    expect(game.world, 'discovery');
    expect(game.rounds.first.deck.length, 6);
    // Decks hold only distinct glyphs (the match key is the glyph itself).
    expect(game.rounds.first.deck.toSet().length, 6);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppState(prefs)),
          ChangeNotifierProvider.value(value: FxController()),
        ],
        child: MaterialApp(
          home: Scaffold(body: Center(child: MemoryGame(round: game.rounds.first, onSolved: () {}))),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull); // 12 cards fit with no overflow
    // 6 pairs → 12 cards, all face-down showing '?'.
    expect(find.text('?'), findsNWidgets(12));
  });

  test('Animals: 7 continents, non-empty pools, unique animal ids', () {
    expect(kContinents.length, 7);
    final ids = <String>[];
    for (final c in kContinents) {
      expect(c.pool, isNotEmpty, reason: '${c.id} should have animals');
      for (final a in c.pool) {
        expect(a.en, isNotEmpty);
        expect(a.so, isNotEmpty);
        expect(a.emoji, isNotEmpty);
        ids.add(a.id);
      }
    }
    expect(ids.toSet().length, ids.length, reason: 'animal ids must be unique');
  });

  test('Animals: a continent quiz serves a shuffled session and reshuffles', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);

    app.startContinent('africa');
    final africa = continentById('africa');
    final expected = africa.pool.length.clamp(0, AppState.kAnimalsPerSession);
    expect(app.currentContinent?.id, 'africa');
    expect(app.animalQueue.length, expected);
    expect(app.screen, 'animal-quiz');

    // Walk to the end of the session.
    for (var i = 0; i < expected - 1; i++) {
      expect(app.nextAnimal(), isTrue);
    }
    expect(app.nextAnimal(), isFalse); // finished

    // A second visit reshuffles (pool smaller than 2×20 → seen resets).
    app.startContinent('africa');
    expect(app.animalQueue.length, expected);
  });

  test('mission builds a 3–4 game queue from chosen topics', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs)..topics = ['logic', 'counting'];
    final queue = app.missionGames();
    expect(queue.length, inInclusiveRange(3, 4));
    expect(queue.toSet().length, queue.length); // no duplicates
  });

  test('award grants stars and skill xp', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    app.award(gainStars: 8, topic: 'logic');
    expect(app.stars, 8);
    expect(app.skillXp['logic'], 1);
  });

  test('tapping a game plays through up to 5 games of its world, then back to the list', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    final discovery = gamesInWorld('discovery').map((g) => g.id).toList();
    expect(discovery.length, greaterThan(AppState.kMaxRunGames)); // 13 games

    // Tapping the first game queues a run of at most kMaxRunGames, in order.
    app.startGame(discovery.first);
    expect(app.screen, 'game');
    expect(app.session!.mode, 'single');
    expect(app.session!.queue, discovery.take(AppState.kMaxRunGames).toList());

    // Tapping a middle game queues from there onward, still capped to the run.
    app.startGame(discovery[2]);
    expect(app.session!.queue, discovery.sublist(2, 2 + AppState.kMaxRunGames));

    // Finishing a non-last game moves on to the NEXT game in the world.
    app.startGame(discovery.first);
    app.finishGame();
    expect(app.screen, 'game');
    expect(app.session!.index, 1);
    expect(app.session!.queue[app.session!.index], discovery[1]);
  });

  test('finishing the last game in a world drops back into its games list', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    final discovery = gamesInWorld('discovery').map((g) => g.id).toList();

    // Start at the last game so the queue is a single game.
    app.startGame(discovery.last);
    expect(app.session!.queue, [discovery.last]);
    app.finishGame();
    // Back to the home map with that world's games sheet queued to reopen —
    // NOT a jump to any planet/collecting screen.
    expect(app.screen, 'home');
    expect(app.resumeWorld, 'discovery');
    expect(app.session, isNull);
  });

  test('back from a game returns to its world games list (one step back)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    app.startGame('mem-animals');
    app.backToWorld('discovery');
    expect(app.screen, 'home');
    expect(app.resumeWorld, 'discovery');
    expect(app.session, isNull);
  });


  test('multiple children have separate, isolated progress', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    expect(app.children.length, 1);

    app.setAge(5);
    app.award(gainStars: 8);
    expect(app.stars, 8);

    app.addChild(); // child 2 becomes active
    expect(app.children.length, 2);
    expect(app.stars, 0); // fresh, isolated progress
    app.award(gainStars: 3);
    expect(app.stars, 3);

    app.setActiveChild(0); // back to child 1
    expect(app.stars, 8); // child 1's stars are intact and isolated

    app.removeChild(1);
    expect(app.children.length, 1);
  });

  test('each child remembers its own Look across profile switches', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);

    // Child 1 picks Moonlit; that Look applies app-wide.
    app.setAge(5);
    app.setSkin('moonlit');
    expect(app.skin, 'moonlit');
    expect(activeSkin.id, 'moonlit');

    // Child 2 starts on the default, then picks Somali Village.
    app.addChild();
    expect(app.skin, 'sunshine'); // a fresh child falls back to the default Look
    expect(activeSkin.id, 'sunshine');
    app.setSkin('somali');
    expect(activeSkin.id, 'somali');

    // Switching back to child 1 restores *their* Look, not child 2's.
    app.setActiveChild(0);
    expect(app.skin, 'moonlit');
    expect(activeSkin.id, 'moonlit');

    // …and it survives an app relaunch (each Look rides in its own profile).
    final reopened = AppState(prefs);
    expect(reopened.skin, 'moonlit'); // child 0 is active
    expect(reopened.children[0].skin, 'moonlit');
    expect(reopened.children[1].skin, 'somali');

    reopened.setSkin('sunshine'); // restore default for any later tests
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

  test('skins: Jungle look is ready and carries an animated scene', () {
    expect(kReadySkins, contains('jungle'));
    final jungle = kSkins['jungle']!;
    expect(jungle.hasScene, isTrue);
    expect(jungle.sceneBuilder!(), isA<FloatingScene>());
    // Sunshine/Classic stay scene-free (calm).
    expect(kSkins['sunshine']!.hasScene, isFalse);
    expect(kSkins['classic']!.hasScene, isFalse);
  });

  test('skins: Ocean look is ready with a water scene', () {
    expect(kReadySkins, contains('ocean'));
    final ocean = kSkins['ocean']!;
    expect(ocean.hasScene, isTrue);
    expect(ocean.sceneBuilder!(), isA<FloatingScene>());
    expect(ocean.displayFont, 'quicksand'); // distinct type pairing
  });

  test('skins: Crayon Pop look is ready (ink borders + hero scene)', () {
    expect(kReadySkins, contains('crayon'));
    final crayon = kSkins['crayon']!;
    expect(crayon.hasScene, isTrue);
    expect(crayon.cardBorder, isNotNull); // neubrutalist outline
    expect(crayon.sceneBuilder!(), isA<FloatingScene>());
    // The calm/standard looks carry no card border.
    expect(kSkins['sunshine']!.cardBorder, isNull);
    expect(kSkins['ocean']!.cardBorder, isNull);
  });

  test('skins: Moonlit Calm is ready, dark, with a night scene', () {
    expect(kReadySkins, contains('moonlit'));
    final m = kSkins['moonlit']!;
    expect(m.brightness, Brightness.dark);
    expect(m.hasScene, isTrue);
    expect(m.sceneBuilder!(), isA<FloatingScene>());
    // Dark look has a light ink for text + a dark paper surface.
    expect(m.ink.computeLuminance(), greaterThan(0.5));
    expect(m.paper.computeLuminance(), lessThan(0.2));
    // Light looks stay light.
    expect(kSkins['sunshine']!.brightness, Brightness.light);
  });

  test('skins: Somali Village is ready and replaces Classic in the picker', () {
    expect(kReadySkins, contains('somali'));
    expect(kReadySkins, isNot(contains('classic'))); // Classic was turned into it
    final v = kSkins['somali']!;
    expect(v.hasScene, isTrue);
    expect(v.sceneBuilder!(), isA<FloatingScene>());
  });

  testWidgets('Somali Village scene renders 3 sisters + hut + tree', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: kSkins['somali']!.sceneBuilder!())),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.byType(SomaliGirl), findsNWidgets(3));
    expect(find.byType(AqalHut), findsOneWidget);
    expect(find.byType(AcaciaTree), findsOneWidget);
  });

  testWidgets('Ocean scene renders shark family + bubbles without error', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: kSkins['ocean']!.sceneBuilder!())),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(find.byType(Shark), findsNWidgets(5)); // baby + 4 grown-ups
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

    // Ready looks show as picker cards.
    expect(find.text('Sunshine'), findsOneWidget);
    expect(find.text('Somali Village'), findsOneWidget);

    // Tapping a look switches the whole-app skin.
    await tester.tap(find.text('Somali Village'));
    await tester.pump();
    expect(app.skin, 'somali');
    expect(activeSkin.id, 'somali');

    app.setSkin('sunshine'); // restore default
  });

  testWidgets('Pressable gives press-in feedback then springs back', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Pressable(
              onTap: () => taps++,
              // a hit-testable surface (as in the app: islands/cards are filled)
              child: Container(width: 120, height: 120, color: const Color(0xFF3366FF)),
            ),
          ),
        ),
      ),
    );
    double scale() => tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

    expect(scale(), 1.0); // at rest
    final g = await tester.startGesture(tester.getCenter(find.byType(Pressable)));
    await tester.pump(const Duration(milliseconds: 120)); // flush tap-down deadline
    expect(scale(), lessThan(1.0)); // pressed in
    await g.up();
    await tester.pumpAndSettle();
    expect(scale(), 1.0); // sprung back
    expect(taps, 1); // and it fired
  });

  test('every animal has a kid-friendly sound (emoji-mapped, with fallback)', () {
    // mapped sounds
    expect(const Animal('lion-af', 'Lion', 'Libaax', '🦁').sound, contains('Roar'));
    expect(const Animal('cow-x', 'Cow', 'Sac', '🐄').sound, contains('Moo'));
    expect(const Animal('frog-x', 'Frog', 'Rah', '🐸').sound, contains('Ribbit'));
    // unmapped emoji → graceful spoken fallback using the name
    expect(const Animal('zzz', 'Quokka', 'Kuwoka', '🟦').sound, contains('Quokka'));
    // every real animal in every continent resolves to a non-empty sound
    for (final c in kContinents) {
      for (final a in c.pool) {
        expect(a.sound.trim(), isNotEmpty, reason: '${a.en} (${a.emoji}) has no sound');
      }
    }
  });

  testWidgets('Animal quiz shows the big "Hear the sound" button', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final app = AppState(prefs);
    app.startContinent('africa'); // gives currentContinent + an animal

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: app),
          ChangeNotifierProvider.value(value: VoService(prefs)),
          ChangeNotifierProvider.value(value: ImageService(prefs)),
          ChangeNotifierProvider.value(value: FxController()),
        ],
        child: const MaterialApp(home: Scaffold(body: AnimalQuizScreen())),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull); // no overflow
    expect(find.text('Hear the sound'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Somali'), findsOneWidget);
  });

  test('VoLineData defaults to English TTS, Somali lines can override the voice', () {
    const def = VoLineData('x', 'hi', 'where');
    const so = VoLineData('y', 'salaan', 'where', lang: 'so-SO');
    expect(def.lang, 'en-US');
    expect(so.lang, 'so-SO');
  });

  test('Splash music is an overridable Studio line backed by the harp asset', () {
    expect(kSplashMusic.asset, 'audio/harp.wav');
    final splash = buildVoRegistry().firstWhere((g) => g.group == 'Splash screen');
    expect(splash.lines.any((l) => l.id == 'splash-music'), isTrue);
  });

  testWidgets('Voiceover Studio: upload buttons + an Animals section per continent', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppState(prefs)),
          ChangeNotifierProvider.value(value: VoService(prefs)),
        ],
        child: const MaterialApp(home: Scaffold(body: VoiceStudio())),
      ),
    );
    await tester.pumpAndSettle();

    // Every line now offers an Upload alongside Record (the default-open group).
    expect(find.byIcon(Icons.upload_rounded), findsWidgets);
    // The Animals section lists all 7 continents.
    expect(find.text('ANIMALS — SOUNDS & NAMES'), findsOneWidget);
    for (final c in kContinents) {
      expect(find.text(c.name), findsOneWidget, reason: '${c.name} continent tile');
    }
    expect(tester.takeException(), isNull); // no overflow

    // Open Africa → its first animal → the three recordable clips appear.
    final firstAfrica = continentById('africa').pool.first;
    await tester.ensureVisible(find.text('Africa'));
    await tester.tap(find.text('Africa'));
    await tester.pumpAndSettle();
    expect(find.text(firstAfrica.en), findsWidgets);

    await tester.ensureVisible(find.text(firstAfrica.en).first);
    await tester.tap(find.text(firstAfrica.en).first);
    await tester.pumpAndSettle();
    expect(find.text('Animal sound'), findsOneWidget);
    expect(find.text('Somali name'), findsOneWidget);
    expect(find.text('English name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Voiceover Studio keeps all 3 Arabic areas: Letters + Flip + the 84 harakat sounds',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppState(prefs)),
          ChangeNotifierProvider.value(value: VoService(prefs)),
        ],
        child: const MaterialApp(home: Scaffold(body: VoiceStudio())),
      ),
    );
    await tester.pumpAndSettle();

    // None of these replaced another — all three Arabic recording areas coexist.
    expect(find.text('Arabic Letters'), findsOneWidget); // alphabet board (28)
    expect(find.text('Flip the Letters'), findsOneWidget); // flip game's own 28
    expect(find.text('ARABIC — LETTER SOUNDS (HARAKAT)'), findsOneWidget); // 84 sounds
    // The harakat section really renders its 28 consonant tiles (Baa's header).
    expect(find.text('Baa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Story library: Fox & Lion is a complete, valid story', () {
    // Storytelling island exists as the 7th world.
    expect(kWorlds.any((w) => w.id == 'story'), isTrue);
    final fox = storyById('fox-lion');
    expect(fox.ready, isTrue);
    expect(fox.titleSo, 'Dawaco iyo Libaax');
    expect(fox.scenes.length, 6);
    expect(fox.questions.length, 2);
    expect(fox.moralEn.isNotEmpty && fox.moralSo.isNotEmpty, isTrue);
    // Every scene has both-language narration; each question has exactly one
    // correct answer; both languages are present on every option.
    for (final s in fox.scenes) {
      expect(s.narrationEn.isNotEmpty && s.narrationSo.isNotEmpty, isTrue);
    }
    for (final q in fox.questions) {
      expect(q.options.where((o) => o.correct).length, 1);
      expect(q.options.every((o) => o.labelEn.isNotEmpty && o.labelSo.isNotEmpty), isTrue);
    }
    // Narration VO ids are unique + registered in the Voiceover Studio so a
    // grown-up can record real Somali narration.
    final voIds = [
      for (final s in fox.scenes) ...[storyVoId(fox.id, s.id, 'so'), storyVoId(fox.id, s.id, 'en')]
    ];
    expect(voIds.toSet().length, voIds.length);
    final storyGroup = buildVoRegistry().firstWhere((g) => g.group.contains('Dawaco iyo Libaax'));
    expect(storyGroup.lines.length, 12);
    // The recurring-cast folktales are scaffolded as "coming soon".
    expect(kStories.where((s) => !s.ready).length, greaterThanOrEqualTo(5));
  });

  test('Story library: 3 stories are fully built and valid', () {
    final ready = kStories.where((s) => s.ready).toList();
    expect(ready.map((s) => s.id).toSet(), {'fox-lion', 'lion-mouse', 'proud-camel'});
    final voIds = <String>[];
    for (final st in ready) {
      expect(st.scenes.length, greaterThanOrEqualTo(5));
      expect(st.questions.length, greaterThanOrEqualTo(1));
      expect(st.moralEn.isNotEmpty && st.moralSo.isNotEmpty, isTrue);
      for (final s in st.scenes) {
        expect(s.narrationEn.isNotEmpty && s.narrationSo.isNotEmpty, isTrue);
        voIds..add(storyVoId(st.id, s.id, 'so'))..add(storyVoId(st.id, s.id, 'en'));
      }
      for (final q in st.questions) {
        expect(q.options.where((o) => o.correct).length, 1);
      }
    }
    // All narration ids across every story are globally unique.
    expect(voIds.toSet().length, voIds.length);
    // The background-music bed is an uploadable Studio line backed by the harp.
    expect(kStoryMusic.id, 'story-music');
    expect(kStoryMusic.asset, 'audio/harp.wav');
    expect(buildVoRegistry().any((g) => g.lines.any((l) => l.id == 'story-music')), isTrue);
  });

  testWidgets('Story scene art renders the fox + lion with no overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SizedBox(width: 760, height: 460, child: StorySceneArt(art: 'friends'))),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.byType(LibaaxLion), findsOneWidget);
    expect(find.byType(DawacoFox), findsOneWidget);
  });
}
