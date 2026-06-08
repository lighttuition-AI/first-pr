import 'package:flutter/material.dart';

import '../models/approval_status.dart';
import '../theme/hp_spacing.dart';

/// Small status pill — tinted fill + leading geometric glyph (no emoji).
class HpBadge extends StatelessWidget {
  const HpBadge({
    super.key,
    required this.label,
    required this.color,
    required this.tint,
    this.glyph,
  });

  /// Builds a badge directly from an [ApprovalStatus].
  HpBadge.status(ApprovalStatus status, {Key? key})
      : this(
          key: key,
          label: status.label,
          color: status.color,
          tint: status.tint,
          glyph: status.glyph,
        );

  final String label;
  final Color color;
  final Color tint;
  final String? glyph;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3, vertical: 5),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(HpRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (glyph != null) ...[
            Text(glyph!, style: TextStyle(color: color, fontSize: 11, height: 1)),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
