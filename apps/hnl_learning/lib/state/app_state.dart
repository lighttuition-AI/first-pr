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

class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;

  /// Wired up after construction so navigation can stop the voiceover.
  VoService? vo;

  // ---- routing ----
  String screen = 'onb-0';

  // ---- profile ----
  int? age;
  List<String> topics = [];
  String? avatar;
  String? photo; // base64-encoded photo chosen via image_picker

  /// Decoded profile photo bytes, if a photo was chosen.
  Uint8List? get photoBytes {
    if (photo == null) return null;
    try {
      return base64Decode(photo!);
    } catch (_) {
      return null;
    }
  }

  // ---- progress ----
  int stars = 0;
  List<String> planets = [];
  int streak = 1;
  int timeToday = 0;
  Map<String, int> skillXp = {};

  // ---- tweaks ----
  String palette = 'meadow';
  String font = 'baloo'; // 'baloo' | 'quick'
  bool mascot = true;
  String celebration = 'big'; // 'big' | 'gentle'
  int sessionLen = 15;
  bool sound = true;

  // ---- session (transient) ----
  Session? session;

  // ---- transient overlay UI (Studios + Tweaks panel) ----
  bool showVoice = false;
  bool showPictures = false;
  bool showTweaks = false;

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

  void toggleTweaks() {
    showTweaks = !showTweaks;
    notifyListeners();
  }

  Palette get pal => kPalettes[palette] ?? kPalettes['meadow']!;
  bool get quicksand => font == 'quick';

  // ------------------------------------------------------------
  // Persistence
  // ------------------------------------------------------------
  void _load() {
    final raw = _prefs.getString(_saveKey);
    if (raw == null) return;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;
      final p = (d['profile'] as Map?) ?? {};
      age = p['age'] as int?;
      topics = (p['topics'] as List?)?.cast<String>() ?? [];
      avatar = p['avatar'] as String?;
      photo = p['photo'] as String?;
      stars = d['stars'] as int? ?? 0;
      planets = (d['planets'] as List?)?.cast<String>() ?? [];
      streak = d['streak'] as int? ?? 1;
      timeToday = d['timeToday'] as int? ?? 0;
      skillXp = (d['skillXp'] as Map?)?.map((k, v) => MapEntry(k as String, v as int)) ?? {};
      final t = (d['tweaks'] as Map?) ?? {};
      palette = t['palette'] as String? ?? 'meadow';
      font = t['font'] as String? ?? 'baloo';
      mascot = t['mascot'] as bool? ?? true;
      celebration = t['celebration'] as String? ?? 'big';
      sessionLen = t['sessionLen'] as int? ?? 15;
      sound = t['sound'] as bool? ?? true;
      final s = d['screen'] as String?;
      if (s != null && !s.startsWith('game')) {
        screen = s;
      } else {
        screen = age != null ? 'home' : 'onb-0';
      }
    } catch (_) {/* corrupt save — start fresh */}
  }

  void _save() {
    final data = {
      'profile': {'age': age, 'topics': topics, 'avatar': avatar, 'photo': photo},
      'stars': stars,
      'planets': planets,
      'streak': streak,
      'timeToday': timeToday,
      'skillXp': skillXp,
      'tweaks': {
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
    age = a;
    _changed();
  }

  void toggleTopic(String id) {
    topics = topics.contains(id)
        ? (List.of(topics)..remove(id))
        : (List.of(topics)..add(id));
    _changed();
  }

  void setAvatar(String id) {
    avatar = id;
    photo = null;
    _changed();
  }

  void setPhoto(String path) {
    photo = path;
    avatar = null;
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
    var pool = kGames.where((g) => topics.contains(g.topic)).toList();
    if (pool.length < 3) {
      pool = [...pool, ...kGames.where((g) => !pool.contains(g))];
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

  void startMission() {
    session = Session(missionGames(), 0, 'mission', DateTime.now().millisecondsSinceEpoch);
    go('game');
  }

  void award({String? planetId, int gainStars = 0, String? topic}) {
    if (gainStars != 0) stars += gainStars;
    if (planetId != null && !planets.contains(planetId)) planets.add(planetId);
    if (topic != null) skillXp[topic] = (skillXp[topic] ?? 0) + 1;
    _changed();
  }

  /// Advance to the next game in the queue, or end the session.
  void finishGame([int mins = 1]) {
    timeToday += mins;
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
    age = null;
    topics = [];
    avatar = null;
    photo = null;
    stars = 0;
    planets = [];
    streak = 1;
    timeToday = 0;
    skillXp = {};
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
