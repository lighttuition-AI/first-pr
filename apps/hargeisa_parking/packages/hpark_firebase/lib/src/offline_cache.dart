import 'package:cloud_firestore/cloud_firestore.dart';

/// Turn on Firestore's on-device cache so the app keeps working with no
/// internet: reads are served from the local cache, and any writes (citations,
/// appeals, …) are queued locally and synced automatically once the connection
/// returns. Call once at startup, right after `Firebase.initializeApp`, before
/// any repository touches Firestore.
///
/// Persistence is on by default on mobile; this makes it explicit and lifts the
/// cache to unlimited so the latest data is always retained offline.
void enableOfflineCache() {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (_) {
    // Settings can only be applied before the first Firestore use — ignore if
    // it has already been initialised.
  }
}
