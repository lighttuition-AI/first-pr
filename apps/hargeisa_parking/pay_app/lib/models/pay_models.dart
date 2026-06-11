// Citizen profile for HPark Pay. (Citation, CitationStatus and Deal are shared
// across the apps and now live in hpark_core.)

class Citizen {
  const Citizen({
    required this.fullName,
    required this.nationalId,
    required this.dateOfBirth,
    this.email = '',
    this.plate = '',
  });

  final String fullName;
  final String nationalId;
  final DateTime dateOfBirth;
  final String email;

  /// The citizen's vehicle number plate. Citations are matched to a driver on
  /// their plate, so this is how HPark Pay finds "your citations".
  final String plate;

  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Citizen copyWith({
    String? nationalId,
    DateTime? dateOfBirth,
    String? plate,
  }) =>
      Citizen(
        fullName: fullName,
        nationalId: nationalId ?? this.nationalId,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        email: email,
        plate: plate ?? this.plate,
      );

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'nationalId': nationalId,
        'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
        'email': email,
        'plate': plate,
      };

  static Citizen fromMap(Map<String, dynamic> map) => Citizen(
        fullName: map['fullName'] as String? ?? '',
        nationalId: map['nationalId'] as String? ?? '',
        dateOfBirth: DateTime.fromMillisecondsSinceEpoch(
            (map['dateOfBirth'] as num?)?.toInt() ??
                DateTime(1990).millisecondsSinceEpoch),
        email: map['email'] as String? ?? '',
        plate: (map['plate'] as String? ?? '').toUpperCase(),
      );
}
