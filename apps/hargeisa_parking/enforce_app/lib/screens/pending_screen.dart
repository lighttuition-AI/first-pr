import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import '../widgets/auth_scaffold.dart';

/// Shown whenever a signed-in officer is not [ApprovalStatus.approved].
/// This is the visible half of the approval gate — the officer cannot reach any
/// enforcement feature until an admin clears them in HPark Command. The record is
/// watched live, so this screen unlocks the moment an admin approves.
class PendingScreen extends StatelessWidget {
  const PendingScreen({
    super.key,
    required this.officer,
    required this.onSignOut,
  });

  final Officer officer;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final status = officer.status;
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: status.tint,
                borderRadius: BorderRadius.circular(HpRadius.xl),
              ),
              child: Icon(_icon(status), color: status.color, size: 34),
            ),
          ),
          const SizedBox(height: HpSpace.x5),
          Center(child: HpBadge.status(status)),
          const SizedBox(height: HpSpace.x4),
          Text(_title(status), textAlign: TextAlign.center, style: HpType.heading(size: 24)),
          const SizedBox(height: HpSpace.x3),
          Text(_message(status), textAlign: TextAlign.center, style: HpType.body(size: 14.5)),
          const SizedBox(height: HpSpace.x6),
          HpCard(
            child: Column(
              children: [
                _row('Name', officer.fullName),
                const Divider(height: HpSpace.x6),
                _row('National ID', officer.nationalId, mono: true),
                const Divider(height: HpSpace.x6),
                _row('Badge', officer.badgeNumber, mono: true),
              ],
            ),
          ),
          if (officer.reviewNote != null && officer.reviewNote!.isNotEmpty) ...[
            const SizedBox(height: HpSpace.x4),
            HpCard(
              borderColor: HpColors.danger.withValues(alpha: 0.35),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 18, color: HpColors.danger),
                  const SizedBox(width: HpSpace.x3),
                  Expanded(
                    child: Text('Reason: ${officer.reviewNote}',
                        style: HpType.body(size: 13.5, color: HpColors.text2)),
                  ),
                ],
              ),
            ),
          ],
          if (status == ApprovalStatus.pending) ...[
            const SizedBox(height: HpSpace.x5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: HpColors.warning),
                ),
                const SizedBox(width: HpSpace.x3),
                Text('Waiting for an admin to approve…',
                    style: HpType.body(size: 12.5, color: HpColors.textMuted)),
              ],
            ),
          ],
          const SizedBox(height: HpSpace.x6),
          TextButton(
            onPressed: onSignOut,
            child: Text('Sign out',
                style: HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.text2)),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool mono = false}) {
    return Row(
      children: [
        Text(label, style: HpType.body(size: 13.5, color: HpColors.textMuted)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: mono
                ? HpType.mono(size: 14, color: HpColors.text)
                : HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.text),
          ),
        ),
      ],
    );
  }

  IconData _icon(ApprovalStatus s) => switch (s) {
        ApprovalStatus.pending => Icons.hourglass_top_rounded,
        ApprovalStatus.rejected => Icons.block_rounded,
        ApprovalStatus.suspended => Icons.pause_circle_outline_rounded,
        ApprovalStatus.approved => Icons.check_rounded,
      };

  String _title(ApprovalStatus s) => switch (s) {
        ApprovalStatus.pending => 'Waiting for approval',
        ApprovalStatus.rejected => 'Application rejected',
        ApprovalStatus.suspended => 'Access suspended',
        ApprovalStatus.approved => 'Approved',
      };

  String _message(ApprovalStatus s) => switch (s) {
        ApprovalStatus.pending =>
          'Your registration was received. An administrator is verifying your identity. '
              'You\'ll get access the moment you\'re approved.',
        ApprovalStatus.rejected =>
          'Your request to operate as an officer was not approved. Contact your '
              'supervisor if you believe this is a mistake.',
        ApprovalStatus.suspended =>
          'Your officer access has been temporarily paused by an administrator.',
        ApprovalStatus.approved => 'You\'re all set.',
      };
}
