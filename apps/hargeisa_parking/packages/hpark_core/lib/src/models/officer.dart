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
