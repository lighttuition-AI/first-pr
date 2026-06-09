import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/competitions.dart';
import '../models/competition.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Competition switcher sheet. Returns the chosen competition id, or null.
Future<String?> showCompetitionPicker(BuildContext context, String currentId) {
  return showFcSheet<String>(
    context,
    builder: (_) => _CompetitionPicker(currentId: currentId),
  );
}

class _CompetitionPicker extends StatelessWidget {
  final String currentId;
  const _CompetitionPicker({required this.currentId});

  IconData _icon(Competition c) =>
      c.id == 'pl' ? LucideIcons.listOrdered : c.id == 'wc' ? LucideIcons.globe : LucideIcons.trophy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(alignment: Alignment.centerLeft, child: SectionTitle('Switch competition')),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Standings, fixtures and brackets update to match.', style: FCType.body(size: 12.5, color: FC.text2)),
        ),
        const SizedBox(height: 14),
        for (final c in Comps.all) ...[
          GestureDetector(
            onTap: () => Navigator.of(context).pop(c.id),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: c.id == currentId ? FC.purpleTint : FC.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.id == currentId ? FC.borderFocus : FC.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(11)),
                    child: Icon(_icon(c), size: 19, color: c.id == currentId ? FC.purple300 : FC.text2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.name} · ${c.season}', style: FCType.body(size: 14, weight: FontWeight.w700, height: 1.2)),
                        Text(c.isCup ? 'Group stage + knockout' : 'League · 38-game season', style: FCType.body(size: 11.5, color: FC.text2)),
                      ],
                    ),
                  ),
                  if (c.id == currentId) const Icon(LucideIcons.check, size: 18, color: FC.purple300),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}
