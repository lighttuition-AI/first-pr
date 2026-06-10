import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
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
    final myRows = Seed.league.where((r) => r.id == me.id);
    final rank = myRows.isEmpty ? null : myRows.first;

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
            country: me.country,
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
                        Text(rank == null ? '—' : ordinal(rank.pos), style: FCType.mono(size: 17, weight: FontWeight.w700)),
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
                            Text('${rank?.pts ?? 0}', style: FCType.mono(size: 17, weight: FontWeight.w700)),
                            Text(' pts', style: FCType.body(size: 11, color: FC.textMuted)),
                          ],
                        ),
                        Text(rank == null ? 'New player' : rank.form.join(' '), style: FCType.body(size: 11, color: FC.text2, height: 1.1)),
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

/// Home "Upcoming matches" — four fixed boxes: Premier League, Champions League,
/// World Cup, and New challenges (friendly duels from the Arena). Each is empty
/// by default and fills with live data once a season starts or a challenge locks.
class _UpcomingMatches extends StatelessWidget {
  const _UpcomingMatches();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser;

    // The player's own competition fixtures, grouped by competition.
    final byComp = <String, List<({String opp, String meta, String? status})>>{};
    for (final fx in Seed.fixtures) {
      if (fx.a != me.id && fx.b != me.id) continue;
      final oppId = fx.a == me.id ? fx.b : fx.a;
      (byComp[fx.comp] ??= []).add((opp: Seed.byId(oppId).short, meta: fx.when, status: fx.status));
    }
    List<({String opp, String meta, String? status})> forComp(String c) => byComp[c] ?? const [];
    final friendly = [
      for (final c in app.activeChallenges)
        (opp: Seed.byId(c['opp'] as String).short, meta: c['when'] as String, status: c['status'] as String?),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Upcoming matches'),
        _box('Premier League', forComp('Premier League')),
        _box('Champions League', forComp('Champions League')),
        _box('World Cup', forComp('World Cup')),
        _box('New challenges', friendly),
      ],
    );
  }

  Widget _box(String name, List<({String opp, String meta, String? status})> items) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Eyebrow(name, color: FC.purple300),
                const SizedBox(width: 8),
                if (items.isNotEmpty) Text('${items.length}', style: FCType.mono(size: 11, color: FC.textMuted)),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Surface(
                child: Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 18, color: FC.textMuted),
                    const SizedBox(width: 11),
                    Text('Nothing scheduled yet', style: FCType.body(size: 12.5, color: FC.text2)),
                  ],
                ),
              )
            else
              for (final m in items) ...[_matchRow(m.opp, m.meta, m.status), const SizedBox(height: 8)],
          ],
        ),
      );

  Widget _matchRow(String opp, String meta, String? status) {
    final initials = opp.split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join();
    return Surface(
      child: Row(
        children: [
          AvatarInitials(initials: initials.isEmpty ? '?' : initials, size: 36, name: opp),
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
          if (status != null) ...[const SizedBox(width: 8), StatusPill(status)],
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
      if (app.isAdmin) ('Control', LucideIcons.shield, () => app.setTab(5)),
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
