import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

import '../state/shift_state.dart';

const _gps = '9.5616° N, 44.0650° E';
final _money = NumberFormat.decimalPattern('en');
String _slsh(int v) => 'SLSH ${_money.format(v)}';

enum _Step { scan, notFound, found, violation, evidence, review, issued }

/// The end-to-end citation flow: scan/lookup -> vehicle -> violation -> evidence
/// -> review -> issued. Pushed full-screen from the patrol tab.
class CitationFlow extends StatefulWidget {
  const CitationFlow({super.key, required this.officer, required this.shift});

  final Officer officer;
  final ShiftState shift;

  @override
  State<CitationFlow> createState() => _CitationFlowState();
}

class _CitationFlowState extends State<CitationFlow> {
  _Step _step = _Step.scan;
  final _plateCtrl = TextEditingController();
  String _plate = '';
  Vehicle? _vehicle;
  ViolationType? _violation;
  int _photos = 0;
  bool _video = false;
  Citation? _result;

  List<String> _knownPlates = [];
  bool _looking = false;

  @override
  void initState() {
    super.initState();
    // Pull a few plates already on file so the demo "Simulate LPR" + the
    // "Try:" hint reflect the live vehicle registry rather than a hard-coded list.
    widget.shift.vehicles.knownPlates().then((plates) {
      if (mounted) setState(() => _knownPlates = plates);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final plate = _plateCtrl.text.trim().toUpperCase();
    if (plate.isEmpty || _looking) return;
    setState(() {
      _plate = plate;
      _looking = true;
    });
    Vehicle? v;
    try {
      v = await widget.shift.vehicles.lookup(plate);
    } catch (_) {
      v = null;
    }
    if (!mounted) return;
    setState(() {
      _vehicle = v;
      _looking = false;
      _step = v != null ? _Step.found : _Step.notFound;
    });
  }

  void _simulateLpr() {
    if (_knownPlates.isEmpty) return;
    _plateCtrl.text = _knownPlates[Random().nextInt(_knownPlates.length)];
    _lookup();
  }

  void _issue() {
    final citation = widget.shift.issue(
      officer: widget.officer,
      plate: _plate,
      vehicle: _vehicle,
      violation: _violation!,
      gps: _gps,
      photoCount: _photos,
      hasVideo: _video,
    );
    setState(() {
      _result = citation;
      _step = _Step.issued;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_title, style: HpType.heading(size: 18)),
      ),
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: SafeArea(top: false, child: _body()),
      ),
    );
  }

  String get _title => switch (_step) {
        _Step.scan => 'Scan plate',
        _Step.notFound => 'No record',
        _Step.found => 'Vehicle found',
        _Step.violation => 'Select violation',
        _Step.evidence => 'Capture evidence',
        _Step.review => 'Review',
        _Step.issued => 'Citation issued',
      };

  Widget _body() => switch (_step) {
        _Step.scan => _ScanStep(
            controller: _plateCtrl,
            onLookup: _lookup,
            onSimulate: _simulateLpr,
            knownPlates: _knownPlates,
            looking: _looking,
          ),
        _Step.notFound => _NotFoundStep(
            plate: _plate,
            onIssueAnyway: () => setState(() => _step = _Step.violation),
            onBack: () => setState(() => _step = _Step.scan),
          ),
        _Step.found => _FoundStep(
            vehicle: _vehicle!,
            onIssue: () => setState(() => _step = _Step.violation),
            onClear: () => Navigator.pop(context),
          ),
        _Step.violation => _ViolationStep(
            selected: _violation,
            onSelect: (v) => setState(() => _violation = v),
            onContinue: _violation == null ? null : () => setState(() => _step = _Step.evidence),
          ),
        _Step.evidence => _EvidenceStep(
            photos: _photos,
            video: _video,
            onPhoto: () => setState(() => _photos++),
            onVideo: () => setState(() => _video = !_video),
            onReview: _photos == 0 ? null : () => setState(() => _step = _Step.review),
          ),
        _Step.review => _ReviewStep(
            officer: widget.officer,
            plate: _plate,
            vehicle: _vehicle,
            violation: _violation!,
            photos: _photos,
            video: _video,
            offline: widget.shift.offline,
            onIssue: _issue,
          ),
        _Step.issued => _IssuedStep(
            citation: _result!,
            onDone: () => Navigator.pop(context),
            onAnother: () => setState(() {
              _step = _Step.scan;
              _plateCtrl.clear();
              _plate = '';
              _vehicle = null;
              _violation = null;
              _photos = 0;
              _video = false;
              _result = null;
            }),
          ),
      };
}

