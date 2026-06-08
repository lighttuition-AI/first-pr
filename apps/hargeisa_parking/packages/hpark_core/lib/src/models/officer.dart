import 'approval_status.dart';

/// A parking enforcement officer. Officers self-register in HPark Enforce and
/// start in [ApprovalStatus.pending]; an admin approves them in HPark Command
/// before they can operate.
class Officer {
  const Officer({
    required this.id,
    required this.fullName,
    required this.nationalId,
    required this.phone,
    required this.dateOfBirth,
    required this.badgeNumber,
    required this.status,
    required this.appliedAt,
    this.assignedDistrictId,
    this.approvedAt,
    this.approvedBy,
    this.reviewNote,
    this.citationsIssued = 0,
    this.photoUrl,
  });

  final String id; // e.g. OFR-118
  final String fullName;
  final String nationalId; // Somaliland national ID number
  final String phone;
  final DateTime dateOfBirth;
  final String badgeNumber; // e.g. HG-OFR-118
  final ApprovalStatus status;
  final DateTime appliedAt;

  final String? assignedDistrictId;
  final DateTime? approvedAt;
  final String? approvedBy; // admin id/name who actioned the decision
  final String? reviewNote; // optional reason, esp. for rejection
  final int citationsIssued;
  final String? photoUrl;

  bool get canUseOfficerApp => status.canUseOfficerApp;

  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// Firestore-agnostic serialization (dates as epoch millis, enums by name).
  /// The Firebase layer maps these to/from document data.
  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'nationalId': nationalId,
        'phone': phone,
        'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
        'badgeNumber': badgeNumber,
        'status': status.name,
        'appliedAt': appliedAt.millisecondsSinceEpoch,
        'assignedDistrictId': assignedDistrictId,
        'approvedAt': approvedAt?.millisecondsSinceEpoch,
        'approvedBy': approvedBy,
        'reviewNote': reviewNote,
        'citationsIssued': citationsIssued,
        'photoUrl': photoUrl,
      };

  static Officer fromMap(Map<String, dynamic> map) {
    DateTime? ms(Object? v) =>
        v == null ? null : DateTime.fromMillisecondsSinceEpoch((v as num).toInt());
    return Officer(
      id: map['id'] as String,
      fullName: map['fullName'] as String? ?? '',
      nationalId: map['nationalId'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      dateOfBirth: ms(map['dateOfBirth']) ?? DateTime(1990),
      badgeNumber: map['badgeNumber'] as String? ?? '',
      status: ApprovalStatus.values.byName(map['status'] as String? ?? 'pending'),
      appliedAt: ms(map['appliedAt']) ?? DateTime.now(),
      assignedDistrictId: map['assignedDistrictId'] as String?,
      approvedAt: ms(map['approvedAt']),
      approvedBy: map['approvedBy'] as String?,
      reviewNote: map['reviewNote'] as String?,
      citationsIssued: (map['citationsIssued'] as num?)?.toInt() ?? 0,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Officer copyWith({
    ApprovalStatus? status,
    String? assignedDistrictId,
    DateTime? approvedAt,
    String? approvedBy,
    String? reviewNote,
    int? citationsIssued,
  }) {
    return Officer(
      id: id,
      fullName: fullName,
      nationalId: nationalId,
      phone: phone,
      dateOfBirth: dateOfBirth,
      badgeNumber: badgeNumber,
      status: status ?? this.status,
      appliedAt: appliedAt,
      assignedDistrictId: assignedDistrictId ?? this.assignedDistrictId,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      reviewNote: reviewNote ?? this.reviewNote,
      citationsIssued: citationsIssued ?? this.citationsIssued,
      photoUrl: photoUrl,
    );
  }
}
