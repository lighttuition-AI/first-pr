/// A type of parking violation an officer can cite, with its standard fine.
class ViolationType {
  const ViolationType({
    required this.code,
    required this.label,
    required this.fine,
  });

  final String code; // V-NPZ
  final String label; // Parked in a no-parking zone
  final int fine; // SLSH
}

/// The violation catalogue (fines in SLSH). Adjust to the city's fee schedule.
const List<ViolationType> kViolationTypes = [
  ViolationType(code: 'V-NPZ', label: 'Parked in a no-parking zone', fine: 250000),
  ViolationType(code: 'V-EXP', label: 'Expired parking session', fine: 120000),
  ViolationType(code: 'V-DWY', label: 'Blocking a driveway', fine: 180000),
  ViolationType(code: 'V-DBL', label: 'Double parking', fine: 200000),
  ViolationType(code: 'V-HYD', label: 'Parked by a fire hydrant', fine: 300000),
  ViolationType(code: 'V-DIS', label: 'Disabled bay without permit', fine: 350000),
];
