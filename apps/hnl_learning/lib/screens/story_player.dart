// Story player — reads a Somali folktale scene by scene, then asks a couple of
// questions and shows the moral. Each scene has an original animated scene
// (StorySceneArt), bilingual narration (English + Somali — tap to hear,
// recordable in the Voiceover Studio) and an optional character speech bubble.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';
import '../widgets/story_art.dart';

class StoryPlayerScreen extends StatefulWidget {
  const StoryPlayerScreen({super.key});
  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

enum _Phase { story, questions, moral }

class _StoryPlayerScreenState extends State<StoryPlayerScreen> {
  late final Story story;
  int _scene = 0;
  int _q = 0;
  _Phase _phase = _Phase.story;
  String? _wrong; // last wrong option id (for a gentle flash)

  @override
  void initState() {
    super.initState();
    story = storyById(context.read<AppState>().currentStory ?? kStories.first.id);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playNarration());
  }

  void _playNarration() {
    if (!mounted) return;
    final vo = context.read<VoService>();
    final s = story.scenes[_scene];
    // Auto-play Somali if a grown-up has recorded it; otherwise English so the
    // child can always follow along.
    final soId = storyVoId(story.id, s.id, 'so');
    if (vo.has(soId)) {
      vo.play(soId, s.narrationSo, lang: 'so-SO');
    } else {
      vo.play(storyVoId(story.id, s.id, 'en'), s.narrationEn, lang: 'en-US');
    }
  }

  void _say(String lang) {
    final vo = context.read<VoService>();
    final s = story.scenes[_scene];
    if (lang == 'so') {
      vo.play(storyVoId(story.id, s.id, 'so'), s.narrationSo, lang: 'so-SO');
    } else {
      vo.play(storyVoId(story.id, s.id, 'en'), s.narrationEn, lang: 'en-US');
    }
  }

  void _next() {
    if (_scene < story.scenes.length - 1) {
      setState(() => _scene++);
      _playNarration();
    } else {
      setState(() => _phase = story.questions.isEmpty ? _Phase.moral : _Phase.questions);
    }
  }

  void _prev() {
    if (_scene > 0) {
      setState(() => _scene--);
      _playNarration();
    }
  }

