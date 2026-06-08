import 'package:firebase_auth/firebase_auth.dart';
import 'package:hpark_core/hpark_core.dart';

/// Firebase Auth implementation of [AuthService]. Email/password by default —
/// swap to phone auth (ZAAD/eDahab numbers) by adding a `verifyPhoneNumber`
/// path; the rest of the app only depends on the [AuthService] seam.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  AuthUser? _map(User? u) => u == null
      ? null
      : AuthUser(
          uid: u.uid,
          email: u.email,
          phone: u.phoneNumber,
          displayName: u.displayName,
        );

  @override
  Stream<AuthUser?> authStateChanges() => _auth.authStateChanges().map(_map);

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _map(cred.user)!;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (displayName != null && displayName.isNotEmpty) {
      await cred.user!.updateDisplayName(displayName);
    }
    return _map(cred.user)!;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
