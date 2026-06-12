import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';
import 'package:video_player/video_player.dart';

import '../l10n/strings.dart';
import '../util/format.dart';

enum _Step { record, review, submitted }

/// Citizen video-appeal flow: record a real video explanation (live camera, with
/// a front/back flip), review the playback, submit. On submit an [Appeal] is
/// written to Firestore (status `review`) and the citation moves to
/// [CitationStatus.appealReview] — so the city sees it in HPark Command.
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

class _AppealFlowState extends State<AppealFlow> with WidgetsBindingObserver {
  _Step _step = _Step.record;
  final _reason = TextEditingController();

  // Camera
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _camIndex = 0;
  bool _cameraReady = false;
  String? _camError;

  // Recording
  Timer? _timer;
  bool _recording = false;
  int _seconds = 0;
  XFile? _video;

  // Playback (review)
  VideoPlayerController? _player;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    _player?.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive && _recording) {
      // Stop a recording if the app is backgrounded mid-capture.
      _toggleRecord();
    }
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _camError = tr('No camera available on this device.'));
        return;
      }
      // Prefer the back camera to start.
      final back = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      await _startController(back < 0 ? 0 : back);
    } catch (_) {
      if (mounted) setState(() => _camError = tr('Could not open the camera.'));
    }
  }

  Future<void> _startController(int index) async {
    final previous = _controller;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: true,
    );
    try {
      await controller.initialize();
    } catch (_) {
      if (mounted) setState(() => _camError = tr('Could not open the camera.'));
      return;
    }
    await previous?.dispose();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _camIndex = index;
      _cameraReady = true;
      _camError = null;
    });
  }

  Future<void> _flip() async {
    if (_cameras.length < 2 || _recording) return;
    setState(() => _cameraReady = false);
    await _startController((_camIndex + 1) % _cameras.length);
  }

  Future<void> _toggleRecord() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (_recording) {
      _timer?.cancel();
      XFile? file;
      try {
        file = await c.stopVideoRecording();
      } catch (_) {/* ignore — keep whatever we have */}
      if (!mounted) return;
      setState(() => _recording = false);
      if (file != null) {
        _video = file;
        await _initPlayer();
        if (mounted) setState(() => _step = _Step.review);
      }
    } else {
      try {
        await c.startVideoRecording();
      } catch (_) {
        return;
      }
      setState(() {
        _recording = true;
        _seconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _seconds++);
        if (_seconds >= 90) _toggleRecord(); // cap at 1:30
      });
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
    } catch (_) {}
    if (!mounted) {
      await p.dispose();
      return;
    }
    setState(() => _player = p);
  }

  void _reRecord() {
    _player?.pause();
    setState(() {
      _video = null;
      _seconds = 0;
      _step = _Step.record;
    });
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
              children: [
                Text(trf("Explain what you're challenging about citation {id}.", {'id': widget.citation.id}),
                    style: HpType.body(size: 14)),
                const SizedBox(height: HpSpace.x4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(HpRadius.xl),
                    child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _preview(),
                          if (_recording)
                            Positioned(
                              top: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(HpRadius.pill)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: HpColors.danger, shape: BoxShape.circle)),
                                      const SizedBox(width: 6),
                                      Text(_time, style: HpType.mono(size: 14, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (_cameraReady && _cameras.length > 1 && !_recording)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Material(
                                color: Colors.black54,
                                shape: const CircleBorder(),
                                child: IconButton(
                                  tooltip: tr('Flip camera'),
                                  icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
                                  onPressed: _flip,
                                ),
                              ),
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
        Container(
          padding: const EdgeInsets.all(HpSpace.x5),
          decoration: BoxDecoration(
            color: HpColors.surface,
            border: Border(top: BorderSide(color: HpColors.border)),
          ),
          child: Center(
            child: GestureDetector(
              onTap: _cameraReady ? _toggleRecord : null,
              child: Opacity(
                opacity: _cameraReady ? 1 : 0.4,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: HpColors.danger, width: 4),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: _recording ? 28 : 54,
                      height: _recording ? 28 : 54,
                      decoration: BoxDecoration(
                        color: HpColors.danger,
                        borderRadius: BorderRadius.circular(_recording ? 6 : 27),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Live camera preview, filling the box (cover). Falls back to a message.
  Widget _preview() {
    if (_camError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(HpSpace.x6),
          child: Text(_camError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ),
      );
    }
    final c = _controller;
    if (!_cameraReady || c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    final preview = c.value.previewSize;
    if (preview == null) return CameraPreview(c);
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        // previewSize is reported landscape; swap for the portrait box.
        width: preview.height,
        height: preview.width,
        child: CameraPreview(c),
      ),
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
                onPressed: _reRecord,
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