  void _answer(StoryQuestion q, StoryOption o) {
    if (o.correct) {
      context.read<FxController>().fire(intensity: context.read<AppState>().celebration);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _wrong = null;
          if (_q < story.questions.length - 1) {
            _q++;
          } else {
            _phase = _Phase.moral;
          }
        });
      });
    } else {
      setState(() => _wrong = '${q.id}-${o.labelEn}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final bg = _phase == _Phase.story
        ? [story.scenes[_scene].bgTop, story.scenes[_scene].bgBottom]
        : const [Color(0xFFFFF0D6), Color(0xFFFCDFB0)];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: bg),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 24,
            left: 24,
            child: IconCircle(Icons.arrow_back_rounded, size: 64, onTap: () => app.go('stories')),
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(story.titleSo, style: AppText.display(size: 26, weight: FontWeight.w800)),
            ),
          ),
          Positioned.fill(
            top: 84,
            child: switch (_phase) {
              _Phase.story => _sceneView(app),
              _Phase.questions => _questionView(app),
              _Phase.moral => _moralView(app),
            },
          ),
        ],
      ),
    );
  }

  // ---- Scene ----
  Widget _sceneView(AppState app) {
    final s = story.scenes[_scene];
    final last = _scene == story.scenes.length - 1;
    return Column(
      children: [
        // Scene art with optional speech bubble
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Stack(
              children: [
                Positioned.fill(child: StorySceneArt(art: s.art)),
                if (s.speaker != Speaker.narrator && s.lineSo != null)
                  Align(
                    alignment: s.speaker == Speaker.fox ? Alignment.topLeft : Alignment.topRight,
                    child: _Bubble(so: s.lineSo!, en: s.lineEn ?? ''),
                  ),
              ],
            ),
          ),
        ),
        // Narration card
        Container(
          margin: const EdgeInsets.fromLTRB(40, 8, 40, 8),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          decoration: BoxDecoration(
            color: C.card.withValues(alpha: .94),
            borderRadius: BorderRadius.circular(R.lg),
            boxShadow: Sh.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.narrationSo, textAlign: TextAlign.center, style: AppText.display(size: 24, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(s.narrationEn, textAlign: TextAlign.center, style: AppText.body(size: 19, weight: FontWeight.w600, color: C.muted)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ListenChip(flag: '🇸🇴', label: 'Soomaali', onTap: () => _say('so')),
                  const SizedBox(width: 12),
                  _ListenChip(flag: '🇬🇧', label: 'English', onTap: () => _say('en')),
                ],
              ),
            ],
          ),
        ),
        // Nav
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 22),
          child: Row(
            children: [
              if (_scene > 0)
                KidButton(variant: BtnVariant.ghost, onTap: _prev, child: const Text('◀ Back'))
              else
                const SizedBox(width: 10),
              const Spacer(),
              _Dots(total: story.scenes.length, index: _scene, brand: app.pal.brand),
              const Spacer(),
              KidButton(
                onTap: _next,
                child: Text(last ? 'Questions →' : 'Next →', style: AppText.display(size: 26, weight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- Questions ----
  Widget _questionView(AppState app) {
    final q = story.questions[_q];
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 10, 50, 30),
      child: Column(
        children: [
          const Spacer(),
          Text('❓', style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(q.qSo, textAlign: TextAlign.center, style: AppText.display(size: 30, weight: FontWeight.w800)),
          Text(q.qEn, textAlign: TextAlign.center, style: AppText.body(size: 22, weight: FontWeight.w700, color: C.muted)),
          const SizedBox(height: 26),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            children: [
              for (final o in q.options)
                _OptionCard(
                  option: o,
                  flash: _wrong == '${q.id}-${o.labelEn}',
                  onTap: () => _answer(q, o),
                ),
            ],
          ),
          const Spacer(),
          _Dots(total: story.questions.length, index: _q, brand: app.pal.brand),
        ],
      ),
    );
  }

  // ---- Moral ----
  Widget _moralView(AppState app) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 80),
        padding: const EdgeInsets.fromLTRB(50, 44, 50, 44),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(R.xl),
          boxShadow: Sh.lg,
          border: activeSkin.cardBorder,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 10),
            Text('Casharka — The Lesson', style: AppText.kicker.copyWith(color: app.pal.brand, fontSize: 22)),
            const SizedBox(height: 16),
            Text(story.moralSo, textAlign: TextAlign.center, style: AppText.display(size: 30, weight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(story.moralEn, textAlign: TextAlign.center, style: AppText.lead.copyWith(fontSize: 24)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KidButton(
                  variant: BtnVariant.ghost,
                  onTap: () => setState(() {
                    _scene = 0;
                    _q = 0;
                    _phase = _Phase.story;
                    _playNarration();
                  }),
                  child: const Text('↺ Read again'),
                ),
                const SizedBox(width: 22),
                KidButton(onTap: () => app.go('stories'), child: Text('More stories →', style: AppText.display(size: 24, weight: FontWeight.w800, color: Colors.white))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- small pieces ----
class _ListenChip extends StatelessWidget {
  final String flag, label;
  final VoidCallback onTap;
  const _ListenChip({required this.flag, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: context.read<AppState>().pal.brandSoft,
          borderRadius: BorderRadius.circular(R.pill),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(label, style: AppText.display(size: 20, weight: FontWeight.w800, color: context.read<AppState>().pal.brand)),
          const SizedBox(width: 6),
          Icon(Icons.volume_up_rounded, size: 22, color: context.read<AppState>().pal.brand),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String so, en;
  const _Bubble({required this.so, required this.en});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.lg),
        boxShadow: Sh.md,
        border: Border.all(color: const Color(0xFFFFC76B), width: 3),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(so, style: AppText.display(size: 22, weight: FontWeight.w800, color: const Color(0xFF1F2A33))),
        if (en.isNotEmpty) Text(en, style: AppText.body(size: 17, weight: FontWeight.w700, color: C.muted)),
      ]),
    );
  }
}

class _Dots extends StatelessWidget {
  final int total, index;
  final Color brand;
  const _Dots({required this.total, required this.index, required this.brand});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final on = i <= index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == index ? 18 : 12,
          height: i == index ? 18 : 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: on ? brand : C.line),
        );
      }),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final StoryOption option;
  final bool flash;
  final VoidCallback onTap;
  const _OptionCard({required this.option, required this.flash, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 230,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: flash ? const Color(0xFFFFE0E0) : C.card,
          borderRadius: BorderRadius.circular(R.lg),
          boxShadow: Sh.sm,
          border: Border.all(color: flash ? const Color(0xFFE0573D) : C.line, width: 3),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Img(option.emoji, size: 50),
          const SizedBox(height: 8),
          Text(option.labelSo, textAlign: TextAlign.center, maxLines: 2, style: AppText.display(size: 20, weight: FontWeight.w800)),
          Text(option.labelEn, textAlign: TextAlign.center, maxLines: 2, style: AppText.body(size: 15, weight: FontWeight.w700, color: C.muted)),
        ]),
      ),
    );
  }
}
