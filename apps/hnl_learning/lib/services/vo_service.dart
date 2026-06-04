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

  String? activeId;
  bool _enabled = true;

  bool get enabled => _enabled;
  bool isActive(String id) => activeId == id;
  bool has(String id) => _recordings.containsKey(id);
  int get recordedCount => _recordings.length;

  Future<void> init() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.46); // friendly, unhurried
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
  Future<void> play(String id, String? text) async {
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
        await _tts.speak(text);
        return;
      } catch (_) {}
    }
    // Nothing available — flash the speaking state briefly.
    await Future.delayed(const Duration(milliseconds: 1400));
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
