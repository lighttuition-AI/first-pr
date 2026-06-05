// ============================================================
// ProduceQuiz — one shuffled fruit/veggie guessing session.
// ------------------------------------------------------------
// A BIG friendly picture (emoji default; an uploaded real photo in Img slot
// '<id>' overrides it) + the name in English / Somali, each with its own
// speaker button AND its own record mic (a grown-up can voice both, inline or
// in the Voiceover Studio). Tap Next → confetti → next item, until all done;
// the session reshuffles up to 20 fresh items next time (AppState.startProduce).
// Rendered full-area inside the game shell (GameType.produceQuiz).
// ============================================================
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/img_widget.dart';
import '../widgets/kid_button.dart';
import '../widgets/robo.dart';

class ProduceQuiz extends StatefulWidget {
  final String category; // 'fruit' | 'veggie'
  const ProduceQuiz({super.key, required this.category});

  @override
  State<ProduceQuiz> createState() => _ProduceQuizState();
}

class _ProduceQuizState extends State<ProduceQuiz> {
  final AudioRecorder _rec = AudioRecorder();
  String? _recordingId; // the VO id currently recording, or null
  bool _done = false;

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord(VoService vo, String id) async {
    if (_recordingId == id) {
      final path = await _rec.stop();
      if (mounted) setState(() => _recordingId = null);
      if (path != null) vo.registerRecording(id, path);
    } else if (_recordingId != null) {
      final prev = _recordingId!;
      final path = await _rec.stop();
      if (path != null) vo.registerRecording(prev, path);
      if (mounted) setState(() => _recordingId = null);
    } else {
      try {
        if (!await _rec.hasPermission()) return;
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/vo_$id.m4a';
        await _rec.start(const RecordConfig(), path: path);
        if (mounted) setState(() => _recordingId = id);
      } catch (_) {/* recording unavailable here */}
    }
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
    if (!app.nextProduce()) {
      setState(() => _done = true);
    } else {
      setState(() {});
    }
  }

  void _again(AppState app) {
    _stopRecIfNeeded();
    app.startProduce(widget.category);
    setState(() => _done = false);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final vo = context.watch<VoService>();
    final item = app.currentProduce;
    final isFruit = widget.category == 'fruit';
    final accent = isFruit ? const Color(0xFFE8553D) : const Color(0xFFF0822E);

    if (_done) return _DoneCard(isFruit: isFruit, onAgain: () => _again(app), onHome: () => app.go('home'));
    if (item == null) return const SizedBox.shrink();

    final total = app.produceQueue.length;
    final idx = app.produceIndex;
    final enId = '${item.id}-en';
    final soId = '${item.id}-so';

    return Column(
      children: [
        // progress
        Align(
          alignment: Alignment.centerRight,
          child: Text('${idx + 1} / $total',
              style: AppText.display(size: 26, weight: FontWeight.w800, color: C.inkSoft)),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---- the BIG picture ----
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    color: C.card,
                    borderRadius: BorderRadius.circular(R.xl),
                    boxShadow: Sh.md,
                    border: activeSkin.cardBorder,
                  ),
                  alignment: Alignment.center,
                  child: Img(item.emoji, id: item.id, size: 230, fill: true, radius: R.xl),
                ),
                const SizedBox(height: 12),
                Text(item.en, style: AppText.display(size: 42, weight: FontWeight.w800)),
                Text(item.so, style: AppText.body(size: 26, weight: FontWeight.w700, color: C.muted)),
                const SizedBox(height: 16),
                // ---- English / Somali, each with a speaker + a record mic ----
                SizedBox(
                  width: 560,
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
                              onTap: () => vo.play(enId, item.en, lang: 'en-US'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _MicButton(
                            recording: _recordingId == enId,
                            has: vo.has(enId),
                            onTap: () => _toggleRecord(vo, enId),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _LangButton(
                              flag: '🇸🇴',
                              label: 'Somali',
                              color: accent,
                              speaking: vo.isActive(soId),
                              onTap: () => vo.play(soId, item.so, lang: 'so-SO'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _MicButton(
                            recording: _recordingId == soId,
                            has: vo.has(soId),
                            onTap: () => _toggleRecord(vo, soId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ---- next / finish ----
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
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
    );
  }
}

class _DoneCard extends StatelessWidget {
  final bool isFruit;
  final VoidCallback onAgain, onHome;
  const _DoneCard({required this.isFruit, required this.onAgain, required this.onHome});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(50, 40, 50, 40),
        decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(R.xl), boxShadow: Sh.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isFruit ? 'You met all the fruits! 🍎' : 'You met all the veggies! 🥕',
                textAlign: TextAlign.center, style: AppText.display(size: 44, weight: FontWeight.w800)),
            const SizedBox(height: 20),
            if (app.mascot) const Robo(size: 180, pose: 'cheer'),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KidButton(
                  variant: BtnVariant.ghost,
                  onTap: onHome,
                  child: const Text('Done'),
                ),
                const SizedBox(width: 16),
                KidButton(
                  large: true,
                  onTap: onAgain,
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Again'),
                    SizedBox(width: 10),
                    Icon(Icons.refresh_rounded),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- a bright language button (speaker) ----
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

// ---- a record mic for the parent (records that language's clip) ----
class _MicButton extends StatelessWidget {
  final bool recording, has;
  final VoidCallback onTap;
  const _MicButton({required this.recording, required this.has, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: recording ? 'Tap to stop' : 'Record the name',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: recording ? const Color(0xFFE0573D) : (has ? const Color(0xFF15B886) : C.card),
            shape: BoxShape.circle,
            boxShadow: Sh.sm,
            border: Border.all(color: const Color(0xFFE0573D), width: 2.5),
          ),
          child: Icon(
            recording ? Icons.stop_rounded : (has ? Icons.check_rounded : Icons.mic_rounded),
            color: recording || has ? Colors.white : const Color(0xFFE0573D),
            size: 30,
          ),
        ),
      ),
    );
  }
}
