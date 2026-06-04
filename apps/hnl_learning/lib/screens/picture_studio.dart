// Picture Studio — upload your own art from the gallery for every
// image slot in the app. One upload applies everywhere that image
// appears. (Ported from the Studio UI in js/imgstudio.jsx.)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/image_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/avatar.dart';
import '../widgets/kid_button.dart';
import '../widgets/planet.dart';

class PictureStudio extends StatefulWidget {
  const PictureStudio({super.key});
  @override
  State<PictureStudio> createState() => _PictureStudioState();
}

class _PictureStudioState extends State<PictureStudio> {
  final groups = buildImgRegistry();
  late String? _open = groups.first.group;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final svc = context.watch<ImageService>();
    return Stack(
      children: [
        Positioned.fill(child: GestureDetector(onTap: app.closePictureStudio, child: ColoredBox(color: C.inkA(.45)))),
        Center(
          child: Container(
            width: 1100,
            constraints: const BoxConstraints(maxHeight: 900),
            decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(R.xl), boxShadow: Sh.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 34, 30, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('PICTURE STUDIO', style: AppText.kicker),
                                const SizedBox(width: 12),
                                Text('${svc.count} 🖼️', style: AppText.body(size: 20, weight: FontWeight.w800, color: C.muted)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Use your own pictures', style: AppText.h2),
                            const SizedBox(height: 8),
                            Text(
                              'Tap Upload on any picture to swap in your own art — it replaces that image everywhere it appears, rounded to fit.',
                              style: AppText.lead.copyWith(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                      IconCircle(Icons.close_rounded, onTap: app.closePictureStudio),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 34),
                    child: Column(
                      children: [
                        for (final g in groups)
                          _Group(
                            group: g,
                            open: _open == g.group,
                            uploadedCount: g.items.where((s) => svc.has(s.id)).length,
                            onToggle: () => setState(() => _open = _open == g.group ? null : g.group),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  final ImgGroup group;
  final bool open;
  final int uploadedCount;
  final VoidCallback onToggle;
  const _Group({required this.group, required this.open, required this.uploadedCount, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.md), boxShadow: Sh.sm),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(child: Text(group.group, style: AppText.display(size: 28, weight: FontWeight.w700))),
                  Text('$uploadedCount/${group.items.length} 🖼️',
                      style: AppText.body(size: 22, weight: FontWeight.w700, color: C.muted)),
                  const SizedBox(width: 12),
                  Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [for (final s in group.items) _SlotTile(slot: s)],
              ),
            ),
        ],
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  final ImgSlot slot;
  const _SlotTile({required this.slot});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<ImageService>();
    final has = svc.has(slot.id);
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(R.md), border: Border.all(color: C.line)),
      child: Column(
        children: [
          SizedBox(height: 80, child: Center(child: _preview(svc))),
          const SizedBox(height: 8),
          Text(slot.where, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(size: 18, weight: FontWeight.w700, color: C.muted)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KidButton(small: true, onTap: () => svc.pickFor(slot.id), child: const Text('Upload')),
              if (has) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => svc.remove(slot.id),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: C.card, shape: BoxShape.circle, boxShadow: Sh.sm),
                    child: const Icon(Icons.refresh_rounded, size: 24),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _preview(ImageService svc) {
    final bytes = svc.bytesFor(slot.id);
    if (bytes != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(R.sm), child: Image.memory(bytes, width: 76, height: 76, fit: BoxFit.cover));
    }
    switch (slot.kind) {
      case SlotKind.emoji:
        return Text(slot.data as String, style: const TextStyle(fontSize: 52));
      case SlotKind.avatar:
        return Avatar(data: slot.data as AvatarData, size: 70);
      case SlotKind.planet:
        return Planet(data: slot.data as PlanetData, size: 70);
    }
  }
}
