import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pay_models.dart';

/// Stores a citizen's profile in Firestore under `citizens/{uid}`, so their
/// name / national ID restore on sign-in across devices.
class CitizenStore {
  CitizenStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('citizens').doc(uid);

  Future<void> create(String uid, Citizen citizen) => _doc(uid).set(citizen.toMap());

  Future<Citizen?> get(String uid) async {
    final snap = await _doc(uid).get();
    final data = snap.data();
    return data == null ? null : Citizen.fromMap(data);
  }
}
