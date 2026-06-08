import '../models/district.dart';

/// The 8 distinct districts of Hargeisa.
///
/// The original brief listed 9 entries, but **"Maxamuud Haybe"** and
/// **"Mohamoud Haibe"** are two spellings of the same district — collapsed here
/// into one canonical entry. Update the names/stats once the official map and
/// boundaries are provided.
const List<District> kHargeisaDistricts = [
  District(id: 'ahmed-dhagah', name: 'Ahmed Dhagah', officersAssigned: 4, activeViolations: 7, compliancePct: 88),
  District(id: '26-june', name: '26 June', officersAssigned: 3, activeViolations: 5, compliancePct: 91),
  District(id: '31-may', name: '31 May', officersAssigned: 3, activeViolations: 9, compliancePct: 84),
  District(id: 'mohamed-mooge', name: 'Mohamed Mooge', officersAssigned: 5, activeViolations: 6, compliancePct: 89),
  District(id: 'maxamuud-haybe', name: 'Maxamuud Haybe', officersAssigned: 2, activeViolations: 4, compliancePct: 86),
  District(id: 'gacan-libaax', name: 'Gacan Libaax', officersAssigned: 2, activeViolations: 3, compliancePct: 90),
  District(id: 'ibrahim-koodbuur', name: 'Ibrahim Koodbuur', officersAssigned: 4, activeViolations: 8, compliancePct: 83),
  District(id: 'macalin-haroon', name: 'Macalin Haroon', officersAssigned: 3, activeViolations: 5, compliancePct: 87),
];

District? districtById(String? id) {
  if (id == null) return null;
  for (final d in kHargeisaDistricts) {
    if (d.id == id) return d;
  }
  return null;
}
