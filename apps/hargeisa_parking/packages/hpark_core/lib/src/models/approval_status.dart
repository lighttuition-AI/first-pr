import 'package:flutter/widgets.dart';

import '../theme/hp_colors.dart';

/// Lifecycle of an officer account. An officer can only sign in to HPark Enforce
/// once an admin has moved them to [approved] in HPark Command — this is the gate
/// that keeps unauthorized people from operating as officers.
enum ApprovalStatus {
  /// Self-registered, waiting for an admin to review.
  pending,

  /// Reviewed and cleared by an admin — may use the officer app.
  approved,

  /// Reviewed and denied — cannot use the officer app.
  rejected,

  /// Previously approved, access temporarily revoked by an admin.
  suspended;

  bool get canUseOfficerApp => this == ApprovalStatus.approved;

  String get label => switch (this) {
        ApprovalStatus.pending => 'Pending review',
        ApprovalStatus.approved => 'Approved',
        ApprovalStatus.rejected => 'Rejected',
        ApprovalStatus.suspended => 'Suspended',
      };

  /// Leading status glyph, per the design system's status language (no emoji).
  String get glyph => switch (this) {
        ApprovalStatus.pending => '◌',
        ApprovalStatus.approved => '✓',
        ApprovalStatus.rejected => '✕',
        ApprovalStatus.suspended => '▲',
      };

  Color get color => switch (this) {
        ApprovalStatus.pending => HpColors.warning,
        ApprovalStatus.approved => HpColors.success,
        ApprovalStatus.rejected => HpColors.danger,
        ApprovalStatus.suspended => HpColors.textMuted,
      };

  Color get tint => switch (this) {
        ApprovalStatus.pending => HpColors.warningTint,
        ApprovalStatus.approved => HpColors.successTint,
        ApprovalStatus.rejected => HpColors.dangerTint,
        ApprovalStatus.suspended => HpColors.overlay,
      };
}
