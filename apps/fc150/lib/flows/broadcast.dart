import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Compose + push a broadcast (admin). [onSend] receives the message text.
void showBroadcastCompose(BuildContext context, ValueChanged<String> onSend) {
  showFcSheet(context, builder: (_) => _Compose(onSend: onSend));
}

class _Compose extends StatefulWidget {
  final ValueChanged<String> onSend;
  const _Compose({required this.onSend});
  @override
  State<_Compose> createState() => _ComposeState();
}

class _ComposeState extends State<_Compose> {
  final _ctrl = TextEditingController();
  bool _empty = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
              decoration: BoxDecoration(color: FC.purpleTint, borderRadius: BorderRadius.circular(11)),
              child: const Icon(LucideIcons.megaphone, size: 20, color: FC.purple300),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Broadcast'),
                  const SizedBox(height: 2),
                  Text('Message all players', style: FCType.heading(size: 19, weight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Players see this as a popup the next time they open the app.',
            style: FCType.body(size: 12.5, color: FC.text2, height: 1.35)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: FC.overlay,
            borderRadius: BorderRadius.circular(FC.rInput + 4),
            border: Border.all(color: FC.border),
          ),
          child: TextField(
            controller: _ctrl,
            minLines: 3,
            maxLines: 6,
            maxLength: 280,
            autofocus: true,
            onChanged: (v) => setState(() => _empty = v.trim().isEmpty),
            style: FCType.body(size: 14, weight: FontWeight.w500, height: 1.4),
            cursorColor: FC.purple300,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: InputBorder.none,
              hintText: 'e.g. Season 3 fixtures drop Friday 8pm — get your challenges in!',
              hintStyle: FCType.body(size: 14, color: FC.textMuted, height: 1.4),
              counterStyle: FCType.mono(size: 10.5, color: FC.textMuted),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GButton(
          'Push to all players',
          icon: LucideIcons.send,
          full: true,
          disabled: _empty,
          onTap: () {
            final msg = _ctrl.text.trim();
            if (msg.isEmpty) return;
            widget.onSend(msg);
            Navigator.of(context).maybePop();
            flashToast(context, 'Broadcast pushed · players see it on next open');
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// The popup a player sees on opening the app after a broadcast was pushed.
void showBroadcastPopup(BuildContext context, String message) {
  showFcSheet(context, dismissible: true, builder: (_) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: FC.purpleTint, shape: BoxShape.circle, boxShadow: FC.glowPurpleSm),
            child: const Icon(LucideIcons.megaphone, size: 26, color: FC.purple300),
          ),
        ),
        const SizedBox(height: 14),
        Center(child: const Eyebrow('Announcement', color: FC.purple300)),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center, style: FCType.heading(size: 18, weight: FontWeight.w700, height: 1.3)),
        const SizedBox(height: 18),
        GButton('Got it', full: true, onTap: () => Navigator.of(context).maybePop()),
        const SizedBox(height: 4),
      ],
    );
  });
}
