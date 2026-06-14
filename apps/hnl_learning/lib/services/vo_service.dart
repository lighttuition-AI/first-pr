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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics.dart';
import 'local_file.dart' if (dart.library.io) 'local_file_io.dart';

/// Audio file types the upload picker accepts. iOS plays them all; `.ogg` is
/// deliberately excluded because iOS can't decode it.
const List<String> kAudioExtensions = ['m4a', 'mp3', 'wav', 'aac', 'aiff', 'caf', 'm4r'];

/// Outcome of [VoService.importFile] — lets the UI tell "you cancelled" apart
/// from "that didn't work" (e.g. uploads aren't available on this platform).
enum ImportResult { ok, cancelled, failed }

const _voPathsKey = 'hnl-vo-paths';

class VoService extends ChangeNotifier {
  VoService(this._prefs);

  final SharedPreferences _prefs;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  // A separate looping player for the Story Time background music, so it plays
  // softly UNDER the narration instead of fighting it.
  final AudioPlayer _bgm = AudioPlayer();
  bool _storyMusicOn = true;

  /// line id -> recorded clip reference. For local recordings we store only
  /// the *filename* (e.g. `vo_<id>.m4a`), resolved against the current app
  /// Documents dir at play time — absolute sandbox paths go stale whenever the
  /// container changes (reinstall/app update), which made saved clips silently
  /// fail. Web recordings are stored as blob/data URLs verbatim.
  final Map<String, String> _recordings = {};

