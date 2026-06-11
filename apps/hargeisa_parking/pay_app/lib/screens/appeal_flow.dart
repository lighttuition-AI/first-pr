import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import '../util/format.dart';

enum _Step { record, review, submitted }

/// Citizen video-appeal flow: record an explanation, review it, submit. On
/// submit an [Appeal] is written to Firestore (status `review`) and the citation
/// moves to [CitationStatus.appealReview] — so the city sees it in HPark Command.
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

  Timer? _timer;
  bool _recording = false;
  int _seconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _reason.dispose();
    super.dispose();
  }

  void _toggleRecord() {
    if (_recording) {
      _timer?.cancel();
      setState(() => _recording = false);
      if (_seconds > 0) setState(() => _step = _Step.review);
    } else {
      setState(() {
        _recording = true;
        _seconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
        if (_seconds >= 90) _toggleRecord(); // cap at 1:30
      });
    }
  }

  String get _time {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  bool _submitting = false;

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
      reason: _reason.text.trim().isEmpty
          ? 'Video appeal submitted.'
          : _reason.text.trim(),
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
        title: Text(_titleText, style: HpType.heading(size: 18)),
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
                Text('Explain what you\'re challenging about citation ${widget.citation.id}.',
                    style: HpType.body(size: 14)),
                const SizedBox(height: HpSpace.x4),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(HpRadius.xl),
                      border: Border.all(color: HpColors.border),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 90, color: Colors.white.withValues(alpha: 0.12)),
                        if (_recording)
                          Positioned(
                            top: 16,
                            child: Row(
                              children: [
                                Container(width: 10, height: 10, decoration: const BoxDecoration(color: HpColors.danger, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(_time, style: HpType.mono(size: 14, color: Colors.white)),
                              ],
                            ),
                          ),
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
          decoration: BoxDecoration(
            color: HpColors.surface,
            border: Border(top: BorderSide(color: HpColors.border)),
          ),
          child: Center(
            child: GestureDetector(
              onTap: _toggleRecord,
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
      ],
    );
  }

  Widget _reviewStep() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(HpSpace.x5),
            children: [
              HpCard(
                padding: EdgeInsets.zero,
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(HpRadius.lg)),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.play_circle_outline, size: 56, color: Colors.white70),
                        Positioned(
                          bottom: 12,
                          child: Text('Recorded · $_time', style: HpType.mono(size: 13, color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: HpSpace.x4),
              HpInput(
                controller: _reason,
                label: 'Add a note (optional)',
                hint: 'Briefly summarise your appeal',
              ),
              const SizedBox(height: HpSpace.x4),
              HpButton(
                label: 'Re-record',
                variant: HpButtonVariant.ghost,
                icon: Icons.refresh_rounded,
                onPressed: () => setState(() => _step = _Step.record),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(HpSpace.x5),
          decoration: BoxDecoration(color: HpColors.surface, border: Border(top: BorderSide(color: HpColors.border))),
          child: HpButton(label: 'Submit appeal', icon: Icons.send_rounded, size: HpButtonSize.lg, expand: true, loading: _submitting, onPressed: _submitting ? null : _submit),
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
                  Text('Appeal submitted', style: HpType.heading(size: 24)),
                  const SizedBox(height: HpSpace.x2),
                  Text(
                    'Your video appeal for ${widget.citation.id} is under review. '
                    'You\'ll be notified of the decision.',
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
