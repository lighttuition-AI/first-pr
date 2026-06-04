// Child personalization — age, practise topics, avatar, and the
// "Your adventure is ready!" confirmation.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/image_service.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/avatar.dart';
import '../widgets/branding.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';
import '../widgets/robo.dart';
import '../widgets/speech_bubble.dart';

mixin _AutoVo<T extends StatefulWidget> on State<T> {
  void autoVo(String id, String text, [int delay = 450]) {
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) context.read<VoService>().play(id, text);
    });
  }
}

Widget _arrowLabel(String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [Text(label), const SizedBox(width: 12), const Icon(Icons.arrow_forward_rounded)],
    );

// ---------------- Age ----------------
class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});
  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> with _AutoVo {
  @override
  void initState() {
    super.initState();
    final v = kScreenVo['age']!;
    autoVo(v.id, v.text);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final v = kScreenVo['age']!;
    return Container(
      color: C.paper,
      child: Column(
        children: [
          SetupHeader(
              index: 0,
              total: 3,
              // Extra children come from "Add a child" → back returns home;
              // the very first child comes from onboarding.
              onBack: app.children.length > 1
                  ? () => app.go('home')
                  : () => app.go('onb-${kOnboarding.length - 1}')),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpeechBubble(text: 'How old is your child?', tail: Tail.down, voId: v.id, voText: v.text),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final a in [2, 3, 4, 5, 6, 7, 8])
                      _AgeTile(age: a, selected: app.age == a, onTap: () => app.setAge(a)),
                  ],
                ),
                const SizedBox(height: 50),
                KidButton(
                  large: true,
                  onTap: app.age != null ? () => app.go('practise') : null,
                  child: _arrowLabel('Continue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeTile extends StatelessWidget {
  final int age;
  final bool selected;
  final VoidCallback onTap;
  const _AgeTile({required this.age, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(0, selected ? -6 : 0, 0),
        width: 150,
        height: 168,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.lg),
          boxShadow: Sh.sm,
          border: Border.all(color: selected ? pal.brand : Colors.transparent, width: 4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$age',
                style: AppText.display(size: 72, weight: FontWeight.w800, color: selected ? pal.brand : C.ink)),
            Text('years', style: AppText.body(size: 24, weight: FontWeight.w700, color: C.muted)),
          ],
        ),
      ),
    );
  }
}

// ---------------- Practise topics ----------------
class PractiseScreen extends StatefulWidget {
  const PractiseScreen({super.key});
  @override
  State<PractiseScreen> createState() => _PractiseScreenState();
}

