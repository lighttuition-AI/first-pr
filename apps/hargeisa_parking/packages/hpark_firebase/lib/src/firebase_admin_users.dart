import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// A dashboard admin user (member of the `admins` collection).
class AdminUser {
  AdminUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String name;
  final String createdBy;
  final DateTime createdAt;

  String get initials {
    final n = (name.isNotEmpty ? name : email).trim();
    final parts = n.split(RegExp(r'[\s@.]+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  static AdminUser fromMap(Map<String, dynamic> m, String uid) => AdminUser(
        uid: uid,
        email: m['email'] as String? ?? '',
        name: m['name'] as String? ?? '',
        createdBy: m['createdBy'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (m['createdAt'] as num?)?.toInt() ?? 0),
      );
}

/// Manages dashboard admin accounts. An `admins/{uid}` document grants admin
/// powers (the security rules treat membership here as admin), so no Cloud
/// Function / custom claim is needed — an existing admin can add others.
///
/// New accounts are created through a **secondary** Firebase app so the signed-in
/// admin is never logged out.
class FirebaseAdminUsers {
  FirebaseAdminUsers({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('admins');

  Stream<List<AdminUser>> watchAll() => _col.snapshots().map((s) {
        final list = s.docs.map((d) => AdminUser.fromMap(d.data(), d.id)).toList()
          ..sort((a, b) => a.email.toLowerCase().compareTo(b.email.toLowerCase()));
        return list;
      });

  /// Create a new admin: a Firebase Auth account (via a throwaway secondary app,
  /// so the current session is untouched) plus their `admins/{uid}` record.
  Future<void> create({
    required String email,
    required String password,
    required String name,
    required String by,
  }) async {
    final secondary = await Firebase.initializeApp(
      name: 'admin-creator-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final cred = await FirebaseAuth.instanceFor(app: secondary)
          .createUserWithEmailAndPassword(email: email.trim(), password: password);
      final uid = cred.user!.uid;
      await _col.doc(uid).set({
        'email': email.trim(),
        'name': name.trim(),
        'createdBy': by,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      await FirebaseAuth.instanceFor(app: secondary).signOut();
    } finally {
      await secondary.delete();
    }
  }

  /// Revoke a user's dashboard admin access (removes the admins doc; the auth
  /// account itself can only be deleted from the Firebase console / Admin SDK).
  Future<void> revoke(String uid) => _col.doc(uid).delete();
}
