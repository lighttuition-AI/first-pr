// Storytelling Island — the Somali story library. A back-button screen (like
// the continent map) listing the folktales: the ready ones are tappable, the
// rest show a friendly "coming soon" badge.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';

class StoryLibraryScreen extends StatelessWidget {
  const StoryLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE9C7), Color(0xFFFCD9A6)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
            child: Row(
              children: [
                IconCircle(Icons.arrow_back_rounded, onTap: () => app.go('home')),
                const SizedBox(width: 16),
                Text('📖  Story Time', style: AppText.display(size: 30, weight: FontWeight.w800)),
                const SizedBox(width: 12),
                Text('Sheekooyin', style: AppText.body(size: 22, weight: FontWeight.w700, color: C.muted)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 30),
              child: Center(
                child: Wrap(
                  spacing: 22,
                  runSpacing: 22,
                  alignment: WrapAlignment.center,
                  children: [for (final s in kStories) _StoryCard(story: s)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final Story story;
  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final ready = story.ready;
    return Pressable(
      onTap: ready ? () => app.startStory(story.id) : null,
      child: Opacity(
        opacity: ready ? 1 : 0.62,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(R.lg),
            boxShadow: Sh.sm,
            border: activeSkin.cardBorder,
          ),
          child: Row(
            children: [
              Container(
                width: 74,
                height: 74,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0A3),
                  borderRadius: BorderRadius.circular(R.md),
                ),
                child: Img(story.emoji, size: 44),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(story.titleSo, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.display(size: 24, weight: FontWeight.w800)),
                    Text(story.titleEn, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(size: 18, weight: FontWeight.w700, color: C.muted)),
                    const SizedBox(height: 6),
                    if (ready)
                      Row(children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(color: app.pal.brandSoft, shape: BoxShape.circle),
                          child: Icon(Icons.play_arrow_rounded, color: app.pal.brand, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text('Ages ${story.ageRange}', style: AppText.body(size: 16, weight: FontWeight.w700, color: C.inkSoft)),
                      ])
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: C.line, borderRadius: BorderRadius.circular(R.pill)),
                        child: Text('Coming soon', style: AppText.body(size: 15, weight: FontWeight.w800, color: C.inkSoft)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