// ---- Bottom action bar shared by steps ----
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HpSpace.x5),
      decoration: const BoxDecoration(
        color: HpColors.surface,
        border: Border(top: BorderSide(color: HpColors.border)),
      ),
      child: Row(children: children),
    );
  }
}

class _ScanStep extends StatelessWidget {
  const _ScanStep({
    required this.controller,
    required this.onLookup,
    required this.onSimulate,
    required this.knownPlates,
    required this.looking,
  });
  final TextEditingController controller;
  final VoidCallback onLookup;
  final VoidCallback onSimulate;
  final List<String> knownPlates;
  final bool looking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(HpSpace.x5),
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(HpRadius.xl),
                    border: Border.all(color: HpColors.border),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.directions_car_outlined, size: 64, color: Colors.white.withValues(alpha: 0.15)),
                      Container(
                        width: 180,
                        height: 64,
                        decoration: BoxDecoration(
                          border: Border.all(color: HpColors.teal, width: 2),
                          borderRadius: BorderRadius.circular(HpRadius.sm),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        child: Text('Point at a number plate',
                            style: HpType.body(size: 12.5, color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: HpSpace.x4),
              HpButton(
                label: 'Simulate LPR scan',
                icon: Icons.center_focus_strong_outlined,
                size: HpButtonSize.lg,
                expand: true,
                onPressed: knownPlates.isEmpty ? null : onSimulate,
              ),
              const SizedBox(height: HpSpace.x5),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3),
                  child: Text('or enter manually', style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: HpSpace.x5),
              HpInput(
                controller: controller,
                label: 'Number plate',
                hint: 'HG-0000',
                icon: Icons.pin_outlined,
                mono: true,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: HpSpace.x3),
              if (knownPlates.isNotEmpty)
                Text('Try: ${knownPlates.take(4).join('  ·  ')}',
                    style: HpType.body(size: 12, color: HpColors.textMuted)),
            ],
          ),
        ),
        _ActionBar(children: [
          Expanded(
            child: HpButton(
              label: 'Look up vehicle',
              icon: Icons.search,
              size: HpButtonSize.lg,
              expand: true,
              loading: looking,
              onPressed: looking ? null : onLookup,
            ),
          ),
        ]),
      ],
    );
  }
}

class _NotFoundStep extends StatelessWidget {
  const _NotFoundStep({required this.plate, required this.onIssueAnyway, required this.onBack});
  final String plate;
  final VoidCallback onIssueAnyway;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(HpSpace.x6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded, size: 56, color: HpColors.warning),
                  const SizedBox(height: HpSpace.x4),
                  Text('No record found', style: HpType.heading(size: 22)),
                  const SizedBox(height: HpSpace.x2),
                  Text('$plate is not in the vehicle database. You can still issue a citation against the plate.',
                      textAlign: TextAlign.center, style: HpType.body(size: 14)),
                ],
              ),
            ),
          ),
        ),
        _ActionBar(children: [
          HpButton(label: 'Back', variant: HpButtonVariant.ghost, size: HpButtonSize.lg, onPressed: onBack),
          const SizedBox(width: HpSpace.x3),
          Expanded(
            child: HpButton(label: 'Issue anyway', size: HpButtonSize.lg, expand: true, onPressed: onIssueAnyway),
          ),
        ]),
      ],
    );
  }
}

