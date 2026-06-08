import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/seed_data.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

const _iconFor = {
  'challenge': LucideIcons.swords,
  'locked': LucideIcons.lock,
  'result': LucideIcons.flag,
  'card': LucideIcons.trendingUp,
  'top3': LucideIcons.crown,
};

Future<void> showNotificationsSheet(BuildContext context) {
  return showFcSheet(context, builder: (_) => const _NotifSheet());
}

class _NotifSheet extends StatelessWidget {
  const _NotifSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(alignment: Alignment.centerLeft, child: SectionTitle('Notifications')),
        const SizedBox(height: 12),
        for (final n in Seed.notifs) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: n.unread ? FC.purpleTint : FC.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: n.unread ? const Color(0x597C6CF8) : FC.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(9)),
                  child: Icon(_iconFor[n.kind] ?? LucideIcons.bell, size: 17, color: FC.purple300),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(n.text, style: FCType.body(size: 13, height: 1.4))),
                const SizedBox(width: 8),
                Text(n.time, style: FCType.mono(size: 11, color: FC.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
