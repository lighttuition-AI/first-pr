import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hpark_core/hpark_core.dart';

/// Live plate scanner. Shows the camera with a "lock-in" guide box and keeps
/// taking pictures + running text recognition until the SAME plate is read on
/// two consecutive frames — then it locks in and returns it. Scanning many
/// frames is what beats glare / shadow / reflection on any single shot.
///
/// Returns the recognised plate string (e.g. "F4154"), or null if the officer
/// backs out / chooses to type it.
class PlateScanner extends StatefulWidget {
  const PlateScanner({super.key});

  @override
  State<PlateScanner> createState() => _PlateScannerState();
}

class _PlateScannerState extends State<PlateScanner> with WidgetsBindingObserver {
  CameraController? _controller;
  final TextRecognizer _recognizer = TextRecognizer();

  bool _ready = false;
  bool _done = false; // stop the loop (locked in or disposing)
  bool _torch = false;
  String? _error;

  String? _candidate; // last plate read
  int _hits = 0; // consecutive reads of _candidate
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      try {
        await controller.setFocusMode(FocusMode.auto);
        await controller.setExposureMode(ExposureMode.auto);
      } catch (_) {/* not all devices support these */}
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _ready = true;
      });
      unawaited(_loop());
    } catch (e) {
      if (mounted) setState(() => _error = 'Camera unavailable on this device.');
    }
  }

  Future<void> _loop() async {
    while (mounted && !_done) {
      final c = _controller;
      if (c == null || !c.value.isInitialized || c.value.isTakingPicture) {
        await Future.delayed(const Duration(milliseconds: 150));
        continue;
      }
      String? path;
      try {
        final shot = await c.takePicture();
        path = shot.path;
        final plate = await _read(path);
        _onRead(plate);
      } catch (_) {
        // a dropped frame is fine — keep scanning
      } finally {
        if (path != null) {
          try {
            await File(path).delete();
          } catch (_) {}
        }
      }
      if (!_done) await Future.delayed(const Duration(milliseconds: 120));
    }
  }

  /// OCR one captured photo: pick the largest plate-like text line.
  Future<String?> _read(String imagePath) async {
    try {
      final result = await _recognizer.processImage(InputImage.fromFilePath(imagePath));
      String? best;
      double bestHeight = 0;
      for (final block in result.blocks) {
        for (final line in block.lines) {
          final candidate = _extractPlate(line.text);
          if (candidate != null && line.boundingBox.height > bestHeight) {
            best = candidate;
            bestHeight = line.boundingBox.height.toDouble();
          }
        }
      }
      return best ?? _extractPlate(result.text);
    } catch (_) {
      return null;
    }
  }

  static final _plate4 = RegExp(r'\b([A-Z]{1,3})[\s\-]*(\d{4})\b');
  static final _plateAny = RegExp(r'\b([A-Z]{1,3})[\s\-]*(\d{3,5})\b');

  String? _extractPlate(String text) {
    final up = text.toUpperCase();
    for (final re in [_plate4, _plateAny]) {
      final m = re.firstMatch(up);
      if (m != null) return '${m.group(1)}${m.group(2)}';
    }
    final digits = RegExp(r'\b\d{4,5}\b').firstMatch(up);
    return digits?.group(0);
  }

  void _onRead(String? plate) {
    if (_done) return;
    if (plate == null) {
      if (mounted) setState(() {/* keep showing the last candidate, if any */});
      return;
    }
    if (plate == _candidate) {
      _hits++;
    } else {
      _candidate = plate;
      _hits = 1;
    }
    if (mounted) setState(() {});
    if (_hits >= 2) _lockIn(plate);
  }

  Future<void> _lockIn(String plate) async {
    if (_locked) return;
    _locked = true;
    _done = true;
    HapticFeedback.mediumImpact();
    if (mounted) setState(() {});
    await Future.delayed(const Duration(milliseconds: 550));
    if (mounted) Navigator.of(context).pop(plate);
  }

  Future<void> _toggleTorch() async {
    final c = _controller;
    if (c == null) return;
    try {
      _torch = !_torch;
      await c.setFlashMode(_torch ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _done = true;
      c.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _done = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready && _controller != null)
            Builder(builder: (context) {
              final size = MediaQuery.of(context).size;
              var scale = _controller!.value.aspectRatio * size.aspectRatio;
              if (scale < 1) scale = 1 / scale;
              return Transform.scale(
                scale: scale,
                child: Center(child: CameraPreview(_controller!)),
              );
            })
          else if (_error != null)
            Center(child: Padding(padding: const EdgeInsets.all(HpSpace.x8), child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 15))))
          else
            const Center(child: CircularProgressIndicator(color: HpColors.purple)),

          // Lock-in guide box.
          if (_ready) Center(child: _GuideBox(locked: _locked, plate: _candidate)),

          // Top bar.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(HpSpace.x4),
              child: Row(
                children: [
                  _RoundBtn(icon: Icons.close, onTap: () => Navigator.of(context).pop()),
                  const Spacer(),
                  if (_ready)
                    _RoundBtn(icon: _torch ? Icons.flashlight_on : Icons.flashlight_off, onTap: _toggleTorch),
                ],
              ),
            ),
          ),

          // Bottom status + actions.
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(HpSpace.x5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _locked
                          ? 'Locked: $_candidate'
                          : _candidate != null
                              ? 'Reading $_candidate…'
                              : 'Point at the plate inside the box',
                      style: TextStyle(
                        color: _locked ? HpColors.success : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: HpSpace.x4),
                    if (_candidate != null && !_locked)
                      HpButton(
                        label: 'Use $_candidate',
                        icon: Icons.check_rounded,
                        size: HpButtonSize.lg,
                        expand: true,
                        onPressed: () {
                          _done = true;
                          Navigator.of(context).pop(_candidate);
                        },
                      ),
                    const SizedBox(height: HpSpace.x3),
                    HpButton(
                      label: 'Enter manually',
                      variant: HpButtonVariant.secondary,
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
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

class _GuideBox extends StatelessWidget {
  const _GuideBox({required this.locked, required this.plate});
  final bool locked;
  final String? plate;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.82;
    final color = locked ? HpColors.success : (plate != null ? HpColors.teal : Colors.white);
    return Container(
      width: w,
      height: w / 2.6, // a plate is roughly 2.6:1
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(HpRadius.lg),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 18, spreadRadius: 1)],
      ),
      child: locked
          ? Center(child: Icon(Icons.check_circle, color: HpColors.success, size: 56))
          : null,
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
