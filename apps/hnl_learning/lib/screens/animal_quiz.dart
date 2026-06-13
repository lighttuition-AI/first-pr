// ============================================================
// AnimalQuizScreen — one continent's shuffled 20-animal session.
// ------------------------------------------------------------
// Big friendly picture of an animal (emoji default; an uploaded real
// photo in slot 'animal-<id>' overrides it) + two bright buttons that
// announce its name in English / Somali. English uses device TTS; Somali
// plays the family's recording (record inline with the mic) or attempts
// Somali TTS. Tap Next → confetti → next animal, until all 20 are done.
// ============================================================
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../models/animals.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';

class AnimalQuizScreen extends StatefulWidget {
  const AnimalQuizScreen({super.key});

  @override
  State<AnimalQuizScreen> createState() => _AnimalQuizScreenState();
}

class _AnimalQuizScreenState extends State<AnimalQuizScreen> {
  final AudioRecorder _rec = AudioRecorder();
  String? _recordingId; // the VO id currently being recorded (name or sound), or null
  bool _done = false;

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  /// Record (or finish recording) clip [id]. Used both for the Somali name and
  /// the animal sound — only one records at a time.
  Future<void> _toggleRecord(VoService vo, String id) async {
    if (_recordingId == id) {
      final path = await _rec.stop();
      if (mounted) setState(() => _recordingId = null);
      if (path != null) vo.registerRecording(id, path);
    } else if (_recordingId != null) {
      // a different clip is recording — finish that one first
      final prev = _recordingId!;
      final path = await _rec.stop();
      if (path != null) vo.registerRecording(prev, path);
      if (mounted) setState(() => _recordingId = null);
    } else {
      // Starting a fresh recording is grown-ups-only — gate it behind the same
      // 1-2-3-4 child-lock as Settings so kids can't overwrite the family's
      // sounds without an elder present. (Stopping above never needs the code.)
      context.read<AppState>().requireParent(() => _beginRecord(vo, id));
    }
  }

  /// Actually start recording clip [id] (only reached after the grown-up lock).
  Future<void> _beginRecord(VoService vo, String id) async {
    try {
      if (!await _rec.hasPermission()) return;
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/vo_$id.m4a';
      await _rec.start(const RecordConfig(), path: path);
      if (mounted) setState(() => _recordingId = id);
    } catch (_) {/* recording unavailable here */}
  }

  Future<void> _stopRecIfNeeded() async {
    if (_recordingId != null) {
      try {
        await _rec.stop();
      } catch (_) {}
      _recordingId = null;
    }
  }

