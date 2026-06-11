import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hpark_core/hpark_core.dart';

/// District shop deals, backed by Firestore (`deals/{id}`). Read by every
/// citizen in HPark Pay; managed by the city / partner shops. Replaces the old
/// hard-coded `kDeals` list.
class FirebaseDealRepository {
  FirebaseDealRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('deals');

  Future<List<Deal>> all() async {
    final snap = await _col.get();
    return snap.docs.map((d) => Deal.fromMap(d.data(), id: d.id)).toList();
  }

  Stream<List<Deal>> watchAll() => _col.snapshots().map(
      (snap) => snap.docs.map((d) => Deal.fromMap(d.data(), id: d.id)).toList());

  Future<void> upsert(Deal deal) =>
      _col.doc(deal.code).set(deal.toMap());
}
