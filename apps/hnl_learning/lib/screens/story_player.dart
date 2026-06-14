// Story player (Somali only) — reads a folktale scene by scene, then asks a
// couple of questions and shows the moral. Each scene has an original animated
// scene (StorySceneArt) PLUS a still picture panel the parent can tap to
// enlarge (and replace in the Picture Studio), a Somali narration (tap to hear,
// recordable) and an optional character speech bubble. Background music is OFF
// by default — the 🎵 button turns it on.
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
  late final VoService _vo;
  int _scene = 0;
  int _q = 0;
  _Phase _phase = _Phase.story;
  String? _wrong;

  @override
  void initState() {
    super.initState();
    _vo = context.read<VoService>();
    story = storyById(context.read<AppState>().currentStory ?? kStories.first.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _say();
      _vo.startStoryMusic(); // off unless the grown-up turned it on
    });
  }

  @override
  void dispose() {
    _vo.stopStoryMusic();
    super.dispose();
  }

  void _say() {
    if (!mounted) return;
    final s = story.scenes[_scene];
    _vo.play(storyVoId(story.id, s.id), s.narration, lang: 'so-SO');
  }

  void _next() {
    if (_scene < story.scenes.length - 1) {
      setState(() => _scene++);
      _say();
    } else {
      setState(() => _phase = story.questions.isEmpty ? _Phase.moral : _Phase.questions);
    }
  }

  void _prev() {
    if (_scene > 0) {
      setState(() => _scene--);
      _say();
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
      setState(() => _wrong = '${q.id}-${o.label}');
    }
  }

  void _enlarge(String pic, String picId) {
    showDialog<void>(
      context: context,
      barrierColor: C.inkA(.6),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Container(
            width: 560,
            height: 560,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.xl), boxShadow: Sh.lg),
            child: Img(pic, id: picId, size: 320),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final bg = _phase == _Phase.story
        ? [story.scenes[_scene].bgTop, story.scenes[_scene].bgBottom]
        : const [Color(0xFFFFF0D6), Color(0xFFFCDFB0)];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: bg)),
      child: Stack(
        children: [
          Positioned(top: 24, left: 24, child: IconCircle(Icons.arrow_back_rounded, size: 64, onTap: () => app.go('stories'))),
          Positioned(top: 30, left: 0, right: 0, child: Center(child: Text(story.title, style: AppText.display(size: 26, weight: FontWeight.w800)))),
          const Positioned(top: 24, right: 24, child: _MusicButton()),
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

  Widget _sceneView(AppState app) {
    final s = story.scenes[_scene];
    final last = _scene == story.scenes.length - 1;
    final picId = storyPicId(story.id, s.id);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The animation (continues), with the speech bubble.
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      Positioned.fill(child: StorySceneArt(art: s.art)),
                      if (s.speaker != Speaker.narrator && s.line != null)
                        Align(
                          alignment: s.speaker == Speaker.left ? Alignment.topLeft : Alignment.topRight,
                          child: _Bubble(text: s.line!),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // The still picture (tap to enlarge; editable in Picture Studio).
                Expanded(
                  flex: 2,
                  child: Pressable(
                    onTap: () => _enlarge(s.picture, picId),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(R.lg),
                        boxShadow: Sh.sm,
                        border: Border.all(color: const Color(0xFFFFC76B), width: 3),
                      ),
                      child: Column(
                        children: [
                          Expanded(child: Center(child: Img(s.picture, id: picId, size: 100))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.zoom_in_rounded, size: 20, color: C.muted),
                              const SizedBox(width: 6),
                              Text('Sawir', style: AppText.body(size: 18, weight: FontWeight.w800, color: C.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Somali narration + a single Somali "listen" button.
        Container(
          margin: const EdgeInsets.fromLTRB(40, 8, 40, 8),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          decoration: BoxDecoration(color: C.card.withValues(alpha: .94), borderRadius: BorderRadius.circular(R.lg), boxShadow: Sh.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.narration, textAlign: TextAlign.center, style: AppText.display(size: 24, weight: FontWeight.w700)),
              const SizedBox(height: 12),
              _ListenChip(onTap: _say),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 22),
          child: Row(
            children: [
              if (_scene > 0) KidButton(variant: BtnVariant.ghost, onTap: _prev, child: const Text('◀ Dib')) else const SizedBox(width: 10),
              const Spacer(),
              _Dots(total: story.scenes.length, index: _scene, brand: app.pal.brand),
              const Spacer(),
              KidButton(onTap: _next, child: Text(last ? 'Su\'aalo →' : 'Xiga →', style: AppText.display(size: 26, weight: FontWeight.w800, color: Colors.white))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _questionView(AppState app) {
    final q = story.questions[_q];
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 10, 50, 30),
      child: Column(
        children: [
          const Spacer(),
          const Text('❓', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(q.q, textAlign: TextAlign.center, style: AppText.display(size: 30, weight: FontWeight.w800)),
          const SizedBox(height: 26),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            children: [for (final o in q.options) _OptionCard(option: o, flash: _wrong == '${q.id}-${o.label}', onTap: () => _answer(q, o))],
          ),
          const Spacer(),
          _Dots(total: story.questions.length, index: _q, brand: app.pal.brand),
        ],
      ),
    );
  }

  Widget _moralView(AppState app) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 80),
        padding: const EdgeInsets.fromLTRB(50, 44, 50, 44),
        decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.xl), boxShadow: Sh.lg, border: activeSkin.cardBorder),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 10),
            Text('Casharka', style: AppText.kicker.copyWith(color: app.pal.brand, fontSize: 22)),
            const SizedBox(height: 16),
            Text(story.moral, textAlign: TextAlign.center, style: AppText.display(size: 30, weight: FontWeight.w800)),
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
                    _say();
                  }),
                  child: const Text('↺ Mar kale'),
                ),
                const SizedBox(width: 22),
                KidButton(onTap: () => app.go('stories'), child: Text('Sheekooyin kale →', style: AppText.display(size: 24, weight: FontWeight.w800, color: Colors.white))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- small pieces ----
class _MusicButton extends StatelessWidget {
  const _MusicButton();
  @override
  Widget build(BuildContext context) {
    final vo = context.watch<VoService>();
    final on = vo.storyMusicOn;
    return Tooltip(
      message: on ? 'Muusik shidan — taabo si aad u demiso' : 'Muusik damay — taabo si aad u shidato',
      child: Pressable(
        onTap: () => vo.setStoryMusicOn(!on),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: C.card, shape: BoxShape.circle, boxShadow: Sh.sm, border: activeSkin.cardBorder),
          child: Text(on ? '🎵' : '🔇', style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
  }
}

class _ListenChip extends StatelessWidget {
  final VoidCallback onTap;
  const _ListenChip({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final pal = context.read<AppState>().pal;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(color: pal.brandSoft, borderRadius: BorderRadius.circular(R.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.volume_up_rounded, size: 24, color: pal.brand),
          const SizedBox(width: 10),
          Text('Dhegayso', style: AppText.display(size: 22, weight: FontWeight.w800, color: pal.brand)),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  const _Bubble({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.lg),
        boxShadow: Sh.md,
        border: Border.all(color: const Color(0xFFFFC76B), width: 3),
      ),
      child: Text(text, style: AppText.display(size: 22, weight: FontWeight.w800, color: const Color(0xFF1F2A33))),
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
          Text(option.label, textAlign: TextAlign.center, maxLines: 3, style: AppText.display(size: 20, weight: FontWeight.w800)),
        ]),
      ),
    );
  }
}