  void _next(AppState app) {
    context.read<FxController>().fire(intensity: app.celebration);
    _stopRecIfNeeded();
    if (!app.nextAnimal()) {
      setState(() => _done = true);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final vo = context.watch<VoService>();
    final continent = app.currentContinent;
    final animal = app.currentAnimal;
    if (continent == null || animal == null) {
      return const SizedBox.shrink();
    }

    if (_done) return _FinishCard(continent: continent, onDone: () => app.go('continents'));

    final total = app.animalQueue.length;
    final idx = app.animalIndex;
    final enId = 'animal-${animal.id}-en';
    final soId = 'animal-${animal.id}-so';
    final soundId = 'animal-${animal.id}-sound';

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(continent.color, Colors.white, .62)!, Color.lerp(continent.color, Colors.white, .82)!],
        ),
      ),
      child: Column(
        children: [
          // ---- header: back · continent · progress ----
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
            child: Row(
              children: [
                IconCircle(Icons.arrow_back_rounded, onTap: () => app.go('continents')),
                const SizedBox(width: 16),
                Text('${continent.emoji}  ${continent.name}',
                    style: AppText.display(size: 26, weight: FontWeight.w800)),
                const Spacer(),
                Text('${idx + 1} / $total',
                    style: AppText.display(size: 26, weight: FontWeight.w800, color: C.inkSoft)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(R.pill),
              child: LinearProgressIndicator(
                value: (idx + 1) / total,
                minHeight: 12,
                backgroundColor: Colors.white.withValues(alpha: .55),
                valueColor: AlwaysStoppedAnimation(continent.color),
              ),
            ),
          ),
          // ---- the animal ----
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(R.xl),
                      boxShadow: Sh.md,
                      border: activeSkin.cardBorder,
                    ),
                    alignment: Alignment.center,
                    child: Img(animal.emoji, id: 'animal-${animal.id}', size: 180, fill: true, radius: R.xl),
                  ),
                  const SizedBox(height: 14),
                  Text(animal.en, style: AppText.display(size: 40, weight: FontWeight.w800)),
                  Text(animal.so, style: AppText.body(size: 24, weight: FontWeight.w700, color: C.muted)),
                  const SizedBox(height: 18),
                  // ---- name buttons + the big animal-sound button ----
                  SizedBox(
                    width: 540,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _LangButton(
                                flag: '🇬🇧',
                                label: 'English',
                                color: const Color(0xFF3F7FD6),
                                speaking: vo.isActive(enId),
                                onTap: () => vo.play(enId, animal.en, lang: 'en-US'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _LangButton(
                                flag: '🇸🇴',
                                label: 'Somali',
                                color: const Color(0xFF22A0D6),
                                speaking: vo.isActive(soId),
                                onTap: () => vo.play(soId, animal.so, lang: 'so-SO'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // inline Somali-name recorder (for parents)
                            _MicButton(
                              recording: _recordingId == soId,
                              has: vo.has(soId),
                              onTap: () => _toggleRecord(vo, soId),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // the hero: hear this animal's sound (hold to record a real one)
                        _SoundButton(
                          playing: vo.isActive(soundId),
                          recording: _recordingId == soundId,
                          hasReal: vo.has(soundId),
                          onTap: () => vo.play(soundId, animal.sound),
                          onLongPress: () => _toggleRecord(vo, soundId),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ---- next ----
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 26),
            child: Align(
              alignment: Alignment.centerRight,
              child: KidButton(
                large: true,
                onTap: () => _next(app),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(idx + 1 >= total ? 'Finish' : 'Next',
                        style: AppText.display(size: 28, weight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String flag, label;
  final Color color;
  final bool speaking;
  final VoidCallback onTap;
  const _LangButton(
      {required this.flag, required this.label, required this.color, required this.speaking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: speaking ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.lerp(color, Colors.white, .18)!, color],
            ),
            borderRadius: BorderRadius.circular(R.lg),
            boxShadow: [BoxShadow(color: color.withValues(alpha: .45), blurRadius: 16, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.display(size: 26, weight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Icon(speaking ? Icons.volume_up_rounded : Icons.volume_up_outlined, color: Colors.white, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool recording, has;
  final VoidCallback onTap;
  const _MicButton({required this.recording, required this.has, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: recording ? 'Tap to stop' : 'Record the Somali name',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: recording ? const Color(0xFFE0573D) : C.card,
            shape: BoxShape.circle,
            boxShadow: Sh.sm,
            border: Border.all(color: const Color(0xFFE0573D), width: 2.5),
          ),
          child: Icon(
            recording ? Icons.stop_rounded : Icons.mic_rounded,
            color: recording ? Colors.white : const Color(0xFFE0573D),
            size: 30,
          ),
        ),
      ),
    );
  }
}

/// The hero "hear the animal's sound" button — bright, full width, with an
/// animated sound-wave while playing. Tap to play; press-and-hold to record a
/// real sound for this animal (stored under `animal-ID-sound`).
class _SoundButton extends StatelessWidget {
  final bool playing, recording, hasReal;
  final VoidCallback onTap, onLongPress;
  const _SoundButton({
    required this.playing,
    required this.recording,
    required this.hasReal,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFFC24B);
    const orange = Color(0xFFFF7A1A);
    const rec = Color(0xFFE0573D);
    final glow = recording ? rec : orange;
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: 0.97,
      child: AnimatedScale(
        scale: playing ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: recording ? [Color.lerp(rec, Colors.white, .15)!, rec] : const [amber, orange],
            ),
            borderRadius: BorderRadius.circular(R.lg),
            boxShadow: [BoxShadow(color: glow.withValues(alpha: .5), blurRadius: 22, offset: const Offset(0, 10))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 42,
                height: 34,
                child: Center(
                  child: recording
                      ? const Icon(Icons.fiber_manual_record_rounded, color: Colors.white, size: 30)
                      : (playing
                          ? const _SoundWave()
                          : const Icon(Icons.volume_up_rounded, color: Colors.white, size: 34)),
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  recording ? 'Recording… release to save' : (playing ? 'Listen!' : 'Hear the sound'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(size: 30, weight: FontWeight.w800, color: Colors.white),
                ),
              ),
              if (hasReal && !recording) ...[
                const SizedBox(width: 10),
                const Text('🎙️', style: TextStyle(fontSize: 22)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A little 4-bar equalizer that bounces while a sound plays.
class _SoundWave extends StatefulWidget {
  const _SoundWave();
  @override
  State<_SoundWave> createState() => _SoundWaveState();
}

class _SoundWaveState extends State<_SoundWave> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 750))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(4, (i) {
          final phase = (_c.value + i * 0.2) % 1.0;
          final h = 8.0 + 22.0 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi));
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: 5,
            height: h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
          );
        }),
      ),
    );
  }
}

class _FinishCard extends StatelessWidget {
  final Continent continent;
  final VoidCallback onDone;
  const _FinishCard({required this.continent, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(continent.color, Colors.white, .55)!, Color.lerp(continent.color, Colors.white, .8)!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(continent.emoji, style: const TextStyle(fontSize: 90)),
            const SizedBox(height: 8),
            Text('Great job!', style: AppText.display(size: 48, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('You met all the ${continent.name} animals!',
                style: AppText.body(size: 24, weight: FontWeight.w700, color: C.inkSoft)),
            const SizedBox(height: 26),
            KidButton(
              large: true,
              onTap: onDone,
              child: Text('Back to the map',
                  style: AppText.display(size: 26, weight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
