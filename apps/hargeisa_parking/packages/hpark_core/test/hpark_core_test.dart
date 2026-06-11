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

    test('a rogue officer can be deleted from the system', () async {
      final repo = OfficerRepository.demo();
      final before = repo.officers.length;
      final victim = repo.officers.first;
      await repo.delete(victim.id);
      expect(repo.officers.length, before - 1);
      expect(repo.byId(victim.id), isNull);
    });
  });

  group('Firestore model serialization', () {
    test('Citation round-trips through map', () {
      final c = Citation(
        id: 'CIT-2026-04822',
        plate: 'HG-4821',
        violation: 'Parked in a no-parking zone',
        violationCode: 'V-NPZ',
        amount: 250000,
        issuedAt: DateTime(2026, 6, 11, 14, 22),
        districtId: 'ahmed-dhagah',
        districtName: 'Ahmed Dhagah',
        ownerNationalId: 'SL-7741-0098',
        officerId: 'uid-123',
        officerName: 'Amina Yusuf',
        gps: '9.5621° N, 44.0650° E',
        photoCount: 2,
        hasVideo: true,
        status: CitationStatus.appealReview,
      );
      final r = Citation.fromMap(c.toMap());
      expect(r.id, c.id);
      expect(r.plate, c.plate);
      expect(r.amount, 250000);
      expect(r.issuedAt, c.issuedAt);
      expect(r.ownerNationalId, 'SL-7741-0098');
      expect(r.status, CitationStatus.appealReview);
      expect(r.hasVideo, isTrue);
    });

    test('Vehicle round-trips through map (permit status by name)', () {
      const v = Vehicle(
        plate: 'HG-7732',
        ownerName: 'Maxamed Cali',
        ownerNationalId: 'SL-9012-4456',
        make: 'Toyota Mark X',
        color: 'Black',
        permitStatus: PermitStatus.expired,
        outstandingCount: 1,
        outstandingTotal: 120000,
      );
      final r = Vehicle.fromMap(v.toMap());
      expect(r.plate, 'HG-7732');
      expect(r.permitStatus, PermitStatus.expired);
      expect(r.outstandingTotal, 120000);
    });

    test('Appeal round-trips through map', () {
      final a = Appeal(
        id: 'APL-2026-0142',
        citationId: 'CIT-2026-04821',
        plate: 'HG-4821',
        violation: 'Parked in a no-parking zone',
        fine: 250000,
        reason: 'Sign was hidden.',
        videoSeconds: 38,
        submittedAt: DateTime(2026, 6, 7, 11, 20),
        appellantName: 'Cabdi Jaamac',
        status: AppealStatus.review,
      );
      final r = Appeal.fromMap(a.toMap());
      expect(r.id, a.id);
      expect(r.citationId, 'CIT-2026-04821');
      expect(r.videoSeconds, 38);
      expect(r.status, AppealStatus.review);
      expect(r.submittedAt, a.submittedAt);
    });

    test('Deal round-trips through map', () {
      const d = Deal(
        shop: 'Liido Shoes',
        title: '50% off all sneakers',
        code: 'HP-LIID-26',
        districtId: 'ahmed-dhagah',
        category: 'Fashion',
      );
      final r = Deal.fromMap(d.toMap(), id: d.code);
      expect(r.id, 'HP-LIID-26');
      expect(r.shop, 'Liido Shoes');
      expect(r.districtId, 'ahmed-dhagah');
    });
  });
}
