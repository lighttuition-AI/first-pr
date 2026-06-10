import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Opens the challenge bottom sheet.
/// - [preset]: quick 1v1 from a player's card — skips type/opponent → time.
/// - generic (no preset): starts at the type step, where 2v2 can be chosen.
/// - [autoLock]: jump straight to the "match locked" confirmation (accept invite).
Future<void> showChallengeFlow(
  BuildContext context, {
  Player? preset,
  String? presetSlot,
  bool autoLock = false,
  void Function(Player opponent, String mode, String slot)? onConfirm,
}) {
  return showFcSheet(
    context,
    dismissible: !autoLock,
    builder: (_) => _ChallengeSheet(preset: preset, presetSlot: presetSlot, autoLock: autoLock, onConfirm: onConfirm),
  );
}

class _ChallengeSheet extends StatefulWidget {
  final Player? preset;
  final String? presetSlot;
  final bool autoLock;
  final void Function(Player opponent, String mode, String slot)? onConfirm;
  const _ChallengeSheet({this.preset, this.presetSlot, this.autoLock = false, this.onConfirm});

  @override
  State<_ChallengeSheet> createState() => _ChallengeSheetState();
}

class _ChallengeSheetState extends State<_ChallengeSheet> {
  String _mode = '1v1';
  Player? _teammate;
  final List<Player> _opponents = [];
  late String _slot = widget.presetSlot ?? 'Today · 20:30';
  late bool _sent = widget.autoLock;
  int _index = 0;

  static const _slots = ['Today · 20:30', 'Today · 22:00', 'Tomorrow · 19:00', 'Tomorrow · 21:30', 'Sat · 18:00'];

  // Step keys vary by mode.
  List<String> get _steps => _mode == '2v2'
      ? const ['type', 'teammate', 'opponents', 'time', 'confirm']
      : const ['type', 'opponent', 'time', 'confirm'];

  String get _step => _steps[_index.clamp(0, _steps.length - 1)];

  @override
  void initState() {
    super.initState();
    if (widget.preset != null) {
      _opponents.add(widget.preset!);
      _index = _steps.indexOf('time'); // quick 1v1 path
    }
    if (widget.autoLock) {
      Timer(const Duration(milliseconds: 1800), _closeIfMounted);
    }
  }

  void _closeIfMounted() {
    if (mounted) Navigator.of(context).maybePop();
  }

  void _send() {
    setState(() => _sent = true);
    if (_opponents.isNotEmpty) widget.onConfirm?.call(_opponents.first, _mode, _slot);
    Timer(const Duration(milliseconds: 1700), _closeIfMounted);
  }

  void _next() => setState(() => _index++);

