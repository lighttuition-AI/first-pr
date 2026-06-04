// ============================================================
// HNL Learning — Voiceover engine (ported from js/vo.jsx)
// • Speaker buttons "speak" the on-screen instruction.
// • If a user recording exists for that line id it plays;
//   otherwise the device TTS voice is used as a stand-in.
// • Every line is re-recordable in the Voiceover Studio and
//   persists offline (recording file paths saved locally).
// ============================================================
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _voPathsKey = 'hnl-vo-paths';

class VoService extends ChangeNotifier {
  VoService(this._prefs);

  final SharedPreferences _prefs;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  /// line id -> recorded clip path/url
  final Map<String, String> _recordings = {};

  static const double _defaultRate = 0.46; // friendly, unhurried

  String? activeId;
  bool _enabled = true;

  bool get enabled => _enabled;
  bool isActive(String id) => activeId == id;
  bool has(String id) => _recordings.containsKey(id);
  int get recordedCount => _recordings.length;

  Future<void> init() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(_defaultRate);
      await _tts.setPitch(1.12); // slightly higher = warmer for kids
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(false);
    } catch (_) {/* TTS unavailable on this platform */}
    _tts.setCompletionHandler(() => _clear());
    _tts.setCancelHandler(() => _clear());
    _player.onPlayerComplete.listen((_) => _clear());

    final raw = _prefs.getString(_voPathsKey);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _recordings.addAll(m.map((k, v) => MapEntry(k, v as String)));
      } catch (_) {}
    }
  }

  void _setActive(String? id) {
    activeId = id;
    notifyListeners();
  }

  void _clear() {
    if (activeId != null) _setActive(null);
  }

  void setEnabled(bool v) {
    _enabled = v;
    if (!v) stop();
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    try {
      await _player.stop();
    } catch (_) {}
    _setActive(null);
  }

  /// Play line [id]; prefer the user's recording, else speak [text].
  /// [lang] sets the TTS voice for this utterance (e.g. 'so-SO' for Somali);
  /// if the device lacks that voice the TTS simply no-ops and the recording
  /// (once made in the Studio / inline) is what plays.
  Future<void> play(String id, String? text, {String lang = 'en-US', double? rate}) async {
    await stop();
    if (!_enabled) return;
    _setActive(id);

    final clip = _recordings[id];
    if (clip != null) {
      try {
        await _player.play(_sourceFor(clip));
        return;
      } catch (_) {/* fall through to TTS */}
    }
    if (text != null && text.isNotEmpty) {
      try {
        await _tts.setLanguage(lang);
        // Set rate explicitly every utterance so a custom (slower, stretched)
        // rate never leaks into the next line.
        await _tts.setSpeechRate(rate ?? _defaultRate);
        await _tts.speak(text);
        return;
      } catch (_) {}
    }
    // Nothing available — flash the speaking state briefly.
    await Future.delayed(const Duration(milliseconds: 1400));
    if (activeId == id) _setActive(null);
  }

  /// Like [play], but the returned Future completes only when the audio has
  /// actually *finished* (recording played to the end, or TTS done speaking).
  /// Used by the launch splash so the three names play one fully after another
  /// instead of cutting each other off. Falls back gracefully if audio fails.
  Future<void> playToCompletion(String id, String? text,
      {String lang = 'en-US', double? rate}) async {
    await stop();
    if (!_enabled) return;
    _setActive(id);

    final clip = _recordings[id];
    if (clip != null) {
      try {
        // Listen for completion *before* starting so we can't miss the event.
        final done = _player.onPlayerComplete.first;
        await _player.play(_sourceFor(clip));
        await done.timeout(const Duration(seconds: 8), onTimeout: () {});
        return;
      } catch (_) {/* fall through to TTS */}
    }
    if (text != null && text.isNotEmpty) {
      try {
        await _tts.setLanguage(lang);
        await _tts.setSpeechRate(rate ?? _defaultRate);
        await _tts.awaitSpeakCompletion(true); // make speak() resolve on completion
        await _tts.speak(text);
        return;
      } catch (_) {
      } finally {
        // Restore the default fire-and-forget behaviour for normal play().
        try {
          await _tts.awaitSpeakCompletion(false);
        } catch (_) {}
      }
    }
    // Nothing to play — a brief beat so the caller's pacing still feels right.
    await Future.delayed(const Duration(milliseconds: 600));
    if (activeId == id) _setActive(null);
  }

  Source _sourceFor(String clip) {
    if (clip.startsWith('http') || clip.startsWith('blob')) {
      return UrlSource(clip);
    }
    return DeviceFileSource(clip);
  }

  // ---- recordings registry (capture happens in the Studio) ----
  void registerRecording(String id, String path) {
    _recordings[id] = path;
    _persistPaths();
    notifyListeners();
  }

  void removeRecording(String id) {
    _recordings.remove(id);
    _persistPaths();
    notifyListeners();
  }

  void _persistPaths() {
    _prefs.setString(_voPathsKey, jsonEncode(_recordings));
  }
}
