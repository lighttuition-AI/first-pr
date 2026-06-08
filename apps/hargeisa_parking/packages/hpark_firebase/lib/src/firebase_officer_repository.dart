import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hpark_core/hpark_core.dart';

/// Firestore-backed [OfficerRepository]. Officer documents live in the
/// `officers` collection keyed by officer id (e.g. `OFR-201`). A live snapshot
/// keeps an in-memory cache in sync, so an approval made in HPark Command flips
/// the officer's HPark Enforce session to unlocked in real time.
///
/// Drop-in for `OfficerRepository.demo()` — same interface, so no screen changes.
class FirebaseOfficerRepository extends ChangeNotifier
    implements OfficerRepository {
  FirebaseOfficerRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance {
    _sub = _col
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .listen(_onSnapshot, onError: (Object e) => debugPrint('officers stream: $e'));
  }

  final FirebaseFirestore _db;
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _sub;
  List<Officer> _cache = const [];

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('officers');

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    _cache = snap.docs
        .map((d) => Officer.fromMap({...d.data(), 'id': d.id}))
        .toList();
    notifyListeners();
  }

  @override
  List<Officer> get officers => List.unmodifiable(_cache);

  @override
  List<Officer> get pending =>
      _cache.where((o) => o.status == ApprovalStatus.pending).toList();

  @override
  List<Officer> get approved =>
      _cache.where((o) => o.status == ApprovalStatus.approved).toList();

  @override
  Officer? byId(String id) {
    for (final o in _cache) {
      if (o.id == id) return o;
    }
    return null;
  }

  @override
  Officer? authenticate(String identifier) {
    final q = identifier.trim().toLowerCase();
    if (q.isEmpty) return null;
    for (final o in _cache) {
      if (o.id.toLowerCase() == q ||
          o.badgeNumber.toLowerCase() == q ||
          o.nationalId.toLowerCase() == q) {
        return o;
      }
    }
    return null;
  }

  @override
  Future<Officer> register({
    required String fullName,
    required String nationalId,
    required String phone,
    required DateTime dateOfBirth,
  }) async {
    // Allocate a sequential officer number via a transaction on a counter doc.
    final counterRef = _db.collection('counters').doc('officers');
    final number = await _db.runTransaction<int>((tx) async {
      final snap = await tx.get(counterRef);
      final next = ((snap.data()?['value'] as num?)?.toInt() ?? 200) + 1;
      tx.set(counterRef, {'value': next});
      return next;
    });
    final numStr = number.toString().padLeft(3, '0');
    final officer = Officer(
      id: 'OFR-$numStr',
      fullName: fullName.trim(),
      nationalId: nationalId.trim(),
      phone: phone.trim(),
      dateOfBirth: dateOfBirth,
      badgeNumber: 'HG-OFR-$numStr',
      status: ApprovalStatus.pending,
      appliedAt: DateTime.now(),
    );
    await _col.doc(officer.id).set(officer.toMap());
    return officer;
  }

  @override
  Future<Officer> approve(String id, {required String by, String? districtId}) =>
      _patch(id, {
        'status': ApprovalStatus.approved.name,
        'approvedAt': DateTime.now().millisecondsSinceEpoch,
        'approvedBy': by,
        'assignedDistrictId': districtId,
        'reviewNote': '',
      });

  @override
  Future<Officer> reject(String id, {required String by, String? note}) =>
      _patch(id, {
        'status': ApprovalStatus.rejected.name,
        'approvedAt': DateTime.now().millisecondsSinceEpoch,
        'approvedBy': by,
        'reviewNote': note ?? '',
      });

  @override
  Future<Officer> suspend(String id, {required String by}) => _patch(id, {
        'status': ApprovalStatus.suspended.name,
        'approvedBy': by,
      });

  Future<Officer> _patch(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
    final doc = await _col.doc(id).get();
    final map = doc.data();
    if (map == null) throw StateError('Officer $id not found');
    return Officer.fromMap({...map, 'id': doc.id});
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
