import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hpark_core/hpark_core.dart';

/// The vehicle registry, backed by Firestore (`vehicles/{plate}`). Replaces the
/// old hard-coded sample map: an officer's plate lookup in HPark Enforce now
/// queries the live database, and admins manage records from HPark Command.
///
/// Documents are keyed by a normalised plate (uppercased, spaces stripped) so a
/// lookup is a single document read.
class FirebaseVehicleRepository {
  FirebaseVehicleRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('vehicles');

  static String normalisePlate(String plate) =>
      plate.trim().toUpperCase().replaceAll(' ', '');

  /// Look up a vehicle by plate. Returns null when the plate isn't on file —
  /// the officer flow treats that as "no record" (issue against the plate anyway).
  Future<Vehicle?> lookup(String plate) async {
    final snap = await _col.doc(normalisePlate(plate)).get();
    final data = snap.data();
    return data == null ? null : Vehicle.fromMap({...data, 'plate': snap.id});
  }

  /// Plates currently on file — used to seed the demo "Simulate LPR" scan and
  /// the "Try:" hint in HPark Enforce.
  Future<List<String>> knownPlates({int limit = 25}) async {
    final snap = await _col.limit(limit).get();
    return snap.docs.map((d) => d.id).toList();
  }

  /// Add or update a vehicle record (admin / bulk import).
  Future<void> upsert(Vehicle vehicle) =>
      _col.doc(normalisePlate(vehicle.plate)).set(vehicle.toMap());

  Future<List<Vehicle>> all() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => Vehicle.fromMap({...d.data(), 'plate': d.id}))
        .toList();
  }
}
