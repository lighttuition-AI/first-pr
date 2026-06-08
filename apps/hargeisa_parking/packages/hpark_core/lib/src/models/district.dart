/// A Hargeisa district / zone (Somali: *degmo*). Officers are assigned to one
/// district per shift; citizens browse deals by district.
class District {
  const District({
    required this.id,
    required this.name,
    this.officersAssigned = 0,
    this.activeViolations = 0,
    this.compliancePct = 0,
  });

  final String id; // url-safe slug, e.g. "ahmed-dhagah"
  final String name; // display name
  final int officersAssigned;
  final int activeViolations;
  final int compliancePct;
}
