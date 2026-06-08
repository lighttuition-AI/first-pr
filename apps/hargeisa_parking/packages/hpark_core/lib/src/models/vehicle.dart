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
}
