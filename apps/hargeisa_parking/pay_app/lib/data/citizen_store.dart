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

  /// Save the citizen's vehicle plate (so HPark Pay can find their citations).
  Future<void> setPlate(String uid, String plate) =>
      _doc(uid).set({'plate': plate.trim().toUpperCase()}, SetOptions(merge: true));

  /// Correct profile details a citizen can edit (e.g. a typo at sign-up).
  Future<void> updateProfile(
    String uid, {
    String? nationalId,
    DateTime? dateOfBirth,
  }) {
    final data = <String, dynamic>{};
    if (nationalId != null) data['nationalId'] = nationalId.trim().toUpperCase();
    if (dateOfBirth != null) {
      data['dateOfBirth'] = dateOfBirth.millisecondsSinceEpoch;
    }
    return _doc(uid).set(data, SetOptions(merge: true));
  }
}