class _FoundStep extends StatelessWidget {
  const _FoundStep({required this.vehicle, required this.onIssue, required this.onClear});
  final Vehicle vehicle;
  final VoidCallback onIssue;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(HpSpace.x5),
            children: [
              HpCard(
                radius: HpRadius.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3, vertical: 6),
                          decoration: BoxDecoration(
                            color: HpColors.overlay,
                            borderRadius: BorderRadius.circular(HpRadius.sm),
                            border: Border.all(color: HpColors.borderStrong),
                          ),
                          child: Text(vehicle.plate, style: HpType.mono(size: 20, weight: FontWeight.w700)),
                        ),
                        const Spacer(),
                        HpBadge(label: vehicle.permitStatus.label, color: vehicle.permitStatus.color, tint: vehicle.permitStatus.tint, glyph: vehicle.permitStatus.glyph),
                      ],
                    ),
                    const SizedBox(height: HpSpace.x4),
                    Text('${vehicle.make} · ${vehicle.color}', style: HpType.heading(size: 17)),
                    const SizedBox(height: HpSpace.x4),
                    const Divider(),
                    const SizedBox(height: HpSpace.x3),
                    _kv('Owner', vehicle.ownerName),
                    const SizedBox(height: HpSpace.x3),
                    _kv('National ID', vehicle.ownerNationalId, mono: true),
                  ],
                ),
              ),
              const SizedBox(height: HpSpace.x4),
              HpCard(
                borderColor: vehicle.outstandingCount > 0 ? HpColors.danger.withValues(alpha: 0.4) : HpColors.border,
                child: Row(
                  children: [
                    Icon(
                      vehicle.outstandingCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      color: vehicle.outstandingCount > 0 ? HpColors.danger : HpColors.success,
                    ),
                    const SizedBox(width: HpSpace.x3),
                    Expanded(
                      child: Text(
                        vehicle.outstandingCount > 0
                            ? '${vehicle.outstandingCount} outstanding citation${vehicle.outstandingCount == 1 ? '' : 's'} · ${_slsh(vehicle.outstandingTotal)}'
                            : 'No outstanding citations',
                        style: HpType.body(size: 13.5, color: HpColors.text, weight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _ActionBar(children: [
          HpButton(label: 'No violation', variant: HpButtonVariant.ghost, size: HpButtonSize.lg, onPressed: onClear),
          const SizedBox(width: HpSpace.x3),
          Expanded(
            child: HpButton(label: 'Issue citation', icon: Icons.receipt_long_outlined, size: HpButtonSize.lg, expand: true, onPressed: onIssue),
          ),
        ]),
      ],
    );
  }

  Widget _kv(String k, String v, {bool mono = false}) => Row(
        children: [
          Text(k, style: HpType.body(size: 13.5, color: HpColors.textMuted)),
          const Spacer(),
          Text(v, style: mono ? HpType.mono(size: 14) : HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.text)),
        ],
      );
}

class _ViolationStep extends StatelessWidget {
  const _ViolationStep({required this.selected, required this.onSelect, required this.onContinue});
  final ViolationType? selected;
  final ValueChanged<ViolationType> onSelect;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(HpSpace.x5),
            children: [
              for (final v in kViolationTypes)
                Padding(
                  padding: const EdgeInsets.only(bottom: HpSpace.x3),
                  child: HpCard(
                    onTap: () => onSelect(v),
                    selected: selected?.code == v.code,
                    padding: const EdgeInsets.all(HpSpace.x4),
                    child: Row(
                      children: [
                        Icon(
                          selected?.code == v.code ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: selected?.code == v.code ? HpColors.purple300 : HpColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: HpSpace.x3),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v.label, style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                              Text(v.code, style: HpType.mono(size: 12, color: HpColors.textMuted)),
                            ],
                          ),
                        ),
                        Text(_slsh(v.fine), style: HpType.mono(size: 14, weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        _ActionBar(children: [
          Expanded(child: HpButton(label: 'Continue', size: HpButtonSize.lg, expand: true, onPressed: onContinue)),
        ]),
      ],
    );
  }
}

class _EvidenceStep extends StatelessWidget {
  const _EvidenceStep({
    required this.photos,
    required this.video,
    required this.onPhoto,
    required this.onVideo,
    required this.onReview,
  });
  final int photos;
  final bool video;
  final VoidCallback onPhoto;
  final VoidCallback onVideo;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(HpSpace.x5),
            children: [
              Text('Add GPS + time-stamped proof of the violation.', style: HpType.body(size: 14)),
              const SizedBox(height: HpSpace.x5),
              _CaptureTile(
                icon: Icons.photo_camera_outlined,
                title: 'Photo',
                captured: photos > 0,
                detail: photos > 0 ? '$photos photo${photos == 1 ? '' : 's'} · $_gps' : 'Tap to capture (required)',
                onTap: onPhoto,
              ),
              const SizedBox(height: HpSpace.x3),
              _CaptureTile(
                icon: Icons.videocam_outlined,
                title: 'Video',
                captured: video,
                detail: video ? '0:12 clip · $_gps' : 'Tap to capture (optional)',
                onTap: onVideo,
              ),
              const SizedBox(height: HpSpace.x4),
              Row(children: [
                const Icon(Icons.lock_clock_outlined, size: 16, color: HpColors.textMuted),
                const SizedBox(width: HpSpace.x2),
                Expanded(child: Text('Each capture is locked with location and timestamp.', style: HpType.body(size: 12.5, color: HpColors.textMuted))),
              ]),
            ],
          ),
        ),
        _ActionBar(children: [
          Expanded(child: HpButton(label: 'Review citation', size: HpButtonSize.lg, expand: true, onPressed: onReview)),
        ]),
      ],
    );
  }
}

