/// A citation issued during the current shift. When the officer is offline it is
/// created with [synced] = false and queued; it flips to synced when back online.
class IssuedCitation {
  IssuedCitation({
    required this.id,
    required this.plate,
    required this.violation,
    required this.fine,
    required this.issuedAt,
    required this.gps,
    required this.photoCount,
    required this.hasVideo,
    required this.synced,
  });

  final String id; // CIT-2026-04822
  final String plate;
  final String violation;
  final int fine; // SLSH
  final DateTime issuedAt;
  final String gps; // "9.5621° N, 44.0650° E"
  final int photoCount;
  final bool hasVideo;
  bool synced;
}
