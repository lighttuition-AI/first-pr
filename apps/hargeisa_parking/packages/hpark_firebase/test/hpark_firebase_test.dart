import 'package:flutter_test/flutter_test.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

void main() {
  test('demo backend works without Firebase configured', () {
    final backend = HParkBackend.demo();
    expect(backend.usingFirebase, isFalse);
    expect(backend.officers, isA<OfficerRepository>());
    expect(backend.officers.pending, isNotEmpty);
  });

  test('Officer round-trips through map serialization', () {
    final officer = Officer(
      id: 'OFR-777',
      fullName: 'Test Officer',
      nationalId: 'SL-1234-5678',
      phone: '+252 63 0000000',
      dateOfBirth: DateTime(1995, 5, 5),
      badgeNumber: 'HG-OFR-777',
      status: ApprovalStatus.approved,
      appliedAt: DateTime(2026, 1, 1),
      assignedDistrictId: 'ahmed-dhagah',
      approvedAt: DateTime(2026, 1, 2),
      approvedBy: 'Hodan Ali',
      citationsIssued: 12,
    );
    final restored = Officer.fromMap(officer.toMap());
    expect(restored.id, officer.id);
    expect(restored.status, ApprovalStatus.approved);
    expect(restored.assignedDistrictId, 'ahmed-dhagah');
    expect(restored.dateOfBirth, officer.dateOfBirth);
    expect(restored.citationsIssued, 12);
    expect(restored.canUseOfficerApp, isTrue);
  });
}
