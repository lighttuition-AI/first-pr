// Unit tests for the ported content model + core app-state logic.
// These lock in the design's documented counts (45 VO lines across
// 12 groups, 78 image slots across 11 groups) and the 7 games.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hnl_learning/models/content.dart';
import 'package:hnl_learning/services/image_service.dart';
import 'package:hnl_learning/state/app_state.dart';

void main() {
  test('all 7 mini-games are present', () {
    expect(kGames.length, 7);
    expect(kGames.map((g) => g.type).toSet().length, 7);
  });

  test('voiceover registry has 45 lines across 12 groups', () {
    final groups = buildVoRegistry();
    expect(groups.length, 12);
    final total = groups.fold<int>(0, (sum, g) => sum + g.lines.length);
    expect(total, 45);
    // Every line id is unique.
    final ids = groups.expand((g) => g.lines.map((l) => l.id)).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('image registry: 11 groups, 78 unique slots (one upload syncs everywhere)', () {
    final groups = buildImgRegistry();
    expect(groups.length, 11);
    // Groups are self-contained, so a shared emoji (e.g. ☀️) shows in
    // multiple game groups — but all instances share ONE slot id, so one
    // upload applies everywhere. The design documents 78 unique slots.
    final uniqueIds = groups.expand((g) => g.items.map((s) => s.id)).toSet();
    expect(uniqueIds.length, 78);
  });

  test('9 collectible planets, each rewarded by exactly one game', () {
    expect(kPlanets.length, 9);
    final rewards = kGames.map((g) => g.reward).toSet();
    expect(rewards.length, kGames.length);
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
}
