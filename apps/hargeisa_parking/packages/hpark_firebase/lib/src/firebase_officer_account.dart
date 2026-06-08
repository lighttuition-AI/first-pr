import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hpark_core/hpark_core.dart';

/// Officer-side view of the `officers` collection, keyed by the officer's auth
/// UID. Used by HPark Enforce: an officer creates **only their own** record
/// (as `pending`) and watches it live, so an admin's approval in HPark Command
/// flips their session to unlocked in real time — across devices.
///
/// This is deliberately single-document (no full-collection read), matching the
/// security rules: a non-admin officer may read only their own record.
class FirebaseOfficerAccount {
  FirebaseOfficerAccount({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('officers').doc(uid);

  /// Live status of the signed-in officer's record (null until they register).
  Stream<Officer?> watch(String uid) => _doc(uid).snapshots().map((snap) {
        final data = snap.data();
        if (data == null) return null;
        return Officer.fromMap({...data, 'id': snap.id});
      });

  Future<Officer?> get(String uid) async {
    final snap = await _doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return Officer.fromMap({...data, 'id': snap.id});
  }

  /// Self-registration from the officer app. Writes `officers/{uid}` as `pending`
  /// with a sequential badge number. The officer cannot operate until an admin
  /// approves them in HPark Command.
  Future<Officer> createPending({
    required String uid,
    required String email,
    required String fullName,
    required String nationalId,
    required String phone,
    required DateTime dateOfBirth,
  }) async {
    final counterRef = _db.collection('counters').doc('officers');
    final number = await _db.runTransaction<int>((tx) async {
      final snap = await tx.get(counterRef);
      final next = ((snap.data()?['value'] as num?)?.toInt() ?? 200) + 1;
      tx.set(counterRef, {'value': next});
      return next;
    });
    final numStr = number.toString().padLeft(3, '0');
    final officer = Officer(
      id: uid,
      fullName: fullName.trim(),
      nationalId: nationalId.trim(),
      phone: phone.trim(),
      dateOfBirth: dateOfBirth,
      badgeNumber: 'HG-OFR-$numStr',
      status: ApprovalStatus.pending,
      appliedAt: DateTime.now(),
      email: email.trim(),
    );
    await _doc(uid).set(officer.toMap());
    return officer;
  }
}
