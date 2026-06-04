// Dropdown shown from the home profile chip: switch between onboarded
// children, add a new one, or jump to the (locked) parent area.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/avatar.dart';

class ChildSwitcher extends StatelessWidget {
  const ChildSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(onTap: app.closeChildMenu, child: ColoredBox(color: C.inkA(.25))),
        ),
        Positioned(
          left: 26,
          top: 112,
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(R.lg),
              boxShadow: Sh.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                  child: Text("Who's playing?", style: AppText.display(size: 24, weight: FontWeight.w700, color: C.muted)),
                ),
                for (var i = 0; i < app.children.length; i++)
                  _ChildRow(index: i, child: app.children[i], active: i == app.activeIndex),
                Divider(height: 22, color: C.line),
                _MenuItem(
                  emoji: '➕',
                  label: 'Add a child',
                  onTap: app.addChild,
                ),
                _MenuItem(
                  emoji: '🔒',
                  label: 'Parent area',
                  onTap: () {
                    app.closeChildMenu();
                    app.go('gate');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildRow extends StatelessWidget {
  final int index;
  final Child child;
  final bool active;
  const _ChildRow({required this.index, required this.child, required this.active});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final sub = child.isSetUp ? 'Age ${child.age}' : 'Tap to finish setup';
    return GestureDetector(
      onTap: () => app.setActiveChild(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? app.pal.brandSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(R.md),
        ),
        child: Row(
          children: [
            _avatar(child, 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Child ${index + 1}', style: AppText.display(size: 24, weight: FontWeight.w700)),
                  Text(sub, style: AppText.body(size: 18, weight: FontWeight.w700, color: C.muted)),
                ],
              ),
            ),
            if (active)
              Icon(Icons.check_circle_rounded, color: app.pal.brand, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _avatar(Child c, double size) {
    final bytes = c.photoBytes;
    if (bytes != null) {
      return ClipOval(child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover));
    }
    final av = c.avatar != null
        ? kAvatars.firstWhere((a) => a.id == c.avatar, orElse: () => kAvatars[0])
        : kAvatars[0];
    return Avatar(data: av, size: size);
  }
}

class _MenuItem extends StatelessWidget {
  final String emoji, label;
  final VoidCallback onTap;
  const _MenuItem({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Text(label, style: AppText.display(size: 24, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
