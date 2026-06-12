import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// A dashboard account and its role.
///  - `admin` — full powers (approve officers, manage vehicles, see the audit
///    log, create users).
///  - `user` — a normal operator: browse + look up only. No officer approval,
///    no vehicle import/edit, no audit log, no user creation.
class DashboardUser {
  DashboardUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdBy,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String name;
  final String role; // 'admin' | 'user'
  final String createdBy;
  final DateTime createdAt;

  bool get isAdmin => role == 'admin';

  String get initials {
    final n = (name.isNotEmpty ? name : email).trim();
    final parts = n.split(RegExp(r'[\s@.]+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  static DashboardUser fromMap(Map<String, dynamic> m, String uid) => DashboardUser(
        uid: uid,
        email: m['email'] as String? ?? '',
        name: m['name'] as String? ?? '',
        role: (m['role'] as String?) == 'admin' ? 'admin' : 'user',
        createdBy: m['createdBy'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (m['createdAt'] as num?)?.toInt() ?? 0),
      );
}

/// Manages dashboard accounts in `dashboardUsers/{uid}`. A document with
/// `role: 'admin'` grants admin powers (the security rules treat it as admin),
/// so no Cloud Function / custom claim is needed — an existing admin can add
/// both fellow admins and normal users.
///
/// New accounts are created through a **secondary** Firebase app so the signed-in
/// admin is never logged out.
class FirebaseAdminUsers {
  FirebaseAdminUsers({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('dashboardUsers');

  /// All dashboard accounts, admins first then by email.
  Stream<List<DashboardUser>> watchAll() => _col.snapshots().map((s) {
        final list = s.docs.map((d) => DashboardUser.fromMap(d.data(), d.id)).toList()
          ..sort((a, b) {
            if (a.isAdmin != b.isAdmin) return a.isAdmin ? -1 : 1;
            return a.email.toLowerCase().compareTo(b.email.toLowerCase());
          });
        return list;
      });

  /// The *currently signed-in* user's dashboard role:
  ///  - `'admin'` — bootstrap `admin` claim, legacy `admins/{uid}` member, or a
  ///    `dashboardUsers/{uid}` record with `role: 'admin'`.
  ///  - `'user'`  — a `dashboardUsers/{uid}` record with any other role.
  ///  - `null`    — not a provisioned dashboard account → no dashboard access.
  ///
  /// The claim check comes first and is offline-safe (cached token), so a real
  /// admin is never locked out by a transient Firestore read failure.
  Future<String?> currentRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final token = await user.getIdTokenResult();
      if (token.claims?['admin'] == true) return 'admin';
    } catch (_) {/* offline / no claim */}
    try {
      if ((await _db.collection('admins').doc(user.uid).get()).exists) return 'admin';
      final d = await _col.doc(user.uid).get();
      final data = d.data();
      if (data != null) return data['role'] == 'admin' ? 'admin' : 'user';
    } catch (_) {/* read failed — fail closed (no access) */}
    return null;
  }

  /// Convenience: is the signed-in user an admin?
  Future<bool> isAdmin() async => (await currentRole()) == 'admin';

  /// Create a new dashboard account: a Firebase Auth login (via a throwaway
  /// secondary app, so the current session is untouched) plus their
  /// `dashboardUsers/{uid}` record carrying the chosen [role].
  Future<void> create({
    required String email,
    required String password,
    required String name,
    required String by,
    String role = 'admin',
  }) async {
    final secondary = await Firebase.initializeApp(
      name: 'user-creator-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final cred = await FirebaseAuth.instanceFor(app: secondary)
          .createUserWithEmailAndPassword(email: email.trim(), password: password);
      final uid = cred.user!.uid;
      await _col.doc(uid).set({
        'email': email.trim(),
        'name': name.trim(),
        'role': role == 'admin' ? 'admin' : 'user',
        'createdBy': by,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      await FirebaseAuth.instanceFor(app: secondary).signOut();
    } finally {
      await secondary.delete();
    }
  }

  /// Remove a dashboard account's access (deletes the record; the auth login
  /// itself can only be deleted from the Firebase console / Admin SDK).
  Future<void> revoke(String uid) => _col.doc(uid).delete();
}
