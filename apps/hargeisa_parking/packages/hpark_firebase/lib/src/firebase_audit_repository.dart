import 'package:cloud_firestore/cloud_firestore.dart';

/// One entry in the activity / audit log.
class AuditEntry {
  AuditEntry({
    required this.id,
    required this.action,
    required this.by,
    required this.at,
    this.target = '',
    this.details = '',
  });

  final String id;
  final String action; // e.g. "Edited vehicle", "Approved officer"
  final String by; // admin name/email who did it
  final DateTime at;
  final String target; // the affected thing, e.g. a plate or officer name
  final String details;

  static AuditEntry fromMap(Map<String, dynamic> m, String id) => AuditEntry(
        id: id,
        action: m['action'] as String? ?? '',
        by: m['by'] as String? ?? '',
        at: DateTime.fromMillisecondsSinceEpoch((m['at'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch),
        target: m['target'] as String? ?? '',
        details: m['details'] as String? ?? '',
      );
}

/// Append-only activity log (`audit/{id}`): records who changed/added what in the
/// dashboard, so every database mutation is attributable.
class AuditRepository {
  AuditRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('audit');

  /// Record an action. Best-effort — never throws into the caller's flow.
  Future<void> log({
    required String action,
    required String by,
    String target = '',
    String details = '',
  }) async {
    try {
      await _col.add({
        'action': action,
        'by': by,
        'target': target,
        'details': details,
        'at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {/* logging must never break the action it records */}
  }

  /// Live, newest-first activity feed.
  Stream<List<AuditEntry>> watchRecent({int limit = 200}) => _col
      .orderBy('at', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => AuditEntry.fromMap(d.data(), d.id)).toList());
}
