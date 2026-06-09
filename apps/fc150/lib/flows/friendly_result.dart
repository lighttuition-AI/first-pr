import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Log the result of a friendly challenge. [onResult] receives 'win'|'draw'|'loss'.
void showFriendlyResult(BuildContext context, String opponent, ValueChanged<String> onResult) {
  showFcSheet(context, builder: (sheetCtx) {
    void pick(String outcome) {
      onResult(outcome);
      Navigator.of(sheetCtx).maybePop();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(alignment: Alignment.centerLeft, child: SectionTitle('Log result')),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('How did your friendly vs $opponent go?', style: FCType.body(size: 12.5, color: FC.text2)),
        ),
        const SizedBox(height: 16),
        GButton('Win', variant: GBtn.teal, icon: LucideIcons.trophy, full: true, onTap: () => pick('win')),
        const SizedBox(height: 10),
        GButton('Draw', variant: GBtn.secondary, icon: LucideIcons.equal, full: true, onTap: () => pick('draw')),
        const SizedBox(height: 10),
        GButton('Loss', variant: GBtn.secondary, icon: LucideIcons.x, full: true, onTap: () => pick('loss')),
        const SizedBox(height: 4),
      ],
    );
  });
}
