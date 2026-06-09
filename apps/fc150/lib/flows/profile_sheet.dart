import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';
import 'photo_crop.dart';
import 'photo_viewer.dart';
import 'share_card.dart';

/// Profile sheet — large card, attribute bars, Photo + Share actions.
/// [onPhoto] persists the picked (and cropped) image path into app state.
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
  final _cardKey = GlobalKey(); // RepaintBoundary for "Share card"

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 90);
    if (x == null || !mounted) return;
    // Let the player frame the crop before it lands on the card.
    final cropped = await showPhotoCrop(context, x.path);
    if (cropped == null) return;
    widget.onPhoto(cropped);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final me = widget.me;
    return Column(
      children: [
        RepaintBoundary(
          key: _cardKey,
          child: FCCard(
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
            onPhotoTap: me.photo == null ? null : () => showPhotoViewer(context, me.photo!),
          ),
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
            Expanded(child: GButton('Share card', icon: LucideIcons.share2, full: true, onTap: () => showShareCardSheet(context, boundaryKey: _cardKey, playerName: me.short))),
          ],
        ),
      ],
    );
  }
}
