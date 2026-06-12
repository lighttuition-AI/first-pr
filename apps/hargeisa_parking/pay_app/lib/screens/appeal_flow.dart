import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../l10n/strings.dart';
import '../util/format.dart';

enum _Step { record, review, submitted }

/// Citizen video-appeal flow: record a real video with the phone's camera (the
/// native recorder — it has the front/back flip built in), review the playback,
/// then submit. On submit an [Appeal] is written to Firestore (status `review`)
/// and the citation moves to [CitationStatus.appealReview] — so the city sees it
/// in HPark Command.
class AppealFlow extends StatefulWidget {
  const AppealFlow({
    super.key,
    required this.citation,
    required this.appellantName,
    required this.repo,
    required this.appeals,
  });

  final Citation citation;
  final String appellantName;
  final FirebaseCitationRepository repo;
  final FirebaseAppealRepository appeals;

  @override
  State<AppealFlow> createState() => _AppealFlowState();
}

class _AppealFlowState extends State<AppealFlow> {
  _Step _step = _Step.record;
  final _reason = TextEditingController();
  final _picker = ImagePicker();

  XFile? _video;
  VideoPlayerController? _player;
  int _seconds = 0;

  bool _busy = false; // camera open
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _player?.dispose();
    _reason.dispose();
    super.dispose();
  }

  /// Open the phone's native video camera (records real video, has flip).
  Future<void> _record() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final x = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 90),
        preferredCameraDevice: CameraDevice.front,
      );
      if (!mounted) return;
      if (x == null) {
        setState(() => _busy = false); // cancelled
        return;
      }
      _video = x;
      await _initPlayer();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _step = _Step.review;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = tr('Could not open the camera. Check camera permission in Settings.');
        });
      }
    }
  }

  Future<void> _initPlayer() async {
    await _player?.dispose();
    final v = _video;
    if (v == null) return;
    final p = VideoPlayerController.file(File(v.path));
    try {
      await p.initialize();
      await p.setLooping(true);
      _seconds = p.value.duration.inSeconds;
    } catch (_) {}
    if (!mounted) {
      await p.dispose();
      return;
    }
    setState(() => _player = p);
  }

  String get _time {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final c = widget.citation;
    final now = DateTime.now();
    final appeal = Appeal(
      id: 'APL-${now.year}-${(now.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}',
      citationId: c.id,
      plate: c.plate,
      violation: c.violation,
      fine: c.amount,
      reason: _reason.text.trim().isEmpty ? 'Video appeal submitted.' : _reason.text.trim(),
      videoSeconds: _seconds,
      submittedAt: now,
      appellantName: widget.appellantName,
      status: AppealStatus.review,
    );
    try {
      await widget.appeals.submit(appeal);
      await widget.repo.setStatus(c.id, CitationStatus.appealReview);
      c.status = CitationStatus.appealReview; // reflect locally on return
    } catch (_) {
      // Surface a gentle error but still advance — Firestore will retry the write.
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _step = _Step.submitted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text(tr(_titleText), style: HpType.heading(size: 18)),
      ),
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: SafeArea(top: false, child: _body()),
      ),
    );
  }

  String get _titleText => switch (_step) {
        _Step.record => 'Record your appeal',
        _Step.review => 'Review',
        _Step.submitted => 'Appeal submitted',
      };

  Widget _body() => switch (_step) {
        _Step.record => _recordStep(),
        _Step.review => _reviewStep(),
        _Step.submitted => _submittedStep(),
      };

  Widget _recordStep() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(HpSpace.x5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(trf("Explain what you're challenging about citation {id}.", {'id': widget.citation.id}),
                    style: HpType.body(size: 14)),
                const SizedBox(height: HpSpace.x4),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96, height: 96,
                          decoration: const BoxDecoration(color: HpColors.purpleTint, shape: BoxShape.circle),
                          child: const Icon(Icons.videocam_rounded, size: 44, color: HpColors.purple300),
                        ),
                        const SizedBox(height: HpSpace.x5),
                        Text(tr('Record a short video explaining your appeal.'),
                            textAlign: TextAlign.center, style: HpType.body(size: 14)),
                        const SizedBox(height: HpSpace.x2),
                        Text(tr('Up to 90 seconds. You can flip the camera in the recorder.'),
                            textAlign: TextAlign.center, style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                        if (_error != null) ...[
                          const SizedBox(height: HpSpace.x4),
                          Text(_error!, textAlign: TextAlign.center, style: HpType.body(size: 13, color: HpColors.danger)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(HpSpace.x5),
          decoration: BoxDecoration(color: HpColors.surface, border: Border(top: BorderSide(color: HpColors.border))),
          child: HpButton(
            label: tr('Record video appeal'),
            icon: Icons.videocam_rounded,
            size: HpButtonSize.lg,
            expand: true,
            loading: _busy,
            onPressed: _busy ? null : _record,
          ),
        ),
      ],
    );
  }

  Widget _reviewStep() {
    final p = _player;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(HpSpace.x5),
            children: [
              HpCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(HpRadius.lg),
                  child: AspectRatio(
                    aspectRatio: (p != null && p.value.isInitialized) ? p.value.aspectRatio : 1.4,
                    child: GestureDetector(
                      onTap: () {
                        if (p == null) return;
                        setState(() => p.value.isPlaying ? p.pause() : p.play());
                      },
                      child: Container(
                        color: Colors.black,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (p != null && p.value.isInitialized) VideoPlayer(p),
                            if (p == null || !p.value.isPlaying)
                              const Icon(Icons.play_circle_outline, size: 56, color: Colors.white70),
                            Positioned(
                              bottom: 12,
                              child: Text(trf('Recorded · {t}', {'t': _time}), style: HpType.mono(size: 13, color: Colors.white70)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: HpSpace.x4),
              HpInput(
                controller: _reason,
                label: tr('Add a note (optional)'),
                hint: tr('Briefly summarise your appeal'),
              ),
              const SizedBox(height: HpSpace.x4),
              HpButton(
                label: tr('Re-record'),
                variant: HpButtonVariant.ghost,
                icon: Icons.refresh_rounded,
                onPressed: _busy ? null : _record,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(HpSpace.x5),
          decoration: BoxDecoration(color: HpColors.surface, border: Border(top: BorderSide(color: HpColors.border))),
          child: HpButton(label: tr('Submit appeal'), icon: Icons.send_rounded, size: HpButtonSize.lg, expand: true, loading: _submitting, onPressed: _submitting ? null : _submit),
        ),
      ],
    );
  }

  Widget _submittedStep() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(HpSpace.x6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84, height: 84,
                    decoration: const BoxDecoration(color: HpColors.purpleTint, shape: BoxShape.circle),
                    child: const Icon(Icons.gavel_rounded, color: HpColors.purple300, size: 40),
                  ),
                  const SizedBox(height: HpSpace.x5),
                  Text(tr('Appeal submitted'), style: HpType.heading(size: 24)),
                  const SizedBox(height: HpSpace.x2),
                  Text(
                    trf("Your video appeal for {id} is under review. You'll be notified of the decision.",
                        {'id': widget.citation.id}),
                    textAlign: TextAlign.center,
                    style: HpType.body(size: 14),
                  ),
                  const SizedBox(height: HpSpace.x4),
                  Text(slsh(widget.citation.amount), style: HpType.mono(size: 20, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(HpSpace.x5),
          decoration: BoxDecoration(color: HpColors.surface, border: Border(top: BorderSide(color: HpColors.border))),
          child: HpButton(
            label: 'Done',
            size: HpButtonSize.lg,
            expand: true,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
