/// Account roles in the HPark ecosystem. Stored on the user's profile document,
/// not on the auth record — drives what each signed-in user may do.
enum AccountRole { officer, citizen, admin }

/// A signed-in user, independent of the auth provider.
class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    this.phone,
    this.displayName,
  });

  final String uid;
  final String? email;
  final String? phone;
  final String? displayName;
}

/// Authentication seam. The app talks to this interface; a concrete
/// implementation (e.g. Firebase Auth) is injected at startup. Keeping it here,
/// provider-agnostic, means screens never import Firebase directly.
abstract class AuthService {
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> register({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();
}
