import 'package:flutter_test/flutter_test.dart';
import 'package:hpark_core/hpark_core.dart';

void main() {
  group('Hargeisa districts', () {
    test('are de-duplicated to 8 distinct entries', () {
      expect(kHargeisaDistricts.length, 8);
    });

    test('have unique ids and names (no Maxamuud/Mohamoud duplicate)', () {
      final ids = kHargeisaDistricts.map((d) => d.id).toSet();
      final names = kHargeisaDistricts.map((d) => d.name).toSet();
      expect(ids.length, 8);
      expect(names.length, 8);
    });
  });

  group('Officer approval workflow', () {
    test('self-registration starts pending and cannot use the officer app',
        () async {
      final repo = OfficerRepository.demo();
      final officer = await repo.register(
        fullName: 'Test Officer',
        nationalId: 'SL-0000-0001',
        phone: '+252 00 0000000',
        dateOfBirth: DateTime(1995, 1, 1),
      );
      expect(officer.status, ApprovalStatus.pending);
      expect(officer.canUseOfficerApp, isFalse);
      expect(repo.pending.any((o) => o.id == officer.id), isTrue);
    });

    test('admin approval unlocks the officer app', () async {
      final repo = OfficerRepository.demo();
      final pending = repo.pending.first;
      expect(pending.canUseOfficerApp, isFalse);

      final approved = await repo.approve(
        pending.id,
        by: 'Hodan Ali',
        districtId: 'ahmed-dhagah',
      );

      expect(approved.status, ApprovalStatus.approved);
      expect(approved.canUseOfficerApp, isTrue);
      expect(approved.assignedDistrictId, 'ahmed-dhagah');
      expect(repo.byId(pending.id)!.canUseOfficerApp, isTrue);
    });

    test('rejection keeps the officer locked out', () async {
      final repo = OfficerRepository.demo();
      final pending = repo.pending.first;
      final rejected =
          await repo.reject(pending.id, by: 'Hodan Ali', note: 'Unverified ID');
      expect(rejected.status, ApprovalStatus.rejected);
      expect(rejected.canUseOfficerApp, isFalse);
    });
  });
}
