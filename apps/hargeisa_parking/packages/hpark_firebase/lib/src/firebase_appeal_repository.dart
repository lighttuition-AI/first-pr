import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hpark_core/hpark_core.dart';

/// Video appeals, backed by Firestore (`appeals/{id}`). A driver submits one
/// from HPark Pay (always created as `review`); the city watches the queue live
/// in HPark Command and upholds or dismisses it.
class FirebaseAppealRepository {
  FirebaseAppealRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('appeals');

  /// Citizen submits an appeal (must start in [AppealStatus.review]).
  Future<void> submit(Appeal appeal) =>
      _col.doc(appeal.id).set(appeal.toMap());

  /// Live appeals queue for HPark Command, newest-first.
  Stream<List<Appeal>> watchAll() =>
      _col.snapshots().map((snap) => snap.docs
          .map((d) => Appeal.fromMap({...d.data(), 'id': d.id}))
          .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt)));

  /// Admin decision: uphold (citation stands) or dismiss (citation cancelled).
  Future<void> decide(String id,
          {required AppealStatus status, required String by}) =>
      _col.doc(id).update({'status': status.name, 'decidedBy': by});
}
