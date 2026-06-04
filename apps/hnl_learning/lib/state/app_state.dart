// ============================================================
// HNL Learning — App state, routing & persistence
// Mirrors js/app.jsx: a single-screen state machine whose
// profile/progress/tweaks persist locally (shared_preferences,
// in place of the prototype's localStorage "hnl-save-v1").
// ============================================================
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/animals.dart';
import '../models/content.dart';
import '../theme/tokens.dart';
import '../services/vo_service.dart';

const _saveKey = 'hnl-save-v1';

class Session {
  final List<String> queue;
  final int index;
  final String mode; // 'single' | 'mission'
  final int started; // epoch ms
  const Session(this.queue, this.index, this.mode, this.started);

  Session copyWith({int? index}) =>
      Session(queue, index ?? this.index, mode, started);
}

/// One child's profile + their own progress. The app supports many children
/// (switch between them from the home profile chip).
class Child {
  int? age;
  List<String> topics;
  String? avatar; // avatar id
  String? photo; // base64-encoded photo
  String? skin; // this child's chosen Look (theme/skins.dart); null = app default
  int stars;
  List<String> planets;
  int streak;
  int timeToday;
  Map<String, int> skillXp;

  /// Per-continent animal ids the child has already been quizzed on, so each
  /// visit serves fresh animals (reshuffles when a continent is exhausted).
  Map<String, List<String>> animalsSeen;

  Child({
    this.age,
    List<String>? topics,
    this.avatar,
    this.photo,
    this.skin,
    this.stars = 0,
    List<String>? planets,
    this.streak = 1,
    this.timeToday = 0,
    Map<String, int>? skillXp,
    Map<String, List<String>>? animalsSeen,
  })  : topics = topics ?? [],
        planets = planets ?? [],
        skillXp = skillXp ?? {},
        animalsSeen = animalsSeen ?? {};

  bool get isSetUp => age != null;

