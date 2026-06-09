import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../flows/challenge_flow.dart';
import '../flows/notifications_sheet.dart';
import '../flows/profile_sheet.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser;
    final unread = Seed.notifs.where((n) => n.unread).length;
    final rank = Seed.league.firstWhere((r) => r.id == 'p01');
    final nextFix = Seed.fixtures.first;
    final opp = Seed.byId(nextFix.b);

    String ordinal(int n) => n == 1 ? '1st' : n == 2 ? '2nd' : n == 3 ? '3rd' : '${n}th';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Welcome back'),
                  const SizedBox(height: 2),
                  Text(me.short, style: FCType.heading(size: 23, weight: FontWeight.w800)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => showNotificationsSheet(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FC.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FC.border),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(LucideIcons.bell, size: 20, color: FC.text),
                    if (unread > 0)
                      const Positioned(
                        top: 8,
                        right: 9,
                        child: _Dot(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // current card
        Center(
          child: FCCard(
            variant: me.variant,
            tier: me.tier,
            rating: me.rating,
            name: me.name,
            pos: me.pos,
            psn: me.psn,
            stats: me.stats,
            photo: me.photo,
            flagBands: Seed.flagOf(me.country),
            width: 232,
            onTap: () => showProfileSheet(context, me, (p) => context.read<AppState>().setPhoto(p)),
          ),
        ),
        const SizedBox(height: 18),

        // two stat tiles
        Row(
          children: [
            Expanded(
              child: Surface(
                pad: 13,
                child: Row(
                  children: [
                    const Icon(LucideIcons.trophy, size: 18, color: FC.warning),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ordinal(rank.pos), style: FCType.mono(size: 17, weight: FontWeight.w700)),
                        Text('League rank', style: FCType.body(size: 11, color: FC.text2, height: 1.1)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Surface(
                pad: 13,
                child: Row(
                  children: [
                    const Icon(LucideIcons.zap, size: 18, color: FC.teal),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${rank.pts}', style: FCType.mono(size: 17, weight: FontWeight.w700)),
                            Text(' pts', style: FCType.body(size: 11, color: FC.textMuted)),
                          ],
                        ),
                        Text(rank.form.join(' '), style: FCType.body(size: 11, color: FC.text2, height: 1.1)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // upcoming match
        const SectionTitle('Upcoming match'),
        const SizedBox(height: 8),
        Surface(
          glow: true,
          borderColor: const Color(0x4D00D8D6),
          child: Row(
            children: [
              _vsName(me.short.split(' ').first, '${me.rating}'),
              Expanded(
                child: Column(
                  children: [
                    Text('VS', style: FCType.mono(size: 14, weight: FontWeight.w800, color: FC.teal)),
                    const SizedBox(height: 2),
                    Text(nextFix.when, style: FCType.body(size: 11, color: FC.text2)),
                    const SizedBox(height: 6),
                    const StatusPill('locked'),
                  ],
                ),
              ),
              _vsName(opp.short.split(' ').first, '${opp.rating}'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // invitations
        const SectionTitle('Challenge invitations'),
        const SizedBox(height: 8),
        for (final inv in Seed.invites) ...[
          Builder(builder: (context) {
            final f = Seed.byId(inv.from);
            return Surface(
              child: Row(
                children: [
                  AvatarInitials(initials: f.initials, size: 38),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.short, style: FCType.body(size: 13.5, weight: FontWeight.w600, height: 1.2)),
                        Text('${inv.mode} · ${inv.when}', style: FCType.mono(size: 11, color: FC.text2)),
                      ],
                    ),
                  ),
                  GButton('Accept', size: 'sm', variant: GBtn.teal, onTap: () => showChallengeFlow(context, preset: f, presetSlot: inv.when, autoLock: true)),
                  const SizedBox(width: 8),
                  GButton('✕', size: 'sm', variant: GBtn.ghost, onTap: () {}),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 10),

        // quick actions
        const SectionTitle('Quick actions'),
        const SizedBox(height: 8),
        _QuickGrid(),
      ],
    );
  }

  Widget _vsName(String name, String rating) => SizedBox(
        width: 52,
        child: Column(
          children: [
            Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.heading(size: 15, weight: FontWeight.w800)),
            Text(rating, style: FCType.mono(size: 11, color: FC.purple300)),
          ],
        ),
      );
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: FC.danger, shape: BoxShape.circle, boxShadow: [BoxShadow(color: FC.danger, blurRadius: 6)]),
      );
}

class _QuickGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final items = <(String, IconData, VoidCallback)>[
      ('Challenge pool', LucideIcons.swords, () => app.setTab(1)),
      ('My cards', LucideIcons.layers, () => app.setTab(3)),
      ('Standings', LucideIcons.listOrdered, () { app.setCompetition('pl'); app.setTab(2, leagueSubTab: 'table'); }),
      ('Fixtures', LucideIcons.calendar, () { app.setCompetition('pl'); app.setTab(2, leagueSubTab: 'fixtures'); }),
      ('Roster', LucideIcons.clipboardList, () => app.setTab(4)),
      ('Admin panel', LucideIcons.shield, () => app.setTab(5)),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.92,
      children: [
        for (final it in items)
          GestureDetector(
            onTap: it.$3,
            child: Container(
              decoration: BoxDecoration(
                color: FC.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: FC.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: FC.purpleTint, borderRadius: BorderRadius.circular(11)),
                    child: Icon(it.$2, size: 19, color: FC.purple300),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(it.$1, textAlign: TextAlign.center, style: FCType.body(size: 11.5, weight: FontWeight.w600, height: 1.2)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
