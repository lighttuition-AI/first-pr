// Brand wordmark + the shared setup/onboarding header bar.
import 'package:flutter/material.dart';

import '../models/content.dart';
import '../theme/tokens.dart';
import 'common.dart';
import 'kid_button.dart';
import 'planet.dart';

class Logo extends StatelessWidget {
  final bool small;
  const Logo({super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    final mark = small ? 34.0 : 44.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Planet(data: kPlanets[2], size: mark),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            style: AppText.display(size: small ? 30 : 40, weight: FontWeight.w800),
            children: [
              const TextSpan(text: 'HNL'),
              TextSpan(
                text: ' Learning',
                style: AppText.display(
                  size: small ? 26 : 34,
                  weight: FontWeight.w600,
                  color: C.inkSoft,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SetupHeader extends StatelessWidget {
  final int index;
  final int total;
  final VoidCallback? onBack;
  const SetupHeader({super.key, required this.index, required this.total, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
      child: Row(
        children: [
          if (onBack != null)
            IconCircle(Icons.arrow_back_rounded, onTap: onBack)
          else
            const SizedBox(width: kTap),
          const Spacer(),
          const Logo(small: true),
          const Spacer(),
          SizedBox(
            width: kTap,
            child: total > 0
                ? Align(
                    alignment: Alignment.centerRight,
                    child: ProgressDots(total: total, index: index),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