class _PractiseScreenState extends State<PractiseScreen> with _AutoVo {
  @override
  void initState() {
    super.initState();
    final v = kScreenVo['practise']!;
    autoVo(v.id, v.text);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final v = kScreenVo['practise']!;
    final sel = app.topics;
    return Container(
      color: C.paper,
      child: Column(
        children: [
          SetupHeader(index: 1, total: 3, onBack: () => app.go('age')),
          const SizedBox(height: 6),
          SpeechBubble(text: 'What should we practise?', tail: Tail.down, voId: v.id, voText: v.text),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 22,
                  runSpacing: 22,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final t in kTopics)
                      _TopicTile(topic: t, selected: sel.contains(t.id), onTap: () => app.toggleTopic(t.id)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sel.isNotEmpty ? '${sel.length} chosen' : 'Pick at least one',
                    style: AppText.body(size: 24, weight: FontWeight.w700, color: C.muted)),
                const SizedBox(width: 24),
                KidButton(
                  large: true,
                  onTap: sel.isNotEmpty ? () => app.go('avatar') : null,
                  child: _arrowLabel('Continue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final Topic topic;
  final bool selected;
  final VoidCallback onTap;
  const _TopicTile({required this.topic, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    final tc = topic.color(pal);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(0, selected ? -6 : 0, 0),
        width: 270,
        constraints: const BoxConstraints(minHeight: 190),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.lg),
          boxShadow: Sh.sm,
          border: Border.all(color: selected ? tc : Colors.transparent, width: 4),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Img(topic.emoji, size: 64),
                  const SizedBox(height: 12),
                  Text(topic.label,
                      textAlign: TextAlign.center,
                      style: AppText.display(size: 27, weight: FontWeight.w700)),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: tc, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Avatar ----------------
class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});
  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> with _AutoVo {
  @override
  void initState() {
    super.initState();
    final v = kScreenVo['avatar']!;
    autoVo(v.id, v.text);
  }

  Future<void> _addPhoto() async {
    final bytes = await context.read<ImageService>().pickRaw();
    if (bytes != null && mounted) {
      context.read<AppState>().setPhoto(base64Encode(bytes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final v = kScreenVo['avatar']!;
    final chosen = app.avatar != null || app.photo != null;
    return Container(
      color: C.paper,
      child: Column(
        children: [
          SetupHeader(index: 2, total: 3, onBack: () => app.go('practise')),
          const SizedBox(height: 6),
          SpeechBubble(text: 'Choose your buddy!', tail: Tail.down, voId: v.id, voText: v.text),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 22,
                  runSpacing: 22,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final a in kAvatars)
                      _AvatarPick(
                        selected: app.avatar == a.id,
                        outline: a.color,
                        onTap: () => app.setAvatar(a.id),
                        child: Avatar(data: a, size: 108),
                      ),
                    _AvatarPick(
                      selected: app.photo != null,
                      outline: C.muted,
                      onTap: _addPhoto,
                      child: app.photoBytes != null
                          ? ClipOval(child: Image.memory(app.photoBytes!, width: 108, height: 108, fit: BoxFit.cover))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('📷', style: TextStyle(fontSize: 44)),
                                Text('Add photo', style: TextStyle(fontSize: 18, color: C.muted, fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: KidButton(
              large: true,
              onTap: chosen ? () => app.go('ready') : null,
              child: _arrowLabel("That's me!"),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPick extends StatelessWidget {
  final bool selected;
  final Color outline;
  final VoidCallback onTap;
  final Widget child;
  const _AvatarPick({required this.selected, required this.outline, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(0, selected ? -6 : 0, 0),
        width: 150,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.lg),
          boxShadow: Sh.sm,
          border: Border.all(color: selected ? outline : Colors.transparent, width: 4),
        ),
        child: child,
      ),
    );
  }
}

// ---------------- Adventure ready ----------------
class ReadyScreen extends StatefulWidget {
  const ReadyScreen({super.key});
  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen> with _AutoVo {
  @override
  void initState() {
    super.initState();
    final v = kScreenVo['ready']!;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<VoService>().play(v.id, v.text);
      context.read<FxController>().fire(intensity: context.read<AppState>().celebration);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final v = kScreenVo['ready']!;
    final av = app.avatar != null ? kAvatars.firstWhere((a) => a.id == app.avatar) : null;
    final n = app.topics.length;
    return Container(
      color: app.pal.brandSoft,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (app.mascot) const Robo(size: 240, pose: 'cheer'),
                const SizedBox(width: 10),
                if (app.photoBytes != null)
                  ClipOval(child: Image.memory(app.photoBytes!, width: 150, height: 150, fit: BoxFit.cover))
                else if (av != null)
                  Avatar(data: av, size: 170, bouncing: true),
              ],
            ),
            const SizedBox(height: 16),
            Text('Your adventure is ready!',
                textAlign: TextAlign.center,
                style: AppText.display(size: 88, weight: FontWeight.w800, height: 1.02)),
            const SizedBox(height: 14),
            Text('Robo built a personal path with $n favourite ${n == 1 ? "topic" : "topics"}.',
                style: AppText.lead.copyWith(fontSize: 32)),
            const SizedBox(height: 40),
            KidButton(
              large: true,
              onTap: () => app.go('home'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('🚀', style: TextStyle(fontSize: 34)), SizedBox(width: 12), Text("Let's play!")],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<VoService>().play(v.id, v.text),
              child: Text('🔊 Hear it again',
                  style: AppText.body(size: 24, weight: FontWeight.w700, color: C.inkSoft)),
            ),
          ],
        ),
      ),
    );
  }
}