class _CaptureTile extends StatelessWidget {
  const _CaptureTile({required this.icon, required this.title, required this.captured, required this.detail, required this.onTap});
  final IconData icon;
  final String title;
  final bool captured;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      onTap: onTap,
      selected: captured,
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: captured ? HpColors.successTint : HpColors.overlay,
              borderRadius: BorderRadius.circular(HpRadius.md),
            ),
            child: Icon(captured ? Icons.check_rounded : icon, color: captured ? HpColors.success : HpColors.text2),
          ),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                Text(detail, style: HpType.body(size: 12.5, color: captured ? HpColors.text2 : HpColors.textMuted)),
              ],
            ),
          ),
          Icon(captured ? Icons.add_a_photo_outlined : Icons.chevron_right, color: HpColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.officer,
    required this.plate,
    required this.vehicle,
    required this.violation,
    required this.photos,
    required this.video,
    required this.offline,
    required this.onIssue,
  });
  final Officer officer;
  final String plate;
  final Vehicle? vehicle;
  final ViolationType violation;
  final int photos;
  final bool video;
  final bool offline;
  final VoidCallback onIssue;

  @override
  Widget build(BuildContext context) {
    final district = districtById(officer.assignedDistrictId);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(HpSpace.x5),
            children: [
              if (offline) ...[
                HpCard(
                  borderColor: HpColors.warning.withValues(alpha: 0.4),
                  padding: const EdgeInsets.all(HpSpace.x4),
                  child: Row(children: [
                    const Icon(Icons.cloud_off_outlined, color: HpColors.warning, size: 20),
                    const SizedBox(width: HpSpace.x3),
                    Expanded(child: Text('You\'re offline — this citation will be queued and synced when back online.', style: HpType.body(size: 13))),
                  ]),
                ),
                const SizedBox(height: HpSpace.x4),
              ],
              HpCard(
                radius: HpRadius.xl,
                child: Column(
                  children: [
                    _kv('Plate', plate, mono: true),
                    const Divider(height: HpSpace.x6),
                    _kv('Owner', vehicle?.ownerName ?? 'Unknown vehicle'),
                    const Divider(height: HpSpace.x6),
                    _kv('Violation', violation.label),
                    const Divider(height: HpSpace.x6),
                    _kv('Fine', _slsh(violation.fine), mono: true),
                    const Divider(height: HpSpace.x6),
                    _kv('Evidence', '$photos photo${photos == 1 ? '' : 's'}${video ? ' · 1 video' : ''}'),
                    const Divider(height: HpSpace.x6),
                    _kv('Location', _gps, mono: true),
                    const Divider(height: HpSpace.x6),
                    _kv('Officer', '${officer.fullName} · ${district?.name ?? '—'}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        _ActionBar(children: [
          Expanded(
            child: HpButton(
              label: offline ? 'Queue citation' : 'Issue citation',
              icon: Icons.check_rounded,
              size: HpButtonSize.lg,
              expand: true,
              onPressed: onIssue,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _kv(String k, String v, {bool mono = false}) => Row(
        children: [
          Text(k, style: HpType.body(size: 13.5, color: HpColors.textMuted)),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: mono ? HpType.mono(size: 14) : HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.text),
            ),
          ),
        ],
      );
}

class _IssuedStep extends StatelessWidget {
  const _IssuedStep({required this.citation, required this.onDone, required this.onAnother});
  final Citation citation;
  final VoidCallback onDone;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
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
                    decoration: const BoxDecoration(color: HpColors.successTint, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: HpColors.success, size: 44),
                  ),
                  const SizedBox(height: HpSpace.x5),
                  Text(citation.synced ? 'Citation issued' : 'Citation queued', style: HpType.heading(size: 24)),
                  const SizedBox(height: HpSpace.x2),
                  Text(citation.id, style: HpType.mono(size: 16, color: HpColors.text2)),
                  const SizedBox(height: HpSpace.x4),
                  Text(_slsh(citation.amount), style: HpType.mono(size: 30, weight: FontWeight.w700)),
                  const SizedBox(height: HpSpace.x4),
                  HpBadge(
                    label: citation.synced ? 'Synced' : 'Queued — will sync',
                    color: citation.synced ? HpColors.success : HpColors.warning,
                    tint: citation.synced ? HpColors.successTint : HpColors.warningTint,
                    glyph: citation.synced ? '✓' : '◷',
                  ),
                ],
              ),
            ),
          ),
        ),
        _ActionBar(children: [
          HpButton(label: 'Issue another', variant: HpButtonVariant.ghost, size: HpButtonSize.lg, onPressed: onAnother),
          const SizedBox(width: HpSpace.x3),
          Expanded(child: HpButton(label: 'Done', size: HpButtonSize.lg, expand: true, onPressed: onDone)),
        ]),
      ],
    );
  }
}
