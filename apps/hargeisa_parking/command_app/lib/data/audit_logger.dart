import 'package:hpark_firebase/hpark_firebase.dart';

/// Wraps [AuditRepository] with the signed-in admin's identity so the pages can
/// just call `audit.log('Edited vehicle', target: 'F4154')`.
class AuditLogger {
  AuditLogger(this._repo, this.by);

  final AuditRepository _repo;
  final String by;

  Future<void> log(String action, {String target = '', String details = ''}) =>
      _repo.log(action: action, by: by, target: target, details: details);
}
