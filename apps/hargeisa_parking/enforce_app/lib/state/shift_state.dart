import 'package:flutter/foundation.dart';

import '../models/issued_citation.dart';

/// Holds the officer's current-shift state: connectivity, and the list of
/// citations issued (some queued offline). Shared across the Patrol / Activity /
/// Profile tabs.
class ShiftState extends ChangeNotifier {
  bool _offline = false;
  final List<IssuedCitation> _issued = [];
  int _counter = 4821;

  bool get offline => _offline;
  List<IssuedCitation> get issued => List.unmodifiable(_issued);

  int get issuedTodayCount => _issued.length;
  int get queuedCount => _issued.where((c) => !c.synced).length;

  void setOffline(bool value) {
    if (_offline == value) return;
    _offline = value;
    if (!value) _syncAll();
    notifyListeners();
  }

  /// Record a new citation. If offline it is queued unsynced.
  IssuedCitation issue({
    required String plate,
    required String violation,
    required int fine,
    required String gps,
    required int photoCount,
    required bool hasVideo,
  }) {
    _counter += 1;
    final citation = IssuedCitation(
      id: 'CIT-2026-${_counter.toString().padLeft(5, '0')}',
      plate: plate,
      violation: violation,
      fine: fine,
      issuedAt: DateTime.now(),
      gps: gps,
      photoCount: photoCount,
      hasVideo: hasVideo,
      synced: !_offline,
    );
    _issued.insert(0, citation);
    notifyListeners();
    return citation;
  }

  void _syncAll() {
    for (final c in _issued) {
      c.synced = true;
    }
  }
}
