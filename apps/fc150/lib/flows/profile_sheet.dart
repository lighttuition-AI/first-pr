import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Profile sheet — large card, attribute bars, Photo + Share actions.
/// [onPhoto] persists the picked image path into app state.
Future<void> showProfileSheet(BuildContext context, Player me, ValueChanged<String> onPhoto) {
  return showFcSheet(context, builder: (_) => _ProfileSheet(me: me, onPhoto: onPhoto));
}

class _ProfileSheet extends StatefulWidget {
  final Player me;
  final ValueChanged<String> onPhoto;
  const _ProfileSheet({required this.me, required this.onPhoto});
  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 88);
    if (x == null) return;
    widget.onPhoto(x.path);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final me = widget.me;
    return Column(
      children: [
        FCCard(
          variant: me.variant,
          tier: me.tier,
          rating: me.rating,
          name: me.name,
          pos: me.pos,
          psn: me.psn,
          stats: me.stats,
          photo: me.photo,
          flagBands: Seed.flagOf(me.country),
          width: 230,
        ),
        const SizedBox(height: 18),
        const Align(alignment: Alignment.centerLeft, child: SectionTitle('Attributes')),
        const SizedBox(height: 10),
        StatBars(stats: {
          'pac': me.stats.pac, 'sho': me.stats.sho, 'pas': me.stats.pas,
          'dri': me.stats.dri, 'def': me.stats.def, 'phy': me.stats.phy,
        }, animate: true),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: GButton('Photo', variant: GBtn.secondary, icon: LucideIcons.camera, full: true, onTap: _pick)),
            const SizedBox(width: 10),
            Expanded(child: GButton('Share card', icon: LucideIcons.share2, full: true, onTap: () {})),
          ],
        ),
      ],
    );
  }
}
