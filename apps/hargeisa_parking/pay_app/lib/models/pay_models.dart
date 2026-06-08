// Citizen-facing models for HPark Pay.

class Citizen {
  const Citizen({
    required this.fullName,
    required this.nationalId,
    required this.dateOfBirth,
    this.email = '',
  });

  final String fullName;
  final String nationalId;
  final DateTime dateOfBirth;
  final String email;

  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'nationalId': nationalId,
        'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
        'email': email,
      };

  static Citizen fromMap(Map<String, dynamic> map) => Citizen(
        fullName: map['fullName'] as String? ?? '',
        nationalId: map['nationalId'] as String? ?? '',
        dateOfBirth: DateTime.fromMillisecondsSinceEpoch(
            (map['dateOfBirth'] as num?)?.toInt() ??
                DateTime(1990).millisecondsSinceEpoch),
        email: map['email'] as String? ?? '',
      );
}

enum CitationStatus { outstanding, paid, appealReview }

class Citation {
  Citation({
    required this.id,
    required this.plate,
    required this.violation,
    required this.amount,
    required this.issuedAt,
    required this.districtName,
    this.status = CitationStatus.outstanding,
  });

  final String id; // CIT-2026-04821
  final String plate; // HG-4821
  final String violation;
  final int amount; // in SLSH
  final DateTime issuedAt;
  final String districtName;
  CitationStatus status;
}

class Deal {
  const Deal({
    required this.shop,
    required this.title,
    required this.code,
    required this.districtId,
    required this.category,
  });

  final String shop;
  final String title; // e.g. "50% off shoes"
  final String code; // coupon code encoded into the QR
  final String districtId;
  final String category; // Food / Fashion / Electronics ...
}
