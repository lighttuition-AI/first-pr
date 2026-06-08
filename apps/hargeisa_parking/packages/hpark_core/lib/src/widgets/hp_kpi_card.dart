import 'package:flutter/material.dart';

import '../theme/hp_colors.dart';
import '../theme/hp_spacing.dart';
import '../theme/hp_typography.dart';
import 'hp_card.dart';

/// Dashboard metric tile — uppercase eyebrow label, big mono value, optional
/// delta chip. For KPIs like Revenue Today, Compliance Rate, Active Officers.
class HpKpiCard extends StatelessWidget {
  const HpKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaUp = true,
    this.icon,
    this.accent = HpColors.purple,
  });

  final String label;
  final String value;
  final String? delta;
  final bool deltaUp;
  final IconData? icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final deltaColor = deltaUp ? HpColors.success : HpColors.danger;
    return HpCard(
      padding: const EdgeInsets.all(HpSpace.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(label.toUpperCase(), style: HpType.eyebrow)),
              if (icon != null) Icon(icon, size: 18, color: accent),
            ],
          ),
          const SizedBox(height: HpSpace.x3),
          Text(value, style: HpType.mono(size: 28, weight: FontWeight.w700)),
          if (delta != null) ...[
            const SizedBox(height: HpSpace.x2),
            Row(
              children: [
                Icon(
                  deltaUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 14,
                  color: deltaColor,
                ),
                const SizedBox(width: 3),
                Text(
                  delta!,
                  style: HpType.body(size: 13, weight: FontWeight.w600, color: deltaColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
