import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hpark_core/hpark_core.dart';

/// Citations, backed by Firestore (`citations/{id}`). This is the spine of the
/// real end-to-end flow: an approved officer **issues** a citation in HPark
/// Enforce; the cited driver **sees and pays** it in HPark Pay (matched on
/// plate); the city reviews appeals in HPark Command.
///
/// Firestore queues writes made offline and flushes them when connectivity
/// returns, so the officer's "issue while offline" path is real, not simulated.
class FirebaseCitationRepository {
  FirebaseCitationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('citations');

  /// Officer issues a citation. The returned future completes when the write is
  /// acknowledged by the server (offline: completes once it syncs).
  Future<void> issue(Citation citation) =>
      _col.doc(citation.id).set(citation.toMap());

  /// Live stream of the citations for one plate — what a driver sees in HPark
  /// Pay. Sorted newest-first client-side (no composite index needed).
  Stream<List<Citation>> watchByPlate(String plate) {
    final key = plate.trim().toUpperCase();
    return _col.where('plate', isEqualTo: key).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => Citation.fromMap({...d.data(), 'id': d.id}))
          .toList()
        ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
      return list;
    });
  }

  /// Live stream of every citation (HPark Command / reporting).
  Stream<List<Citation>> watchAll() =>
      _col.snapshots().map((snap) => snap.docs
          .map((d) => Citation.fromMap({...d.data(), 'id': d.id}))
          .toList()
        ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt)));

  /// Move a citation to a new status (citizen pays / appeals; admin decides an
  /// appeal). Only the `status` field changes.
  Future<void> setStatus(String id, CitationStatus status) =>
      _col.doc(id).update({'status': status.name});
}