  bool get _canContinue {
    switch (_step) {
      case 'teammate':
        return _teammate != null;
      case 'opponent':
        return _opponents.isNotEmpty;
      case 'opponents':
        return _opponents.length == 2;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) return _locked();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepper(),
        const SizedBox(height: 16),
        switch (_step) {
          'type' => _typeStep(),
          'teammate' => _teammateStep(),
          'opponent' => _opponentStep(),
          'opponents' => _opponentsStep(),
          'time' => _timeStep(),
          _ => _confirmStep(),
        },
      ],
    );
  }

  Widget _stepper() {
    final n = _steps.length;
    return Row(
      children: [
        for (int i = 0; i < n; i++) ...[
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: i <= _index ? FC.gradient : null,
                color: i <= _index ? null : FC.overlay,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < n - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _heading(String title, [String? sub]) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FCType.heading(size: 20, weight: FontWeight.w800)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub, style: FCType.body(size: 13, color: FC.text2)),
          ],
        ],
      );

  Widget _typeStep() {
    Widget tile(String m, IconData ic, String sub) {
      final sel = _mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _mode = m;
            // reset roster when switching mode
            _teammate = null;
            _opponents.clear();
          }),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: sel ? FC.purpleTint : FC.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sel ? FC.borderFocus : FC.border),
              boxShadow: sel ? FC.glowPurpleSm : null,
            ),
            child: Column(
              children: [
                Icon(ic, size: 26, color: sel ? FC.purple300 : FC.text2),
                const SizedBox(height: 8),
                Text(m, style: FCType.heading(size: 18, weight: FontWeight.w800)),
                Text(sub, style: FCType.body(size: 12, color: FC.text2, height: 1.2)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Challenge type', 'How do you want to play?'),
        const SizedBox(height: 16),
        Row(children: [
          tile('1v1', LucideIcons.user, 'Solo duel'),
          const SizedBox(width: 12),
          tile('2v2', LucideIcons.users, 'Team match'),
        ]),
        const SizedBox(height: 18),
        GButton('Continue', full: true, icon: LucideIcons.arrowRight, onTap: _next),
      ],
    );
  }

  Widget _teammateStep() {
    final pool = Seed.players.where((p) => p.id != 'p01').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Pick your teammate', 'They play on your side in the 2v2'),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 290),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: pool.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _PoolPickRow(
              p: pool[i],
              selected: _teammate?.id == pool[i].id,
              accent: FC.teal,
              onTap: () => setState(() => _teammate = pool[i]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GButton('Continue', full: true, icon: LucideIcons.arrowRight, disabled: !_canContinue, onTap: _next),
      ],
    );
  }

  Widget _opponentStep() {
    final pool = Seed.players.where((p) => p.id != 'p01').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Pick opponent', 'Available in the 1v1 pool right now'),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: pool.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _PoolPickRow(
              p: pool[i],
              selected: _opponents.isNotEmpty && _opponents.first.id == pool[i].id,
              onTap: () => setState(() {
                _opponents
                  ..clear()
                  ..add(pool[i]);
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GButton('Continue', full: true, icon: LucideIcons.arrowRight, disabled: !_canContinue, onTap: _next),
      ],
    );
  }

  Widget _opponentsStep() {
    // exclude me + teammate
    final pool = Seed.players.where((p) => p.id != 'p01' && p.id != _teammate?.id).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Pick two opponents', 'Choose the opposing pair (${_opponents.length}/2)'),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 290),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: pool.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final p = pool[i];
              final selected = _opponents.any((o) => o.id == p.id);
              return _PoolPickRow(
                p: p,
                selected: selected,
                multi: true,
                onTap: () => setState(() {
                  if (selected) {
                    _opponents.removeWhere((o) => o.id == p.id);
                  } else if (_opponents.length < 2) {
                    _opponents.add(p);
                  }
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        GButton('Continue', full: true, icon: LucideIcons.arrowRight, disabled: !_canContinue, onTap: _next),
      ],
    );
  }

  String _fmtDateTime(DateTime dt) {
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hh = dt.hour.toString().padLeft(2, '0'), mm = dt.minute.toString().padLeft(2, '0');
    return '${wd[dt.weekday - 1]} ${dt.day} ${mo[dt.month - 1]} · $hh:$mm';
  }

  /// A single iOS-style date+time wheel in a bottom sheet. Replaces the Material
  /// clock-dial picker (whose keyboard/typing mode was fiddly on device): the
  /// wheel always works, reads as native on iOS, and keeps everything in one
  /// scroll instead of two chained dialogs.
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    // Default to the next round-ish kick-off (top of the next hour).
    var temp = DateTime(now.year, now.month, now.day, now.hour).add(const Duration(hours: 1));

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: FC.elevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: FC.border)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pick date & time', style: FCType.heading(size: 16, weight: FontWeight.w800)),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(sheetCtx).pop(temp),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text('Done', style: FCType.body(size: 15, weight: FontWeight.w800, color: FC.purple300)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 224,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(fontSize: 19, color: FC.text, fontWeight: FontWeight.w600),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    use24hFormat: true,
                    initialDateTime: temp,
                    minimumDate: now.subtract(const Duration(minutes: 1)),
                    maximumDate: now.add(const Duration(days: 90)),
                    onDateTimeChanged: (d) => temp = d,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _slot = _fmtDateTime(picked));
  }

  Widget _timeStep() {
    final sub = _mode == '2v2'
        ? 'You & ${_teammate?.short ?? '—'} vs ${_opponents.map((o) => o.short.split(' ').first).join(' & ')}'
        : 'vs ${_opponents.isNotEmpty ? _opponents.first.short : '—'} · $_mode';
    final custom = !_slots.contains(_slot);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Pick date & time', sub),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: custom ? FC.purpleTint : FC.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: custom ? FC.borderFocus : FC.borderStrong),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.calendarClock, size: 18, color: FC.purple300),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(custom ? _slot : 'Pick a date & time', style: FCType.body(size: 13.5, weight: FontWeight.w700)),
                      Text('Choose any day and kick-off time', style: FCType.body(size: 11.5, color: FC.text2)),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, size: 18, color: FC.textMuted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Or pick a quick slot', style: FCType.body(size: 11.5, weight: FontWeight.w600, color: FC.text2)),
        const SizedBox(height: 8),
        for (final s in _slots) ...[
          GestureDetector(
            onTap: () => setState(() => _slot = s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: _slot == s ? FC.purpleTint : FC.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _slot == s ? FC.borderFocus : FC.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s, style: FCType.mono(size: 13.5, weight: FontWeight.w600)),
                  if (_slot == s) const Icon(LucideIcons.check, size: 18, color: FC.purple300),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        GButton('Review', full: true, icon: LucideIcons.arrowRight, onTap: _next),
      ],
    );
  }

  Widget _confirmStep() {
    final rows = _mode == '2v2'
        ? [
            ('Type', '2v2 · Team match'),
            ('Your team', 'You & ${_teammate?.short ?? '—'}'),
            ('Opponents', _opponents.map((o) => o.short).join(' & ')),
            ('When', _slot),
            ('Console', 'PlayStation 5'),
            ('Competition', 'Friendly'),
          ]
        : [
            ('Type', '1v1 · Solo duel'),
            ('Opponent', _opponents.isNotEmpty ? _opponents.first.short : '—'),
            ('When', _slot),
            ('Console', 'PlayStation 5'),
            ('Competition', 'Friendly'),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading('Confirm challenge'),
        const SizedBox(height: 14),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FC.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: FC.surface,
                    border: i < rows.length - 1 ? const Border(bottom: BorderSide(color: FC.border)) : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 92, child: Text(rows[i].$1, style: FCType.body(size: 13, color: FC.text2))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(rows[i].$2, textAlign: TextAlign.right, style: FCType.body(size: 13.5, weight: FontWeight.w600))),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _mode == '2v2'
              ? "If the opposing pair doesn't show, your team automatically wins 3–0. Both teams are removed from the pool for this slot."
              : "If your opponent doesn't show, you automatically win 3–0 and it counts to the league table and your card.",
          style: FCType.body(size: 12, color: FC.textMuted, height: 1.5),
        ),
        const SizedBox(height: 14),
        GButton('Send challenge', full: true, variant: GBtn.teal, icon: LucideIcons.swords, onTap: _send),
      ],
    );
  }

  Widget _locked() {
    final detail = _mode == '2v2'
        ? 'You & ${_teammate?.short ?? 'your teammate'} vs ${_opponents.map((o) => o.short).join(' & ')} · $_slot. Both teams removed from the pool for this slot. Play it on PS5, then submit the score.'
        : 'You vs ${_opponents.isNotEmpty ? _opponents.first.short : 'your opponent'} · $_slot. Both removed from the pool for this slot. Play it on PS5, then submit the score.';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: FC.tealTint,
                shape: BoxShape.circle,
                border: Border.all(color: FC.teal, width: 2),
                boxShadow: FC.glowTeal,
              ),
              child: const Icon(LucideIcons.lock, size: 34, color: FC.teal),
            ),
          ),
          const SizedBox(height: 18),
          const Eyebrow('Match locked', color: FC.teal),
          const SizedBox(height: 6),
          Text(_mode == '2v2' ? 'Team match confirmed' : 'Challenge confirmed', style: FCType.heading(size: 21, weight: FontWeight.w800)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Text(detail, textAlign: TextAlign.center, style: FCType.body(size: 13.5, color: FC.text2)),
          ),
        ],
      ),
    );
  }
}

/// Pool pick row (avatar · name · pos·PSN · rating), with single or multi-select.
class _PoolPickRow extends StatelessWidget {
  final Player p;
  final bool selected;
  final bool multi;
  final Color accent;
  final VoidCallback onTap;
  const _PoolPickRow({required this.p, required this.selected, required this.onTap, this.multi = false, this.accent = FC.purple300});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? FC.purpleTint : FC.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? FC.borderFocus : FC.border),
        ),
        child: Row(
          children: [
            AvatarInitials(initials: p.initials, size: 38, expandable: false),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.short, maxLines: 1, overflow: TextOverflow.ellipsis, style: FCType.body(size: 14, weight: FontWeight.w600, height: 1.2)),
                  Text('${p.pos} · PSN ${p.psn}', style: FCType.mono(size: 11.5, color: FC.text2)),
                ],
              ),
            ),
            if (multi)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected ? FC.teal : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? FC.teal : FC.borderStrong),
                ),
                child: selected ? const Icon(LucideIcons.check, size: 14, color: Color(0xFF04201F)) : null,
              )
            else
              Text('${p.rating}', style: FCType.mono(size: 16, weight: FontWeight.w700, color: selected ? accent : FC.purple300)),
          ],
        ),
      ),
    );
  }
}
