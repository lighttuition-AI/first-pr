import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

/// A "coming soon" surface for ops sections scaffolded but not yet built out.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: HpCard(
          padding: const EdgeInsets.all(HpSpace.x8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: HpColors.purpleTint,
                  borderRadius: BorderRadius.circular(HpRadius.lg),
                ),
                child: Icon(icon, color: HpColors.purple300, size: 26),
              ),
              const SizedBox(height: HpSpace.x4),
              Text(title, style: HpType.heading(size: 20)),
              const SizedBox(height: HpSpace.x2),
              Text(message, textAlign: TextAlign.center, style: HpType.body(size: 14)),
              const SizedBox(height: HpSpace.x4),
              const HpBadge(
                label: 'Planned',
                color: HpColors.purple300,
                tint: HpColors.purpleTint,
                glyph: '◌',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
