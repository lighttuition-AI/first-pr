import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../flows/photo_viewer.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';

/// One card per competition, kept up to date with the player's progress:
/// Premier League · Champions League · World Cup · Friendly challenges.
/// The Friendly card reflects the persisted record (ranked by games played).
class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser;

    final friendlyLine = app.friendlyPlayed == 0
        ? 'No matches yet'
        : 'Played ${app.friendlyPlayed} · ${app.friendlyWon}W ${app.friendlyDrawn}D ${app.friendlyLost}L';

    // No games played yet → competition cards read "not started" until the
    // season begins; the Friendly card tracks the live record.
    final cards = <({String comp, String variant, String progress})>[
      (comp: 'Premier League', variant: 'neon', progress: 'Season hasn’t started'),
      (comp: 'Champions League', variant: 'holo', progress: 'Not started yet'),
      (comp: 'World Cup', variant: 'neon', progress: 'Not started yet'),
      (comp: 'Friendly challenges', variant: 'mono', progress: friendlyLine),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Your career', color: FC.teal),
        const SizedBox(height: 2),
        Text('Card collection', style: FCType.heading(size: 23, weight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('One card per competition · updated as you play', style: FCType.body(size: 12, color: FC.text2)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.52,
          children: [
            for (final c in cards)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: FCCard(
                      variant: c.variant,
                      rating: me.rating,
                      name: me.name,
                      pos: me.pos,
                      psn: me.psn,
                      stats: me.stats,
                      photo: me.photo,
                      country: me.country,
                      flagBands: Seed.flagOf(me.country),
                      width: 142,
                      shine: c.variant != 'mono',
                      onTap: () => showAvatarViewer(context, photo: me.photo, initials: me.initials, name: me.short),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.comp, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.body(size: 12, weight: FontWeight.w600, height: 1.2)),
                        Text(c.progress, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.mono(size: 10.5, color: FC.text2)),
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
