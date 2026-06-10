import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../flows/broadcast.dart';
import '../flows/new_season.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late List<PendingReg> _reg = List.of(Seed.pendingReg);
  late List<Dispute> _disputes = List.of(Seed.disputes);
  String _tab = 'queue';
  bool _running = true;
  final Map<String, int> _gen = {}; // compId → 0 idle · 1 generating · 2 done

  void _decide(String id) => setState(() => _reg = _reg.where((x) => x.id != id).toList());

  void _resolveDispute(String id, String msg) {
    setState(() => _disputes = _disputes.where((d) => d.id != id).toList());
    flashToast(context, msg);
  }

  void _newSeason(String compId, String compName) {
    final app = context.read<AppState>();
    final entrants = app.rosterFor(compId).map(Seed.byId).toList();
    showNewSeasonSheet(
      context,
      compName: compName,
      entrants: entrants,
      onConfirm: (winnerId) {
        app.startNewSeason(compId, compName, winnerId: winnerId);
        flashToast(context, winnerId == null ? '$compName · new season started' : '$compName champion crowned 🏆');
      },
    );
  }

  void _generate(String compId, String doneMsg) {
    if (_gen[compId] == 1) return;
    setState(() => _gen[compId] = 1);
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _gen[compId] = 2);
      flashToast(context, doneMsg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final kpis = <(String, String, IconData)>[
      ('Players', '38', LucideIcons.users),
      ('Pending', '${_reg.length}', LucideIcons.userPlus),
      ('Disputes', '${_disputes.length}', LucideIcons.alertTriangle),
      ('Today', '6', LucideIcons.calendar),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Control room', color: FC.warning),
                  const SizedBox(height: 2),
                  Text('Operations', style: FCType.heading(size: 23, weight: FontWeight.w800)),
                ],
              ),
            ),
            Pill(_running ? 'Live' : 'Paused', glyph: '●', tone: _running ? PillTone.success : PillTone.warning),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.7,
          children: [
            for (final k in kpis)
              Surface(
                pad: 13,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(10)),
                      child: Icon(k.$3, size: 18, color: FC.purple300),
                    ),
                    const SizedBox(width: 11),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(k.$2, style: FCType.mono(size: 20, weight: FontWeight.w700, height: 1)),
                        const SizedBox(height: 3),
                        Text(k.$1, style: FCType.body(size: 11, color: FC.text2, height: 1)),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Segmented(
          tabs: const [MapEntry('queue', 'Approvals'), MapEntry('disputes', 'Disputes'), MapEntry('season', 'Season')],
          value: _tab,
          onChange: (v) => setState(() => _tab = v),
        ),
        const SizedBox(height: 16),
        if (_tab == 'queue') _approvals(),
        if (_tab == 'disputes') _disputesView(),
        if (_tab == 'season') _seasonView(),
      ],
    );
  }

  Widget _approvals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Pending registrations'),
        const SizedBox(height: 9),
        if (_reg.isEmpty)
          Surface(child: Center(child: Text('Queue clear · all approved', style: FCType.body(size: 13, color: FC.text2)))),
        for (final r in _reg) ...[
          Surface(
            child: Row(
              children: [
                AvatarInitials(initials: r.initials, size: 38),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: FCType.body(size: 13.5, weight: FontWeight.w600, height: 1.2)),
                      Text('PSN ${r.psn} · ${r.when}', style: FCType.mono(size: 11, color: FC.text2)),
                    ],
                  ),
                ),
                GButton('✓', size: 'sm', variant: GBtn.teal, onTap: () {
                  _decide(r.id);
                  flashToast(context, '${r.name} approved');
                }),
                const SizedBox(width: 8),
                GButton('✕', size: 'sm', variant: GBtn.ghost, onTap: () {
                  _decide(r.id);
                  flashToast(context, '${r.name} rejected');
                }),
              ],
            ),
          ),
          const SizedBox(height: 9),
        ],
      ],
    );
  }

  Widget _disputesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Disputed results'),
        const SizedBox(height: 9),
        if (_disputes.isEmpty)
          Surface(child: Center(child: Text('No open disputes · all resolved', style: FCType.body(size: 13, color: FC.text2)))),
        for (final d in _disputes) ...[
          Builder(builder: (context) {
            final a = Seed.byId(d.a), b = Seed.byId(d.b);
            return Surface(
              borderColor: const Color(0x4DFF5252),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const StatusPill('disputed'),
                      Text(d.when, style: FCType.mono(size: 11, color: FC.text2)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _claim(a.short, d.claimA)),
                      const SizedBox(width: 8),
                      Expanded(child: _claim(b.short, d.claimB)),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(child: GButton('Uphold ${a.short.split(' ').first}', size: 'sm', variant: GBtn.secondary, full: true, onTap: () => _resolveDispute(d.id, 'Upheld: ${a.short} 3–0'))),
                      const SizedBox(width: 8),
                      Expanded(child: GButton('Replay', size: 'sm', variant: GBtn.secondary, full: true, onTap: () => _resolveDispute(d.id, 'Match set to replay'))),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 9),
        ],
      ],
    );
  }

  Widget _claim(String name, String claim) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: FC.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: FC.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: FCType.body(size: 12.5, weight: FontWeight.w600, height: 1.2)),
            const SizedBox(height: 3),
            Text('Claims $claim', style: FCType.mono(size: 11, color: FC.text2)),
          ],
        ),
      );

  Widget _seasonView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Generate competitions'),
        const SizedBox(height: 9),
        _generateCard('pl', 'Premier League', '38 approved players · 38 rounds', 'Premier League fixtures generated · 38 rounds'),
        const SizedBox(height: 11),
        _generateCard('ucl', 'Champions League', '16 teams · 4 groups + knockout', 'Champions League drawn · 4 groups + bracket'),
        const SizedBox(height: 11),
        _generateCard('wc', 'World Cup', '16 teams · 4 groups + knockout', 'World Cup drawn · 4 groups + bracket'),
        const SizedBox(height: 16),
        const SectionTitle('Reset / new season'),
        const SizedBox(height: 9),
        _seasonRow(LucideIcons.trophy, FC.warning, 'Premier League', 'Crown champion · clear & restart', 'New season', () => _newSeason('pl', 'Premier League')),
        const SizedBox(height: 11),
        _seasonRow(LucideIcons.trophy, FC.warning, 'Champions League', 'Crown champion · clear & restart', 'New season', () => _newSeason('ucl', 'Champions League')),
        const SizedBox(height: 11),
        _seasonRow(LucideIcons.trophy, FC.warning, 'World Cup', 'Crown champion · clear & restart', 'New season', () => _newSeason('wc', 'World Cup')),
        const SizedBox(height: 16),
        const SectionTitle('Season controls'),
        const SizedBox(height: 9),
        _seasonRow(LucideIcons.pause, FC.warning, 'Season state', 'Pause or resume all fixtures', _running ? 'Pause' : 'Resume', () {
          setState(() => _running = !_running);
          flashToast(context, _running ? 'Season resumed' : 'Season paused');
        }),
        const SizedBox(height: 11),
        _seasonRow(LucideIcons.megaphone, FC.purple300, 'Broadcast', 'Write a message · players get a popup', 'Compose',
            () => showBroadcastCompose(context, (msg) => context.read<AppState>().pushBroadcast(msg))),
        const SizedBox(height: 11),
        _seasonRow(LucideIcons.award, FC.warning, 'Trigger card update', 'Re-issue cards after milestone', 'Run', () => flashToast(context, 'Card update queued for 38 players')),
      ],
    );
  }

  Widget _generateCard(String compId, String name, String sub, String doneMsg) {
    final state = _gen[compId] ?? 0;
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.shuffle, size: 18, color: FC.teal),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: FCType.body(size: 14, weight: FontWeight.w700)),
                    Text(sub, style: FCType.body(size: 11.5, color: FC.text2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (state == 1)
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: const LinearProgressIndicator(minHeight: 5, backgroundColor: FC.overlay, valueColor: AlwaysStoppedAnimation(FC.purple)),
            )
          else
            GButton(
              state == 2 ? 'Fixtures generated' : 'Generate fixtures',
              full: true,
              size: 'md',
              variant: state == 2 ? GBtn.secondary : GBtn.primary,
              icon: state == 2 ? LucideIcons.check : LucideIcons.shuffle,
              onTap: () => _generate(compId, doneMsg),
            ),
        ],
      ),
    );
  }

  Widget _seasonRow(IconData ic, Color icColor, String title, String sub, String action, VoidCallback onTap) {
    return Surface(
      child: Row(
        children: [
          Icon(ic, size: 18, color: icColor),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: FCType.body(size: 14, weight: FontWeight.w700)),
                Text(sub, style: FCType.body(size: 11.5, color: FC.text2)),
              ],
            ),
          ),
          GButton(action, size: 'sm', variant: GBtn.secondary, onTap: onTap),
        ],
      ),
    );
  }
}
