import 'package:flutter/material.dart';

import '../theme/hp_colors.dart';

/// The Hargeisa Parking logomark — a rounded-square "P" in the brand gradient
/// on the dark surface. Mirrors `assets/logo-mark.svg`.
class HpLogoMark extends StatelessWidget {
  const HpLogoMark({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.25;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.04),
      decoration: BoxDecoration(
        gradient: HpColors.gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: HpColors.surface,
          borderRadius: BorderRadius.circular(radius - 1),
        ),
        alignment: Alignment.center,
        child: ShaderMask(
          shaderCallback: (bounds) => HpColors.gradient.createShader(bounds),
          child: Text(
            'P',
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand wordmark — the logomark beside the two-line "Hargeisa / Parking" name.
class HpWordmark extends StatelessWidget {
  const HpWordmark({super.key, this.markSize = 42});

  final double markSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HpLogoMark(size: markSize),
        const SizedBox(width: 13),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hargeisa',
              style: TextStyle(
                color: HpColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.05,
              ),
            ),
            Text(
              'Parking',
              style: TextStyle(
                color: HpColors.text2,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.05,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
