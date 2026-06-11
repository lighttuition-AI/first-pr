import 'package:flutter/widgets.dart';

import '../theme/hp_colors.dart';

/// Lifecycle of a parking citation, shared by all three apps:
///  - [outstanding]   issued, awaiting payment
///  - [paid]          settled by the citizen (ZAAD / eDahab)
///  - [appealReview]  the citizen submitted a video appeal; under review
///  - [dismissed]     an admin upheld the appeal and cancelled the citation
enum CitationStatus {
  outstanding,
  paid,
  appealReview,
  dismissed;

  String get label => switch (this) {
        CitationStatus.outstanding => 'Outstanding',
        CitationStatus.paid => 'Paid',
        CitationStatus.appealReview => 'Appeal review',
        CitationStatus.dismissed => 'Dismissed',
      };

  String get glyph => switch (this) {
        CitationStatus.outstanding => '▲',
        CitationStatus.paid => '✓',
        CitationStatus.appealReview => '◌',
        CitationStatus.dismissed => '⊘',
      };

  Color get color => switch (this) {
        CitationStatus.outstanding => HpColors.danger,
        CitationStatus.paid => HpColors.success,
        CitationStatus.appealReview => HpColors.purple300,
        CitationStatus.dismissed => HpColors.textMuted,
      };

  Color get tint => switch (this) {
        CitationStatus.outstanding => HpColors.dangerTint,
        CitationStatus.paid => HpColors.successTint,
        CitationStatus.appealReview => HpColors.purpleTint,
        CitationStatus.dismissed => HpColors.overlay,
      };
}

/// A parking citation. One Firestore document under `citations/{id}`, written by
/// the officer who issues it (HPark Enforce) and read by the cited driver
/// (HPark Pay, matched on [plate]) and the city (HPark Command).
///
/// Firestore-agnostic serialization (dates as epoch millis, enums by name); the
/// Firebase layer maps these to/from document data.
class Citation {
  Citation({
    required this.id,
    required this.plate,
    required this.violation,
    required this.amount,
    required this.issuedAt,
    required this.districtName,
    this.districtId = '',
    this.violationCode = '',
    this.ownerNationalId = '',
    this.officerId = '',
    this.officerName = '',
    this.gps = '',
    this.photoCount = 0,
    this.hasVideo = false,
    this.status = CitationStatus.outstanding,
    this.synced = true,
  });

  final String id; // CIT-2026-04821
  final String plate; // HG-4821 (links the citation to the driver in HPark Pay)
  final String violation; // human label, e.g. "Parked in a no-parking zone"
  final int amount; // fine in SLSH
  final DateTime issuedAt;
  final String districtName;
  final String districtId;
  final String violationCode; // V-NPZ
  final String ownerNationalId; // denormalised from the vehicle record (may be '')
  final String officerId; // auth uid of the issuing officer
  final String officerName;
  final String gps; // "9.5621° N, 44.0650° E"
  final int photoCount;
  final bool hasVideo;
  CitationStatus status;

  /// UI-only: whether this citation's write has reached the server. Firestore
  /// queues writes made offline and flushes them automatically when back online.
  bool synced;

  Map<String, dynamic> toMap() => {
        'id': id,
        'plate': plate,
        'violation': violation,
        'amount': amount,
        'issuedAt': issuedAt.millisecondsSinceEpoch,
        'districtName': districtName,
        'districtId': districtId,
        'violationCode': violationCode,
        'ownerNationalId': ownerNationalId,
        'officerId': officerId,
        'officerName': officerName,
        'gps': gps,
        'photoCount': photoCount,
        'hasVideo': hasVideo,
        'status': status.name,
      };

  static Citation fromMap(Map<String, dynamic> map) => Citation(
        id: map['id'] as String? ?? '',
        plate: map['plate'] as String? ?? '',
        violation: map['violation'] as String? ?? '',
        amount: (map['amount'] as num?)?.toInt() ?? 0,
        issuedAt: DateTime.fromMillisecondsSinceEpoch(
            (map['issuedAt'] as num?)?.toInt() ??
                DateTime.now().millisecondsSinceEpoch),
        districtName: map['districtName'] as String? ?? '',
        districtId: map['districtId'] as String? ?? '',
        violationCode: map['violationCode'] as String? ?? '',
        ownerNationalId: map['ownerNationalId'] as String? ?? '',
        officerId: map['officerId'] as String? ?? '',
        officerName: map['officerName'] as String? ?? '',
        gps: map['gps'] as String? ?? '',
        photoCount: (map['photoCount'] as num?)?.toInt() ?? 0,
        hasVideo: map['hasVideo'] as bool? ?? false,
        status: CitationStatus.values
            .byName(map['status'] as String? ?? 'outstanding'),
      );
}
