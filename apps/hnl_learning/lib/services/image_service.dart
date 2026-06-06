// ============================================================
// HNL Learning — Image system (ported from js/img.jsx)
// • Every picture in the app is an editable "image slot".
// • Slots are keyed so ONE upload applies everywhere that image
//   appears (replace 🍎 once → every apple updates).
// • Uploads come from the device gallery and persist locally
//   (stored as bytes, so it works on mobile AND web). Nothing
//   ever looks broken: uploaded image if present, else the
//   original emoji / vector character.
// ============================================================
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/content.dart';

const _imgStoreKey = 'hnl-img-store';

String imgTokenId(String token) => 'img-tok-$token';

class ImageService extends ChangeNotifier {
  ImageService(this._prefs);

  final SharedPreferences _prefs;
  final ImagePicker _picker = ImagePicker();

  /// slot id -> decoded image bytes
  final Map<String, Uint8List> _images = {};

  bool has(String id) => _images.containsKey(id);
  Uint8List? bytesFor(String id) => _images[id];
  int get count => _images.length;

  Future<void> init() async {
    final raw = _prefs.getString(_imgStoreKey);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        m.forEach((k, v) => _images[k] = base64Decode(v as String));
      } catch (_) {}
    }
  }

  /// Open the gallery and assign the picked image to [slotId].
  /// Returns the bytes (also useful for the setup "Add photo" avatar).
  Future<Uint8List?> pickFor(String slotId) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 90,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    _images[slotId] = bytes;
    _persist();
    notifyListeners();
    return bytes;
  }

  /// Pick a gallery image without binding it to a slot (used by the
  /// child-setup "Add photo" avatar, stored on the profile instead).
  Future<Uint8List?> pickRaw() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 90,
    );
    if (file == null) return null;
    return file.readAsBytes();
  }

  void remove(String id) {
    _images.remove(id);
    _persist();
    notifyListeners();
  }

  void _persist() {
    final m = _images.map((k, v) => MapEntry(k, base64Encode(v)));
    _prefs.setString(_imgStoreKey, jsonEncode(m));
  }
}

// ------------------------------------------------------------
// Registry — every editable picture in the app (78 slots, 11 groups)
// ------------------------------------------------------------
enum SlotKind { emoji, avatar, planet }

class ImgSlot {
  final String id;
  final SlotKind kind;
  final Object data; // emoji String | AvatarData | PlanetData
  final String where;
  const ImgSlot(this.id, this.kind, this.data, this.where);
}

class ImgGroup {
  final String group;
  final List<ImgSlot> items;
  const ImgGroup(this.group, this.items);
}

List<String> _gameTokens(Game g) {
  final out = <String>[];
  for (final r in g.rounds) {
    switch (g.type) {
      case GameType.pick:
        out.addAll(r.options.map((o) => o.emoji));
      case GameType.count:
        out..add(r.item)..add(r.basket);
      case GameType.pattern:
        out.addAll(r.sequence.where((s) => s != '?'));
        out.addAll(r.choices);
      case GameType.memory:
        out.addAll(r.deck);
      case GameType.letter:
        out.add(r.letter);
        out.addAll(r.options.map((o) => o.emoji));
      case GameType.sort:
        out.addAll(r.groups.map((gr) => gr.emoji));
        out.addAll(r.items.map((i) => i.emoji));
      case GameType.science:
        out.add(r.factEmoji ?? '');
        out.addAll(r.options.map((o) => o.emoji));
      case GameType.alphabet:
      case GameType.trace:
      case GameType.arabicOrder:
      case GameType.arabicFlip:
      case GameType.arabicSounds:
      case GameType.produceQuiz:
        break; // Arabic glyphs + produce items aren't game-round image slots.
    }
  }
  return out;
}

List<ImgGroup> buildImgRegistry() {
  final groups = <ImgGroup>[];

  List<ImgSlot> dedup(Iterable<ImgSlot> items) {
    final seen = <String>{};
    final out = <ImgSlot>[];
    for (final it in items) {
      if (seen.add(it.id)) out.add(it);
    }
    return out;
  }

  groups.add(ImgGroup('App icons', dedup([
    for (final t in kTopics) ImgSlot(imgTokenId(t.emoji), SlotKind.emoji, t.emoji, t.label),
    for (final w in kWorlds) ImgSlot(imgTokenId(w.emoji), SlotKind.emoji, w.emoji, w.name),
  ])));

  groups.add(ImgGroup('Characters', [
    for (final a in kAvatars) ImgSlot('img-avatar-${a.id}', SlotKind.avatar, a, 'Character'),
  ]));

  groups.add(ImgGroup('Planets', [
    for (final p in kPlanets) ImgSlot('img-planet-${p.id}', SlotKind.planet, p, p.name),
  ]));

  groups.add(ImgGroup('Parent gate', [
    for (final n in [1, 2, 3, 4])
      ImgSlot(imgTokenId('$n'), SlotKind.emoji, '$n', 'Gate number $n'),
  ]));

  for (final g in kGames) {
    final items = dedup([
      for (final tok in _gameTokens(g))
        if (tok.isNotEmpty) ImgSlot(imgTokenId(tok), SlotKind.emoji, tok, g.title),
    ]);
    if (items.isNotEmpty) groups.add(ImgGroup(g.title, items));
  }
  return groups;
}
