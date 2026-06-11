import 'package:flutter/foundation.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

/// Holds the officer's current-shift state: connectivity and the citations
/// issued this shift. Issuing now writes to Firestore via [citations] — the
/// citation lands in the live database, so the cited driver sees it in HPark
/// Pay and the city sees it in HPark Command. [vehicles] backs the plate lookup.
///
/// Firestore persists + retries writes made offline, so the "queue then sync"
/// behaviour is real: a citation issued with no connection flips from Queued to
/// Synced once the server acknowledges it.
class ShiftState extends ChangeNotifier {
  ShiftState({
    FirebaseCitationRepository? citations,
    FirebaseVehicleRepository? vehicles,
  })  : citations = citations ?? FirebaseCitationRepository(),
        vehicles = vehicles ?? FirebaseVehicleRepository();

  final FirebaseCitationRepository citations;
  final FirebaseVehicleRepository vehicles;

  bool _offline = false;
  final List<Citation> _issued = [];

  bool get offline => _offline;
  List<Citation> get issued => List.unmodifiable(_issued);

  int get issuedTodayCount => _issued.length;
  int get queuedCount => _issued.where((c) => !c.synced).length;

  void setOffline(bool value) {
    if (_offline == value) return;
    _offline = value;
    notifyListeners();
  }

  String _newCitationId() {
    final now = DateTime.now();
    final base = (now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0');
    return 'CIT-${now.year}-$base';
  }

  /// Record a new citation: add it to this shift's list and persist it to
  /// Firestore. [vehicle] (if the plate was on file) lets us denormalise the
  /// owner's national ID onto the citation so HPark Pay can match it.
  Citation issue({
    required Officer officer,
    required String plate,
    required Vehicle? vehicle,
    required ViolationType violation,
    required String gps,
    required int photoCount,
    required bool hasVideo,
  }) {
    final district = districtById(officer.assignedDistrictId);
    final citation = Citation(
      id: _newCitationId(),
      plate: plate.trim().toUpperCase(),
      violation: violation.label,
      violationCode: violation.code,
      amount: violation.fine,
      issuedAt: DateTime.now(),
      districtId: officer.assignedDistrictId ?? '',
      districtName: district?.name ?? '',
      ownerNationalId: vehicle?.ownerNationalId ?? '',
      officerId: officer.id,
      officerName: officer.fullName,
      gps: gps,
      photoCount: photoCount,
      hasVideo: hasVideo,
      status: CitationStatus.outstanding,
      synced: !_offline,
    );
    _issued.insert(0, citation);
    notifyListeners();

    // Persist to the live database. Firestore queues this locally and flushes
    // it when connectivity returns; flip the badge to Synced on server ack.
    citations.issue(citation).then((_) {
      if (!citation.synced) {
        citation.synced = true;
        notifyListeners();
      }
    }).catchError((_) {/* remains queued; Firestore retries */});

    return citation;
  }
}