  /// Current app Documents dir (mobile/desktop), cached at init.
  String? _docsDir;

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
      // iOS: play through the *playback* category so the voice is heard even
      // when the ringer/silent switch is on (kids apps must always be audible),
      // and mix with the splash harp rather than fighting it.
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    } catch (_) {/* TTS unavailable on this platform */}
    _tts.setCompletionHandler(() => _clear());
    _tts.setCancelHandler(() => _clear());
    _player.onPlayerComplete.listen((_) => _clear());

    if (!kIsWeb) {
      try {
        _docsDir = (await getApplicationDocumentsDirectory()).path;
      } catch (_) {/* no docs dir on this platform */}
    }

    _storyMusicOn = _prefs.getBool('story-music-on') ?? true;

    final raw = _prefs.getString(_voPathsKey);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _recordings.addAll(m.map((k, v) => MapEntry(k, v as String)));
      } catch (_) {}
    }

    // Heal legacy saves that stored absolute paths → keep just the filename,
    // so clips resolve against the *current* container instead of a dead one.
    if (!kIsWeb) {
      var changed = false;
      for (final e in _recordings.entries.toList()) {
        final v = e.value;
        if (!_isRemote(v) && v.contains('/')) {
          _recordings[e.key] = v.split('/').last;
          changed = true;
        }
      }
      if (changed) _persistPaths();
    }
  }

  bool _isRemote(String ref) => ref.startsWith('http') || ref.startsWith('blob') || ref.startsWith('data:');

  /// Resolve a stored recording reference to a source we can play right now,
  /// or null if it's a local file that no longer exists (→ caller uses TTS).
  Source? _resolveSource(String ref) {
    if (_isRemote(ref)) return UrlSource(ref);
    if (kIsWeb) return DeviceFileSource(ref);
    final name = ref.contains('/') ? ref.split('/').last : ref;
    final full = _docsDir != null ? '$_docsDir/$name' : ref;
    return localFileExists(full) ? DeviceFileSource(full) : null;
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
  Future<void> play(String id, String? text, {String lang = 'en-US', double? rate, String? asset}) async {
    await stop();
    if (!_enabled) return;
    _setActive(id);

    final clip = _recordings[id];
    if (clip != null) {
      final src = _resolveSource(clip);
      if (src != null) {
        try {
          await _player.play(src);
          return;
        } catch (_) {/* fall through to asset/TTS */}
      }
      // Recording is registered but the file is gone (e.g. reinstalled) — fall
      // back to the bundled default instead of failing silently.
    }
    // A bundled sound default (e.g. the splash music) plays instead of TTS.
    if (asset != null) {
      try {
        await _player.play(AssetSource(asset));
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

  /// Splash helper: start announcing line [id] (the family's recording at its
  /// real length, else TTS) and return how long the splash should let it run —
  /// so each sister's name plays *fully* before the next begins (no cut-off).
  /// Always returns a sane, bounded dwell even if audio is unavailable.
  Future<Duration> beginSplashLine(String id, String? text, {double? rate}) async {
    await stop();
    const fallback = Duration(milliseconds: 1500);
    if (!_enabled) return fallback;
    _setActive(id);

    final clip = _recordings[id];
    final src = clip != null ? _resolveSource(clip) : null;
    if (src != null) {
      final durF = _player.onDurationChanged.first; // subscribe before play
      try {
        await _player.play(src);
        final d = await durF.timeout(const Duration(milliseconds: 700), onTimeout: () => fallback);
        final ms = d.inMilliseconds <= 0 ? fallback.inMilliseconds : d.inMilliseconds;
        return Duration(milliseconds: ms.clamp(900, 5000));
      } catch (_) {/* fall through to TTS */}
    }
    if (text != null && text.isNotEmpty) {
      try {
        await _tts.setLanguage('en-US');
        await _tts.setSpeechRate(rate ?? _defaultRate);
        await _tts.speak(text);
      } catch (_) {}
      return Duration(milliseconds: (900 + text.length * 70).clamp(900, 3200));
    }
    return fallback;
  }

  /// Whether a grown-up has uploaded their own splash music.
  bool get hasSplashMusic => _recordings.containsKey('splash-music');

  /// The looping splash bed: the grown-up's uploaded clip (Studio → Splash ·
  /// background music) if set & resolvable, else the bundled harp. Played by the
  /// splash on its own player, so it never collides with the spoken names.
  Source splashMusicSource() {
    final clip = _recordings['splash-music'];
    if (clip != null) {
      final src = _resolveSource(clip);
      if (src != null) return src;
    }
    return AssetSource('audio/harp.wav');
  }

  // ---- Story Time background music ----
  /// Whether the gentle music bed plays during stories (a grown-up can switch
  /// it off; the choice is remembered).
  bool get storyMusicOn => _storyMusicOn;

  /// Whether a grown-up has uploaded their own story music.
  bool get hasStoryMusic => _recordings.containsKey('story-music');

  /// The looping story bed: the uploaded clip (Studio → Story background music)
  /// if set & resolvable, else the same gentle harp the splash uses.
  Source storyMusicSource() {
    final clip = _recordings['story-music'];
    if (clip != null) {
      final src = _resolveSource(clip);
      if (src != null) return src;
    }
    return AssetSource('audio/harp.wav');
  }

  /// Start the looping story music (no-op if switched off).
  Future<void> startStoryMusic() async {
    if (!_storyMusicOn) return;
    try {
      await _bgm.setReleaseMode(ReleaseMode.loop);
      await _bgm.setVolume(0.24); // soft, well under the narration
      await _bgm.play(storyMusicSource());
    } catch (_) {/* audio unavailable here */}
  }

  Future<void> stopStoryMusic() async {
    try {
      await _bgm.stop();
    } catch (_) {}
  }

  /// Toggle/persist the music bed and start or stop it immediately.
  Future<void> setStoryMusicOn(bool on) async {
    _storyMusicOn = on;
    await _prefs.setBool('story-music-on', on);
    if (on) {
      await startStoryMusic();
    } else {
      await stopStoryMusic();
    }
    notifyListeners();
  }

  // ---- upload an existing audio file as the clip for [id] ----
  /// Let a grown-up pick an audio file — a clip recorded in Voice Memos, or a
  /// sound saved from the web — and use it as the voice/sound for line [id].
  /// The clip plays at its natural length everywhere the line is used.
  ///
  /// Returns one of: `ImportResult.ok` (stored), `ImportResult.cancelled`
  /// (no file chosen), or `ImportResult.failed` (couldn't read/save it).
  Future<ImportResult> importFile(String id) async {
    FilePickerResult? res;
    try {
      res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: kAudioExtensions,
        withData: kIsWeb, // web needs the bytes; mobile copies from the path
      );
    } catch (_) {
      return ImportResult.failed;
    }
    if (res == null || res.files.isEmpty) return ImportResult.cancelled;

    final f = res.files.first;
    final ext = (f.extension ?? 'm4a').toLowerCase();
    try {
      if (kIsWeb) {
        final bytes = f.bytes;
        if (bytes == null) return ImportResult.failed;
        _recordings[id] = 'data:audio/$ext;base64,${base64Encode(bytes)}';
      } else {
        final src = f.path;
        if (src == null || _docsDir == null) return ImportResult.failed;
        final name = 'vo_$id.$ext';
        await copyLocalFile(src, '$_docsDir/$name');
        _recordings[id] = name;
      }
    } catch (_) {
      return ImportResult.failed;
    }
    _persistPaths();
    notifyListeners();
    return ImportResult.ok;
  }

  // ---- recordings registry (capture happens in the Studio) ----
  void registerRecording(String id, String path) {
    // Persist only the filename for local recordings so the clip keeps working
    // after the sandbox container path changes; keep web blob/data URLs as-is.
    _recordings[id] = (kIsWeb || _isRemote(path) || !path.contains('/'))
        ? path
        : path.split('/').last;
    _persistPaths();
    Analytics.recordingSaved(id);
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
