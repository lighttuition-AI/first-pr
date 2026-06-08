import '../models/appeal.dart';
import '../models/vehicle.dart';

/// Sample vehicle records keyed by plate (uppercased). Stands in for the
/// uploaded vehicle database an officer's plate lookup checks against.
const Map<String, Vehicle> _vehicles = {
  'HG-4821': Vehicle(
    plate: 'HG-4821',
    ownerName: 'Cabdi Jaamac',
    ownerNationalId: 'SL-7741-0098',
    make: 'Toyota Vitz',
    color: 'Silver',
    permitStatus: PermitStatus.none,
    outstandingCount: 2,
    outstandingTotal: 370000,
  ),
  'HG-1190': Vehicle(
    plate: 'HG-1190',
    ownerName: 'Hodan Maxamed',
    ownerNationalId: 'SL-3320-7711',
    make: 'Nissan Sunny',
    color: 'White',
    permitStatus: PermitStatus.valid,
  ),
  'HG-7732': Vehicle(
    plate: 'HG-7732',
    ownerName: 'Maxamed Cali',
    ownerNationalId: 'SL-9012-4456',
    make: 'Toyota Mark X',
    color: 'Black',
    permitStatus: PermitStatus.expired,
    outstandingCount: 1,
    outstandingTotal: 120000,
  ),
};

/// Plates the simulated LPR / manual lookup can resolve.
List<String> get knownPlates => _vehicles.keys.toList();

/// Look up a vehicle by plate (case / space insensitive). Returns null if the
/// plate isn't in the database — the officer flow treats that as "no record".
Vehicle? lookupVehicle(String plate) {
  final key = plate.trim().toUpperCase().replaceAll(' ', '');
  return _vehicles[key];
}

/// Sample appeals awaiting review in HPark Command.
List<Appeal> seedAppeals() => [
      Appeal(
        id: 'APL-2026-0142',
        citationId: 'CIT-2026-04821',
        plate: 'HG-4821',
        violation: 'Parked in a no-parking zone',
        fine: 250000,
        reason: 'The no-parking sign was hidden behind a market stall.',
        videoSeconds: 38,
        submittedAt: DateTime(2026, 6, 7, 11, 20),
        appellantName: 'Cabdi Jaamac',
      ),
      Appeal(
        id: 'APL-2026-0139',
        citationId: 'CIT-2026-04655',
        plate: 'HG-7732',
        violation: 'Expired parking session',
        fine: 120000,
        reason: 'I paid via ZAAD but the session did not extend.',
        videoSeconds: 52,
        submittedAt: DateTime(2026, 6, 6, 16, 5),
        appellantName: 'Maxamed Cali',
      ),
    ];
