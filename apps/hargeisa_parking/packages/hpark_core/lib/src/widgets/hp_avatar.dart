import 'package:flutter/material.dart';

import '../theme/hp_colors.dart';
import '../theme/hp_typography.dart';

/// Circular identity token — initials on a purple tint, optional status dot.
class HpAvatar extends StatelessWidget {
  const HpAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.statusColor,
  });

  final String initials;
  final double size;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: HpColors.purpleTint,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: HpType.heading(
                size: size * 0.36,
                color: HpColors.purple300,
              ),
            ),
          ),
          if (statusColor != null)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: HpColors.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
