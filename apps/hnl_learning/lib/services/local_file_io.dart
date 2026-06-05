// Mobile/desktop implementation (selected by conditional import when dart:io
// is available). Used to check that a recording still exists before playing,
// so a missing clip falls back to TTS instead of an iOS playback error.
import 'dart:io';

bool localFileExists(String path) => File(path).existsSync();

/// Copy a picked/uploaded audio file into the app's Documents dir so it
/// persists (the picker hands us a temp copy that the OS may purge).
Future<void> copyLocalFile(String src, String dest) async {
  await File(src).copy(dest);
}
