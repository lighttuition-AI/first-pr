// Thin wrapper over Firebase Analytics. Every call is fire-and-forget and can
// never throw — analytics must never affect the child's experience (and it
// no-ops gracefully if Firebase failed to initialise / is offline).
import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static void _log(String name, [Map<String, Object>? params]) {
    try {
      FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
    } catch (_) {/* swallow — never break the app for a metric */}
  }

  /// A child opened a world/island (e.g. 'arabic', 'animals').
  static void worldOpen(String worldId) => _log('world_open', {'world_id': worldId});

  /// A game started (e.g. 'arabic-flip', 'memory-match').
  static void gameStart(String gameId) => _log('game_start', {'game_id': gameId});

  /// A grown-up saved their own recording for a voice line.
  static void recordingSaved(String voId) => _log('recording_saved', {'vo_id': voId});
}
