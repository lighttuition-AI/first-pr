import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Start a new season for a competition: optionally crown the champion of the
/// season that's ending (they get a trophy), then reset the competition.
/// [onConfirm] receives the chosen winner id, or null for "no champion".
void showNewSeasonSheet(
  BuildContext context, {
  required String compName,
  required List<Player> entrants,
  required void Function(String? winnerId) onConfirm,
}) {
  showFcSheet(context, builder: (_) => _NewSeason(compName: compName, entrants: entrants, onConfirm: onConfirm));
}

class _NewSeason extends StatefulWidget {
  final String compName;
  final List<Player> entrants;
  final void Function(String? winnerId) onConfirm;
  const _NewSeason({required this.compName, required this.entrants, required this.onConfirm});
  @override
  State<_NewSeason> createState() => _NewSeasonState();
}

class _NewSeasonState extends State<_NewSeason> {
  String? _winner;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: FC.warningTint, borderRadius: BorderRadius.circular(11)),
              child: const Icon(LucideIcons.trophy, size: 20, color: FC.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('New season', color: FC.warning),
                  const SizedBox(height: 2),
                  Text(widget.compName, style: FCType.heading(size: 19, weight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Crown the champion of the season that’s ending (optional) — they get a trophy on their card. Starting a new season clears the roster, so you’ll re-draft players.',
            style: FCType.body(size: 12.5, color: FC.text2, height: 1.4)),
        const SizedBox(height: 14),
        if (widget.entrants.isEmpty)
          Surface(child: Center(child: Text('No players in this competition yet', style: FCType.body(size: 13, color: FC.text2))))
        else ...[
          const Align(alignment: Alignment.centerLeft, child: SectionTitle('Champion')),
          const SizedBox(height: 9),
          _option(null, 'No champion this season', LucideIcons.minus),
          const SizedBox(height: 8),
          for (final p in widget.entrants) ...[_playerOption(p), const SizedBox(height: 8)],
        ],
        const SizedBox(height: 8),
        GButton(
          'Start new season',
          variant: GBtn.primary,
          icon: LucideIcons.refreshCw,
          full: true,
          onTap: () {
            widget.onConfirm(_winner);
            Navigator.of(context).maybePop();
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _playerOption(Player p) => _selectable(
        p.id,
        leading: AvatarInitials(initials: p.initials, size: 36, photo: p.photo, expandable: false),
        title: p.short,
        sub: '${p.pos} · ${p.rating} OVR',
      );

  Widget _option(String? id, String title, IconData icon) => _selectable(
        id,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: FC.overlay, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: FC.textMuted),
        ),
        title: title,
      );

  Widget _selectable(String? id, {required Widget leading, required String title, String? sub}) {
    final selected = _winner == id;
    return Surface(
      onTap: () => setState(() => _winner = id),
      borderColor: selected ? FC.borderFocus : null,
      child: Row(
        children: [
          leading,
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: FCType.body(size: 13.5, weight: FontWeight.w600, height: 1.2)),
                if (sub != null) Text(sub, style: FCType.mono(size: 11, color: FC.text2)),
              ],
            ),
          ),
          Icon(selected ? LucideIcons.circleCheck : LucideIcons.circle, size: 20, color: selected ? FC.purple300 : FC.borderStrong),
        ],
      ),
    );
  }
}
