import 'package:flutter/widgets.dart';

import '../theme/hp_colors.dart';

/// State of a citizen's video appeal against a citation.
enum AppealStatus {
  review,
  upheld, // citation stands
  dismissed; // citation cancelled

  String get label => switch (this) {
        AppealStatus.review => 'Under review',
        AppealStatus.upheld => 'Upheld',
        AppealStatus.dismissed => 'Dismissed',
      };

  String get glyph => switch (this) {
        AppealStatus.review => '◌',
        AppealStatus.upheld => '▲',
        AppealStatus.dismissed => '✓',
      };

  Color get color => switch (this) {
        AppealStatus.review => HpColors.purple300,
        AppealStatus.upheld => HpColors.warning,
        AppealStatus.dismissed => HpColors.success,
      };

  Color get tint => switch (this) {
        AppealStatus.review => HpColors.purpleTint,
        AppealStatus.upheld => HpColors.warningTint,
        AppealStatus.dismissed => HpColors.successTint,
      };
}

/// A video appeal: a driver records an explanation challenging a citation;
/// staff review it in HPark Command and uphold or dismiss the citation.
class Appeal {
  Appeal({
    required this.id,
    required this.citationId,
    required this.plate,
    required this.violation,
    required this.fine,
    required this.reason,
    required this.videoSeconds,
    required this.submittedAt,
    this.appellantName = '',
    this.status = AppealStatus.review,
    this.decidedBy,
  });

  final String id; // APL-2026-0142
  final String citationId;
  final String plate;
  final String violation;
  final int fine;
  final String reason;
  final int videoSeconds; // length of the recorded explanation
  final DateTime submittedAt;
  final String appellantName;
  AppealStatus status;
  String? decidedBy;

  String get videoLabel {
    final m = videoSeconds ~/ 60;
    final s = videoSeconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Firestore-agnostic serialization (date as epoch millis, enum by name).
  /// One document under `appeals/{id}`; the Firebase layer maps to/from it.
  Map<String, dynamic> toMap() => {
        'id': id,
        'citationId': citationId,
        'plate': plate,
        'violation': violation,
        'fine': fine,
        'reason': reason,
        'videoSeconds': videoSeconds,
        'submittedAt': submittedAt.millisecondsSinceEpoch,
        'appellantName': appellantName,
        'status': status.name,
        'decidedBy': decidedBy,
      };

  static Appeal fromMap(Map<String, dynamic> map) => Appeal(
        id: map['id'] as String? ?? '',
        citationId: map['citationId'] as String? ?? '',
        plate: map['plate'] as String? ?? '',
        violation: map['violation'] as String? ?? '',
        fine: (map['fine'] as num?)?.toInt() ?? 0,
        reason: map['reason'] as String? ?? '',
        videoSeconds: (map['videoSeconds'] as num?)?.toInt() ?? 0,
        submittedAt: DateTime.fromMillisecondsSinceEpoch(
            (map['submittedAt'] as num?)?.toInt() ??
                DateTime.now().millisecondsSinceEpoch),
        appellantName: map['appellantName'] as String? ?? '',
        status: AppealStatus.values.byName(map['status'] as String? ?? 'review'),
        decidedBy: map['decidedBy'] as String?,
      );
}
