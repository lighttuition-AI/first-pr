import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../flows/card_detail.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = Seed.me;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Your career', color: FC.teal),
        const SizedBox(height: 2),
        Text('Card collection', style: FCType.heading(size: 23, weight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('${Seed.collection.length} cards earned across competitions', style: FCType.body(size: 12, color: FC.text2)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.52,
          children: [
            for (final c in Seed.collection)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: FCCard(
                      variant: c.variant,
                      tier: c.tier,
                      rating: c.rating,
                      name: me.name,
                      pos: me.pos,
                      psn: me.psn,
                      stats: c.stats,
                      flagBands: Seed.flagOf('NL'),
                      width: 142,
                      shine: c.variant != 'mono',
                      onTap: () => showCardDetail(context, c),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.comp, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.body(size: 12, weight: FontWeight.w600, height: 1.2)),
                        Text('${c.season} · ${c.label}', style: FCType.mono(size: 10.5, color: FC.text2)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
