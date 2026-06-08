import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hpark_core/hpark_core.dart';

import 'firebase_auth_service.dart';
import 'firebase_officer_repository.dart';

/// The live backend bundle the apps consume.
class HParkBackend {
  HParkBackend({
    required this.officers,
    required this.auth,
    required this.usingFirebase,
  });

  final OfficerRepository officers;
  final AuthService? auth;

  /// True when backed by Firebase; false when this is the in-memory demo backend.
  final bool usingFirebase;

  /// The in-memory demo backend (no Firebase) — what the apps use today.
  factory HParkBackend.demo() => HParkBackend(
        officers: OfficerRepository.demo(),
        auth: null,
        usingFirebase: false,
      );
}

/// Initializes Firebase with [options] (pass `DefaultFirebaseOptions.currentPlatform`
/// from the app's generated `firebase_options.dart`) and returns the live backend.
///
/// If Firebase isn't configured yet, this falls back to [HParkBackend.demo] so the
/// app still runs — flip to real Firebase simply by completing `flutterfire configure`.
Future<HParkBackend> initBackend({FirebaseOptions? options}) async {
  try {
    await Firebase.initializeApp(options: options);
    return HParkBackend(
      officers: FirebaseOfficerRepository(),
      auth: FirebaseAuthService(),
      usingFirebase: true,
    );
  } catch (e) {
    debugPrint('Firebase not configured ($e) — using in-memory demo backend.');
    return HParkBackend.demo();
  }
}
