// Unit + widget tests for the content model, core app-state logic, and
// the Arabic alphabet board.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hnl_learning/models/animals.dart';
import 'package:hnl_learning/models/content.dart';
import 'package:hnl_learning/screens/animal_quiz.dart';
import 'package:hnl_learning/screens/game.dart';
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
import 'package:hnl_learning/widgets/village.dart';

void main() {
  test('all 10 games present (7 mini-games + 3 Arabic-world games)', () {
    expect(kGames.length, 10);
    expect(kGames.map((g) => g.type).toSet().length, 10);
    // The Arabic-world games are explore-only (never join a mission).
    expect(kGames.firstWhere((g) => g.type == GameType.alphabet).mission, isFalse);
    expect(kGames.firstWhere((g) => g.type == GameType.trace).mission, isFalse);
    expect(kGames.firstWhere((g) => g.type == GameType.arabicOrder).mission, isFalse);
    // All three Arabic games live in the Arabic world.
    expect(gamesInWorld('arabic').length, 3);
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

  test('voiceover registry: 16 groups, every line id unique', () {
    final groups = buildVoRegistry();
    expect(groups.length, 16); // one VO group per game + the Splash screen group
    // 45 original + Splash (1 background music + 3 names) + Arabic group
    // (1 instruction + 28 letters) + trace instruction + letter-order instruction.
    final total = groups.fold<int>(0, (sum, g) => sum + g.lines.length);
    expect(total, 45 + 1 + 3 + 1 + kArabicLetters.length + 1 + 1);
    final ids = groups.expand((g) => g.lines.map((l) => l.id)).toList();
    expect(ids.toSet().length, ids.length);
    // the splash names are recordable
    expect(groups.any((g) => g.group == 'Splash screen'), isTrue);
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

  test('Animals: the island world exists with a giraffe icon', () {
    final animals = kWorlds.firstWhere((w) => w.id == 'animals');
    expect(animals.emoji, '🦒');
    expect(kWorlds.length, 5);
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
}
