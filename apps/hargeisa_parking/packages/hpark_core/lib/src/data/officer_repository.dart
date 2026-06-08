import 'package:flutter/foundation.dart';

import '../models/approval_status.dart';
import '../models/officer.dart';

/// Source of truth for officer accounts and their approval state.
///
/// In production this is backed by a shared server (Firebase Auth + Firestore is
/// the recommended fit) so an approval made in HPark Command instantly unlocks
/// HPark Enforce on the officer's device. [MockOfficerRepository] is an in-memory
/// stand-in that lets every app run and the flow be demoed today.
abstract class OfficerRepository extends ChangeNotifier {
  List<Officer> get officers;

  List<Officer> get pending =>
      officers.where((o) => o.status == ApprovalStatus.pending).toList();
  List<Officer> get approved =>
      officers.where((o) => o.status == ApprovalStatus.approved).toList();

  Officer? byId(String id);

  /// Self-registration from the officer app. Returns the new [Officer] in
  /// [ApprovalStatus.pending] — it cannot use the app until an admin approves.
  Future<Officer> register({
    required String fullName,
    required String nationalId,
    required String phone,
    required DateTime dateOfBirth,
  });

  /// Mock "sign in": look up an existing officer by id, badge number, or national id.
  Officer? authenticate(String identifier);

  Future<Officer> approve(String id, {required String by, String? districtId});
  Future<Officer> reject(String id, {required String by, String? note});
  Future<Officer> suspend(String id, {required String by});

  /// A seeded in-memory repository shared by the demo builds.
  factory OfficerRepository.demo() = MockOfficerRepository.seeded;
}

class MockOfficerRepository extends ChangeNotifier implements OfficerRepository {
  MockOfficerRepository(this._officers);

  factory MockOfficerRepository.seeded() =>
      MockOfficerRepository(List.of(_seed));

  final List<Officer> _officers;
  int _counter = 200;

  @override
  List<Officer> get officers => List.unmodifiable(_officers);

  @override
  List<Officer> get pending =>
      _officers.where((o) => o.status == ApprovalStatus.pending).toList();

  @override
  List<Officer> get approved =>
      _officers.where((o) => o.status == ApprovalStatus.approved).toList();

  @override
  Officer? byId(String id) {
    for (final o in _officers) {
      if (o.id == id) return o;
    }
    return null;
  }

  int _indexOf(String id) => _officers.indexWhere((o) => o.id == id);

  @override
  Future<Officer> register({
    required String fullName,
    required String nationalId,
    required String phone,
    required DateTime dateOfBirth,
  }) async {
    _counter += 1;
    final num = _counter.toString().padLeft(3, '0');
    final officer = Officer(
      id: 'OFR-$num',
      fullName: fullName.trim(),
      nationalId: nationalId.trim(),
      phone: phone.trim(),
      dateOfBirth: dateOfBirth,
      badgeNumber: 'HG-OFR-$num',
      status: ApprovalStatus.pending,
      appliedAt: DateTime.now(),
    );
    _officers.insert(0, officer);
    notifyListeners();
    return officer;
  }

  @override
  Officer? authenticate(String identifier) {
    final q = identifier.trim().toLowerCase();
    if (q.isEmpty) return null;
    for (final o in _officers) {
      if (o.id.toLowerCase() == q ||
          o.badgeNumber.toLowerCase() == q ||
          o.nationalId.toLowerCase() == q) {
        return o;
      }
    }
    return null;
  }

  @override
  Future<Officer> approve(String id, {required String by, String? districtId}) {
    return _update(
      id,
      (o) => o.copyWith(
        status: ApprovalStatus.approved,
        approvedAt: DateTime.now(),
        approvedBy: by,
        assignedDistrictId: districtId,
        reviewNote: '',
      ),
    );
  }

  @override
  Future<Officer> reject(String id, {required String by, String? note}) {
    return _update(
      id,
      (o) => o.copyWith(
        status: ApprovalStatus.rejected,
        approvedAt: DateTime.now(),
        approvedBy: by,
        reviewNote: note ?? '',
      ),
    );
  }

  @override
  Future<Officer> suspend(String id, {required String by}) {
    return _update(
      id,
      (o) => o.copyWith(status: ApprovalStatus.suspended, approvedBy: by),
    );
  }

  Future<Officer> _update(String id, Officer Function(Officer) fn) async {
    final i = _indexOf(id);
    if (i < 0) throw StateError('Officer $id not found');
    final updated = fn(_officers[i]);
    _officers[i] = updated;
    notifyListeners();
    return updated;
  }

  // ---- Seed data ----
  static final List<Officer> _seed = [
    Officer(
      id: 'OFR-118',
      fullName: 'Amina Yusuf',
      nationalId: 'SL-9920-1183',
      phone: '+252 63 4412 118',
      dateOfBirth: DateTime(1994, 3, 12),
      badgeNumber: 'HG-OFR-118',
      status: ApprovalStatus.approved,
      appliedAt: DateTime(2026, 1, 8),
      approvedAt: DateTime(2026, 1, 9),
      approvedBy: 'Hodan Ali',
      assignedDistrictId: 'ahmed-dhagah',
      citationsIssued: 412,
    ),
    Officer(
      id: 'OFR-104',
      fullName: 'Khadar Jama',
      nationalId: 'SL-8814-2204',
      phone: '+252 63 4419 104',
      dateOfBirth: DateTime(1990, 11, 2),
      badgeNumber: 'HG-OFR-104',
      status: ApprovalStatus.approved,
      appliedAt: DateTime(2026, 1, 6),
      approvedAt: DateTime(2026, 1, 7),
      approvedBy: 'Hodan Ali',
      assignedDistrictId: 'mohamed-mooge',
      citationsIssued: 389,
    ),
    Officer(
      id: 'OFR-127',
      fullName: 'Liban Warsame',
      nationalId: 'SL-9133-7781',
      phone: '+252 63 4471 127',
      dateOfBirth: DateTime(1996, 6, 24),
      badgeNumber: 'HG-OFR-127',
      status: ApprovalStatus.pending,
      appliedAt: DateTime(2026, 6, 7, 9, 14),
    ),
    Officer(
      id: 'OFR-128',
      fullName: 'Sahra Abdi',
      nationalId: 'SL-9542-3360',
      phone: '+252 63 4471 128',
      dateOfBirth: DateTime(1999, 2, 9),
      badgeNumber: 'HG-OFR-128',
      status: ApprovalStatus.pending,
      appliedAt: DateTime(2026, 6, 7, 16, 2),
    ),
    Officer(
      id: 'OFR-129',
      fullName: 'Mustafe Cabdi',
      nationalId: 'SL-9077-1145',
      phone: '+252 63 4471 129',
      dateOfBirth: DateTime(1993, 8, 30),
      badgeNumber: 'HG-OFR-129',
      status: ApprovalStatus.pending,
      appliedAt: DateTime(2026, 6, 8, 7, 41),
    ),
  ];
}
