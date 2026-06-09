import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../data/competitions.dart';
import '../data/seed_data.dart';
import '../models/competition.dart';
import '../flows/admin_login.dart';
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
            // Admin lock — players see a plain lock to sign in; admins see a lit
            // shield that signs out. This is the only entry to the admin tabs.
            _HeaderIcon(
              icon: app.isAdmin ? LucideIcons.shieldCheck : LucideIcons.lock,
              active: app.isAdmin,
              onTap: () => app.isAdmin ? showAdminLogout(context) : showAdminLogin(context),
            ),
            const SizedBox(width: 10),
            _HeaderIcon(
              icon: LucideIcons.bell,
              showDot: unread > 0,
              onTap: () => showNotificationsSheet(context),
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

        // invitations — accept moves them to Upcoming matches; ✕ declines.
        if (app.invites.isNotEmpty) ...[
          const SectionTitle('Challenge invitations'),
          const SizedBox(height: 8),
          for (final inv in app.invites) ...[
            Builder(builder: (context) {
              final f = Seed.byId(inv.from);
              return Surface(
                child: Row(
                  children: [
                    AvatarInitials(initials: f.initials, size: 38, photo: f.photo),
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
                    GButton('Accept', size: 'sm', variant: GBtn.teal, onTap: () {
                      context.read<AppState>().acceptInvite(inv);
                      flashToast(context, '${f.short} added to upcoming matches');
                    }),
                    const SizedBox(width: 8),
                    GButton('✕', size: 'sm', variant: GBtn.ghost, onTap: () {
                      context.read<AppState>().declineInvite(inv);
                      flashToast(context, 'Declined ${f.short}');
                    }),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
        ],

        // upcoming matches — grouped by competition
        const _UpcomingMatches(),
        const SizedBox(height: 18),

        // quick actions
        const SectionTitle('Quick actions'),
        const SizedBox(height: 8),
        _QuickGrid(),
      ],
    );
  }
}

/// Upcoming matches grouped by competition (Premier League · Champions League ·
/// World Cup) plus accepted Friendly challenges. Only non-empty groups show.
class _UpcomingMatches extends StatelessWidget {
  const _UpcomingMatches();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser;

    // Premier League — the player's own scheduled/locked fixtures.
    final pl = [
      for (final fx in Seed.fixtures)
        if (fx.a == me.id || fx.b == me.id)
          (opp: Seed.byId(fx.a == me.id ? fx.b : fx.a).short, meta: fx.when, status: fx.status),
    ];

    // Cup ties involving the player that haven't been played yet.
    List<({String opp, String meta, String status})> cup(Competition c) {
      final out = <({String opp, String meta, String status})>[];
      for (final t in c.bracket) {
        final isA = t.a?.name == me.short, isB = t.b?.name == me.short;
        if ((!isA && !isB) || t.status == 'confirmed') continue;
        out.add((opp: (isA ? t.b?.name : t.a?.name) ?? 'TBD', meta: t.round, status: t.status));
      }
      return out;
    }

    final ucl = cup(Comps.championsLeague);
    final wc = cup(Comps.worldCup);

    // Accepted invitations become upcoming friendlies.
    final friendly = [
      for (final inv in app.acceptedFriendlies)
        (opp: Seed.byId(inv.from).short, meta: inv.when, status: 'locked'),
    ];

    final groups = <(String, List<({String opp, String meta, String status})>)>[
      ('Premier League', pl),
      ('Champions League', ucl),
      ('World Cup', wc),
      ('Friendly challenges', friendly),
    ].where((g) => g.$2.isNotEmpty).toList();

    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Upcoming matches'),
        for (final g in groups) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Eyebrow(g.$1, color: FC.purple300),
              const SizedBox(width: 8),
              Text('${g.$2.length}', style: FCType.mono(size: 11, color: FC.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          for (final m in g.$2) ...[
            _matchRow(m.opp, m.meta, m.status),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }

  Widget _matchRow(String opp, String meta, String status) {
    final initials = opp.split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join();
    return Surface(
      child: Row(
        children: [
          AvatarInitials(initials: initials.isEmpty ? '?' : initials, size: 36),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('vs $opp', style: FCType.body(size: 13.5, weight: FontWeight.w600, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(meta, style: FCType.mono(size: 11, color: FC.text2)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(status),
        ],
      ),
    );
  }
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

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;
  final bool active;
  const _HeaderIcon({required this.icon, required this.onTap, this.showDot = false, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? FC.purpleTint : FC.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? const Color(0x737C6CF8) : FC.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: active ? FC.purple300 : FC.text),
            if (showDot) const Positioned(top: 8, right: 9, child: _Dot()),
          ],
        ),
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = <(String, IconData, VoidCallback)>[
      ('Challenge pool', LucideIcons.swords, () => app.setTab(1)),
      ('My cards', LucideIcons.layers, () => app.setTab(3)),
      ('Standings', LucideIcons.listOrdered, () { app.setCompetition('pl'); app.setTab(2, leagueSubTab: 'table'); }),
      ('Fixtures', LucideIcons.calendar, () { app.setCompetition('pl'); app.setTab(2, leagueSubTab: 'fixtures'); }),
      // Admin-only shortcuts map to the Roster/Admin tabs (indices 4/5); players
      // get player-relevant actions instead.
      if (app.isAdmin) ('Roster', LucideIcons.clipboardList, () => app.setTab(4)),
      if (app.isAdmin) ('Admin panel', LucideIcons.shield, () => app.setTab(5)),
      if (!app.isAdmin) ('Results', LucideIcons.flag, () { app.setCompetition('pl'); app.setTab(2, leagueSubTab: 'results'); }),
      if (!app.isAdmin) ('Alerts', LucideIcons.bell, () => showNotificationsSheet(context)),
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
