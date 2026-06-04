// GIF Studio — a grown-up uploads their own celebration GIFs (e.g. a clip
// of their child). One is shown, large, when the child finishes tracing the
// whole Arabic alphabet. Mirrors the Voiceover / Picture studios.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/gif_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/kid_button.dart';

class GifStudio extends StatelessWidget {
  const GifStudio({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final gifs = context.watch<GifService>();
    return Stack(
      children: [
        Positioned.fill(child: GestureDetector(onTap: app.closeGifStudio, child: ColoredBox(color: C.inkA(.45)))),
        Center(
          child: Container(
            width: 1040,
            constraints: const BoxConstraints(maxHeight: 880),
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
                                Text('GIF STUDIO', style: AppText.kicker),
                                const SizedBox(width: 12),
                                Text('${gifs.count} 🎞️',
                                    style: AppText.body(size: 20, weight: FontWeight.w800, color: C.muted)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Celebration GIFs', style: AppText.h2),
                            const SizedBox(height: 8),
                            Text(
                              'Add fun clips (like your child playing). One plays full-screen when they finish tracing the whole alphabet. Short, small GIFs work best.',
                              style: AppText.lead.copyWith(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                      IconCircle(Icons.close_rounded, onTap: app.closeGifStudio),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      KidButton(
                        onTap: () => context.read<GifService>().pickAndAdd(),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.add_rounded),
                          SizedBox(width: 8),
                          Text('Add a GIF'),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: gifs.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
                          child: Center(
                            child: Text(
                              '🎞️\nNo GIFs yet — tap “Add a GIF” to upload one.',
                              textAlign: TextAlign.center,
                              style: AppText.display(size: 28, weight: FontWeight.w700, color: C.muted),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(40, 0, 40, 34),
                          child: Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            children: [for (final g in gifs.gifs) _GifTile(id: g.id, bytes: g.bytes)],
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

class _GifTile extends StatelessWidget {
  final String id;
  final Uint8List bytes;
  const _GifTile({required this.id, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(R.md), boxShadow: Sh.sm),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(R.md),
            child: Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => context.read<GifService>().remove(id),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: Sh.sm),
                child: const Icon(Icons.close_rounded, size: 22, color: Color(0xFFE0573D)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
