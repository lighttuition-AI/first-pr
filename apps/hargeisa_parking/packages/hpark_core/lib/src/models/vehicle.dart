import 'package:flutter/widgets.dart';

import '../theme/hp_colors.dart';

/// Parking permit state for a looked-up vehicle.
enum PermitStatus {
  valid,
  expired,
  none;

  String get label => switch (this) {
        PermitStatus.valid => 'Valid permit',
        PermitStatus.expired => 'Permit expired',
        PermitStatus.none => 'No permit',
      };

  String get glyph => switch (this) {
        PermitStatus.valid => '✓',
        PermitStatus.expired => '▲',
        PermitStatus.none => '✕',
      };

  Color get color => switch (this) {
        PermitStatus.valid => HpColors.success,
        PermitStatus.expired => HpColors.warning,
        PermitStatus.none => HpColors.danger,
      };

  Color get tint => switch (this) {
        PermitStatus.valid => HpColors.successTint,
        PermitStatus.expired => HpColors.warningTint,
        PermitStatus.none => HpColors.dangerTint,
      };
}

/// A vehicle record — what an officer sees after a plate lookup.
class Vehicle {
  const Vehicle({
    required this.plate,
    required this.ownerName,
    required this.ownerNationalId,
    required this.make,
    required this.color,
    required this.permitStatus,
    this.outstandingCount = 0,
    this.outstandingTotal = 0,
  });

  final String plate; // HG-4821
  final String ownerName;
  final String ownerNationalId;
  final String make; // Toyota Vitz
  final String color;
  final PermitStatus permitStatus;
  final int outstandingCount;
  final int outstandingTotal; // SLSH

  bool get isCompliant =>
      permitStatus == PermitStatus.valid && outstandingCount == 0;

  /// Firestore-agnostic serialization (enum stored by name). One document under
  /// `vehicles/{plate}`; the Firebase layer maps these to/from document data.
  Map<String, dynamic> toMap() => {
        'plate': plate,
        'ownerName': ownerName,
        'ownerNationalId': ownerNationalId,
        'make': make,
        'color': color,
        'permitStatus': permitStatus.name,
        'outstandingCount': outstandingCount,
        'outstandingTotal': outstandingTotal,
      };

  static Vehicle fromMap(Map<String, dynamic> map) => Vehicle(
        plate: map['plate'] as String? ?? '',
        ownerName: map['ownerName'] as String? ?? '',
        ownerNationalId: map['ownerNationalId'] as String? ?? '',
        make: map['make'] as String? ?? '',
        color: map['color'] as String? ?? '',
        permitStatus: PermitStatus.values
            .byName(map['permitStatus'] as String? ?? 'none'),
        outstandingCount: (map['outstandingCount'] as num?)?.toInt() ?? 0,
        outstandingTotal: (map['outstandingTotal'] as num?)?.toInt() ?? 0,
      );
}
