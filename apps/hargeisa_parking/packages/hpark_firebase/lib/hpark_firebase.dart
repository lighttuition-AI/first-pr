/// Firebase Auth + Firestore implementations of the HPark backend seams.
///
/// Apps depend on the interfaces in `hpark_core` (OfficerRepository, AuthService);
/// this package provides the Firebase-backed implementations and a bootstrap that
/// falls back to the in-memory demo backend when Firebase isn't configured yet.
library;

export 'src/firebase_officer_repository.dart';
export 'src/firebase_officer_account.dart';
export 'src/firebase_auth_service.dart';
export 'src/firebase_bootstrap.dart';
export 'src/firebase_vehicle_repository.dart';
export 'src/firebase_citation_repository.dart';
export 'src/firebase_appeal_repository.dart';
export 'src/firebase_deal_repository.dart';