  Uint8List? get photoBytes {
    if (photo == null) return null;
    try {
      return base64Decode(photo!);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'topics': topics,
        'avatar': avatar,
        'photo': photo,
        'skin': skin,
        'stars': stars,
        'planets': planets,
        'streak': streak,
        'timeToday': timeToday,
        'skillXp': skillXp,
        'animalsSeen': animalsSeen,
      };

  factory Child.fromJson(Map<String, dynamic> d) => Child(
        age: d['age'] as int?,
        topics: (d['topics'] as List?)?.cast<String>(),
        avatar: d['avatar'] as String?,
        photo: d['photo'] as String?,
        skin: d['skin'] as String?,
        stars: d['stars'] as int? ?? 0,
        planets: (d['planets'] as List?)?.cast<String>(),
        streak: d['streak'] as int? ?? 1,
        timeToday: d['timeToday'] as int? ?? 0,
        skillXp: (d['skillXp'] as Map?)?.map((k, v) => MapEntry(k as String, v as int)),
        animalsSeen: (d['animalsSeen'] as Map?)
            ?.map((k, v) => MapEntry(k as String, (v as List).cast<String>())),
      );
}

class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    _load();
    _applyActiveChildSkin(); // show the active child's saved Look on boot
  }

  final SharedPreferences _prefs;

  /// Wired up after construction so navigation can stop the voiceover.
  VoService? vo;

  // ---- routing ----
  String screen = 'onb-0';

  // ---- children (profiles + per-child progress) ----
  List<Child> children = [Child()];
  int activeIndex = 0;

  Child get child {
    if (children.isEmpty) children = [Child()];
    if (activeIndex < 0 || activeIndex >= children.length) activeIndex = 0;
    return children[activeIndex];
  }

  // Active-child accessors (the rest of the app reads these unchanged).
  int? get age => child.age;
  List<String> get topics => child.topics;
  set topics(List<String> v) => child.topics = v; // used by tests/setup
  String? get avatar => child.avatar;
  String? get photo => child.photo;
  Uint8List? get photoBytes => child.photoBytes;
  int get stars => child.stars;
  List<String> get planets => child.planets;
  int get streak => child.streak;
  int get timeToday => child.timeToday;
  Map<String, int> get skillXp => child.skillXp;

  // ---- tweaks ----
  // [skin] mirrors the *active child's* Look (drives the Tweaks highlight +
  // the global activeSkin). Each child remembers its own Look in `Child.skin`;
  // [_baseSkin] is the fallback for a child who hasn't picked one yet.
  String skin = kDefaultSkin; // the active "Look" (see skins.dart)
  String _baseSkin = kDefaultSkin; // default Look for children without their own
  String palette = 'meadow'; // legacy; kept for save compatibility
  String font = 'baloo'; // legacy; kept for save compatibility
  bool mascot = true;
  String celebration = 'big'; // 'big' | 'gentle'
  int sessionLen = 15;
  bool sound = true;

  // ---- session (transient) ----
  Session? session;

  // ---- transient overlay UI (Studios + Tweaks panel) ----
  bool showVoice = false;
  bool showPictures = false;
  bool showGif = false;
  bool showTweaks = false;
  bool showChildMenu = false; // profile-chip dropdown to switch children

  // Child-lock gate guarding the settings/Tweaks panel.
  bool showGate = false;
  VoidCallback? gateAction;

  // ------------------------------------------------------------
  // Children: switch / add / remove
  // ------------------------------------------------------------
  void openChildMenu() {
    showChildMenu = true;
    notifyListeners();
  }

  void closeChildMenu() {
    showChildMenu = false;
    notifyListeners();
  }

  void setActiveChild(int i) {
    if (i < 0 || i >= children.length) return;
    activeIndex = i;
    showChildMenu = false;
    session = null;
    _applyActiveChildSkin(); // load this child's saved Look
    // Resume setup if this child isn't finished, else go to their home.
    go(child.isSetUp ? 'home' : 'age');
  }

  /// Begin onboarding a new child: append a fresh profile, make it active,
  /// and jump into the child-setup flow.
  void addChild() {
    children.add(Child());
    activeIndex = children.length - 1;
    showChildMenu = false;
    session = null;
    _applyActiveChildSkin(); // a fresh child starts on the default Look
    go('age');
  }

  void removeChild(int i) {
    if (children.length <= 1 || i < 0 || i >= children.length) return;
    children.removeAt(i);
    if (activeIndex >= children.length) activeIndex = children.length - 1;
    _applyActiveChildSkin(); // the now-active child may use a different Look
    _changed();
  }

  /// Show the 1-2-3-4 child-lock; run [onUnlock] only when it's passed.
  void requireParent(VoidCallback onUnlock) {
    gateAction = onUnlock;
    showGate = true;
    notifyListeners();
  }

  void closeGate() {
    showGate = false;
    gateAction = null;
    notifyListeners();
  }

  void openVoiceStudio() {
    showVoice = true;
    notifyListeners();
  }

  void closeVoiceStudio() {
    showVoice = false;
    notifyListeners();
  }

  void openPictureStudio() {
    showPictures = true;
    notifyListeners();
  }

  void closePictureStudio() {
    showPictures = false;
    notifyListeners();
  }

  void openGifStudio() {
    showGif = true;
    notifyListeners();
  }

  void closeGifStudio() {
    showGif = false;
    notifyListeners();
  }

  void toggleTweaks() {
    showTweaks = !showTweaks;
    notifyListeners();
  }

  void openTweaks() {
    showTweaks = true;
    notifyListeners();
  }

  /// The active look's accent palette (the rest of the app reads `app.pal`).
  Palette get pal => activeSkin.palette;

  /// Switch the active child's Look. Saved onto *that child* so switching
  /// profiles restores each kid's own Look. Swaps the global [activeSkin],
  /// persists, and rebuilds every screen (tokens read the active skin).
  void setSkin(String id) {
    child.skin = id;
    skin = id;
    setActiveSkin(id);
    _changed();
  }

  /// Apply the active child's saved Look (or the default if they have none).
  void _applyActiveChildSkin() {
    final id = child.skin ?? _baseSkin;
    skin = id;
    setActiveSkin(id);
  }

  // ------------------------------------------------------------
  // Persistence
  // ------------------------------------------------------------
  void _load() {
    final raw = _prefs.getString(_saveKey);
    if (raw == null) return;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;

      if (d['children'] is List) {
        // New multi-child format.
        children = [for (final c in (d['children'] as List)) Child.fromJson(c as Map<String, dynamic>)];
        if (children.isEmpty) children = [Child()];
        activeIndex = (d['activeIndex'] as int?)?.clamp(0, children.length - 1) ?? 0;
      } else {
        // Migrate the old single-profile save into one child.
        final p = (d['profile'] as Map?) ?? {};
        children = [
          Child(
            age: p['age'] as int?,
            topics: (p['topics'] as List?)?.cast<String>(),
            avatar: p['avatar'] as String?,
            photo: p['photo'] as String?,
            stars: d['stars'] as int? ?? 0,
            planets: (d['planets'] as List?)?.cast<String>(),
            streak: d['streak'] as int? ?? 1,
            timeToday: d['timeToday'] as int? ?? 0,
            skillXp: (d['skillXp'] as Map?)?.map((k, v) => MapEntry(k as String, v as int)),
          )
        ];
        activeIndex = 0;
      }

      final t = (d['tweaks'] as Map?) ?? {};
      // The saved Look is the *default* for children without their own. Each
      // child's chosen Look rides in their own profile (Child.skin); the active
      // one is applied after _load by _applyActiveChildSkin().
      _baseSkin = t['skin'] as String? ?? kDefaultSkin;
      skin = _baseSkin;
      palette = t['palette'] as String? ?? 'meadow';
      font = t['font'] as String? ?? 'baloo';
      mascot = t['mascot'] as bool? ?? true;
      celebration = t['celebration'] as String? ?? 'big';
      sessionLen = t['sessionLen'] as int? ?? 15;
      sound = t['sound'] as bool? ?? true;

      // On a cold start we always come up through the splash and land on a
      // calm screen — never resume mid-activity (a game, the island/continent
      // map, a quiz, a break/reward, or the parent gate).
      final s = d['screen'] as String?;
      const kTransientScreens = {
        'game', 'continents', 'animal-quiz', 'break', 'rewards', 'gate',
      };
      if (s != null && !s.startsWith('game') && !kTransientScreens.contains(s)) {
        screen = s;
      } else {
        screen = child.isSetUp ? 'home' : 'onb-0';
      }
    } catch (_) {/* corrupt save — start fresh */}
  }

  void _save() {
    final data = {
      'children': [for (final c in children) c.toJson()],
      'activeIndex': activeIndex,
      'tweaks': {
        'skin': _baseSkin, // default Look; each child's own Look rides in their profile
        'palette': palette,
        'font': font,
        'mascot': mascot,
        'celebration': celebration,
        'sessionLen': sessionLen,
        'sound': sound,
      },
      'screen': screen,
    };
    _prefs.setString(_saveKey, jsonEncode(data));
  }

  void _changed() {
    _save();
    notifyListeners();
  }

  // ------------------------------------------------------------
  // Navigation
  // ------------------------------------------------------------
  void go(String s) {
    vo?.stop();
    screen = s;
    _changed();
  }

  // ------------------------------------------------------------
  // Profile mutations
  // ------------------------------------------------------------
  void setAge(int a) {
    child.age = a;
    _changed();
  }

  void toggleTopic(String id) {
    final t = child.topics;
    child.topics = t.contains(id) ? (List.of(t)..remove(id)) : (List.of(t)..add(id));
    _changed();
  }

  void setAvatar(String id) {
    child.avatar = id;
    child.photo = null;
    _changed();
  }

  void setPhoto(String base64) {
    child.photo = base64;
    child.avatar = null;
    _changed();
  }

  // ------------------------------------------------------------
  // Tweaks
  // ------------------------------------------------------------
  void setTweak(void Function() apply) {
    apply();
    vo?.setEnabled(sound);
    _changed();
  }

  // ------------------------------------------------------------
  // Session / mission
  // ------------------------------------------------------------
  List<String> missionGames() {
    final eligible = kGames.where((g) => g.mission).toList();
    var pool = eligible.where((g) => topics.contains(g.topic)).toList();
    if (pool.length < 3) {
      pool = [...pool, ...eligible.where((g) => !pool.contains(g))];
    }
    final seen = <String>{};
    final out = <String>[];
    for (final g in pool) {
      if (seen.add(g.id)) out.add(g.id);
      if (out.length >= 4) break;
    }
    return out;
  }

  void startGame(String id) {
    session = Session([id], 0, 'single', DateTime.now().millisecondsSinceEpoch);
    go('game');
  }

  // ------------------------------------------------------------
  // Animals island — continent → a shuffled 20-animal quiz session
  // ------------------------------------------------------------
  static const int kAnimalsPerSession = 20;

  Continent? currentContinent;
  List<Animal> animalQueue = [];
  int animalIndex = 0;

  Animal? get currentAnimal =>
      (animalIndex >= 0 && animalIndex < animalQueue.length) ? animalQueue[animalIndex] : null;

  /// Open the continent map.
  void openContinents() => go('continents');

  /// Build a fresh quiz for [continentId]: up to 20 animals the child hasn't
  /// seen yet; once a continent is exhausted the "seen" set resets (reshuffle).
  void startContinent(String continentId) {
    final c = continentById(continentId);
    final seen = child.animalsSeen[continentId] ?? <String>[];
    var remaining = c.pool.where((a) => !seen.contains(a.id)).toList();
    if (remaining.length < kAnimalsPerSession && remaining.length < c.pool.length) {
      // Not enough fresh ones left → reshuffle the whole pool.
      child.animalsSeen[continentId] = [];
      remaining = List.of(c.pool);
    }
    remaining.shuffle();
    final take = remaining.take(kAnimalsPerSession).toList();
    child.animalsSeen[continentId] = [
      ...(child.animalsSeen[continentId] ?? []),
      ...take.map((a) => a.id),
    ];

    currentContinent = c;
    animalQueue = take;
    animalIndex = 0;
    _save();
    go('animal-quiz');
  }

  /// Advance to the next animal; returns false when the session is finished.
  bool nextAnimal() {
    if (animalIndex < animalQueue.length - 1) {
      animalIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }

  void startMission() {
    session = Session(missionGames(), 0, 'mission', DateTime.now().millisecondsSinceEpoch);
    go('game');
  }

  void award({String? planetId, int gainStars = 0, String? topic}) {
    final c = child;
    if (gainStars != 0) c.stars += gainStars;
    if (planetId != null && !c.planets.contains(planetId)) c.planets.add(planetId);
    if (topic != null) c.skillXp[topic] = (c.skillXp[topic] ?? 0) + 1;
    _changed();
  }

  /// Advance to the next game in the queue, or end the session.
  void finishGame([int mins = 1]) {
    child.timeToday += mins;
    final s = session;
    if (s == null) {
      go('home');
      return;
    }
    if (s.index + 1 < s.queue.length) {
      session = s.copyWith(index: s.index + 1);
      _changed();
    } else {
      session = null;
      go(s.mode == 'mission' ? 'break' : 'rewards');
    }
  }

  void resetAll() {
    children = [Child()];
    activeIndex = 0;
    session = null;
    go('onb-0');
  }
}

// ------------------------------------------------------------
// FX controller — confetti / stars / score bursts.
// Kept separate so firing celebrations doesn't rebuild screens.
// ------------------------------------------------------------
class CelebrateEvent {
  final int id;
  final int? score;
  final String intensity; // 'big' | 'gentle'
  const CelebrateEvent(this.id, this.score, this.intensity);
}

class FxController extends ChangeNotifier {
  int _seq = 0;
  final List<CelebrateEvent> bursts = [];

  void fire({int? score, String intensity = 'big'}) {
    final e = CelebrateEvent(++_seq, score, intensity);
    bursts.add(e);
    _notifySafe();
    Future.delayed(const Duration(milliseconds: 2600), () {
      bursts.removeWhere((b) => b.id == e.id);
      _notifySafe();
    });
  }

  /// Notify listeners without crashing when fire() is called from a
  /// widget's build/initState (e.g. a screen that celebrates on entry).
  void _notifySafe() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }
}
