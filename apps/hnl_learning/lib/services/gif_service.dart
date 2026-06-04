// Celebration GIFs — a grown-up uploads their own clips (e.g. the child
// playing) in the GIF Studio. One is shown, large, when the child finishes
// tracing the whole Arabic alphabet. Stored as bytes so it works on mobile
// and web; Image.memory animates the GIF.
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _gifStoreKey = 'hnl-gif-store';

class GifEntry {
  final String id;
  final Uint8List bytes;
  const GifEntry(this.id, this.bytes);
}

class GifService extends ChangeNotifier {
  GifService(this._prefs);

  final SharedPreferences _prefs;
  final ImagePicker _picker = ImagePicker();
  final List<GifEntry> _gifs = [];
  final Random _rng = Random();

  List<GifEntry> get gifs => List.unmodifiable(_gifs);
  int get count => _gifs.length;
  bool get isEmpty => _gifs.isEmpty;

  Future<void> init() async {
    final raw = _prefs.getString(_gifStoreKey);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        m.forEach((k, v) => _gifs.add(GifEntry(k, base64Decode(v as String))));
      } catch (_) {}
    }
  }

  /// Pick a GIF (or any image) from the gallery. No resize params, so an
  /// animated GIF keeps its animation.
  Future<void> pickAndAdd() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    _gifs.add(GifEntry(DateTime.now().millisecondsSinceEpoch.toString(), bytes));
    _persist();
    notifyListeners();
  }

  void remove(String id) {
    _gifs.removeWhere((g) => g.id == id);
    _persist();
    notifyListeners();
  }

  /// A random uploaded GIF, or null if none have been added yet.
  Uint8List? randomGif() => _gifs.isEmpty ? null : _gifs[_rng.nextInt(_gifs.length)].bytes;

  void _persist() {
    final m = {for (final g in _gifs) g.id: base64Encode(g.bytes)};
    _prefs.setString(_gifStoreKey, jsonEncode(m));
  }
}
