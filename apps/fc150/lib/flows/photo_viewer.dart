import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/tokens.dart';

/// Full-screen photo viewer — tap the photo on a player card to expand it for a
/// better look. Pinch to zoom, drag to pan, tap the backdrop (or ✕) to close.
/// Animates in from the card photo via a shared [heroTag].
void showPhotoViewer(BuildContext context, String path, {Object heroTag = 'fc-card-photo'}) {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: const Color(0xF2050509),
      barrierDismissible: true,
      transitionDuration: FC.durSlow,
      reverseTransitionDuration: FC.durBase,
      pageBuilder: (_, anim, __) => FadeTransition(
        opacity: anim,
        child: _PhotoViewer(path: path, heroTag: heroTag),
      ),
    ),
  );
}

class _PhotoViewer extends StatelessWidget {
  final String path;
  final Object heroTag;
  const _PhotoViewer({required this.path, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 200,
                        height: 200,
                        child: ColoredBox(color: FC.overlay, child: Icon(LucideIcons.imageOff, color: FC.text2)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: top + 8,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x80141420),
                  shape: BoxShape.circle,
                  border: Border.all(color: FC.borderStrong),
                ),
                child: const Icon(LucideIcons.x, size: 20, color: FC.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
