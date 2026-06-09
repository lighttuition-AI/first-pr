import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';
import 'share_card.dart';

/// Aspect ratio (w : h) of the photo slot on the player card — the crop frame
/// matches it so what you frame is what shows on the card.
const double kCardPhotoAspect = 1.4;

/// Adjust-photo editor. Shows the picked image inside a fixed card-shaped frame;
/// pinch to zoom and drag to position, then save. Returns the path to the
/// cropped PNG (written to app storage), or null if cancelled.
Future<String?> showPhotoCrop(BuildContext context, String sourcePath) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _CropPage(sourcePath: sourcePath),
    ),
  );
}

class _CropPage extends StatefulWidget {
  final String sourcePath;
  const _CropPage({required this.sourcePath});
  @override
  State<_CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<_CropPage> {
  final _boundaryKey = GlobalKey();
  late String _path = widget.sourcePath;
  bool _saving = false;

  Future<void> _chooseAnother() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 90);
    if (x == null) return;
    setState(() => _path = x.path);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final bytes = await captureBoundaryPng(_boundaryKey, pixelRatio: 3);
      if (bytes == null) {
        if (mounted) {
          setState(() => _saving = false);
          flashToast(context, "Couldn't save the crop");
        }
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/card_photo_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes, flush: true);
      if (mounted) Navigator.of(context).pop(file.path);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        flashToast(context, 'Something went wrong');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final frameW = (MediaQuery.of(context).size.width - 40).clamp(0.0, 380.0);
    final frameH = frameW / kCardPhotoAspect;

    return Scaffold(
      backgroundColor: FC.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // header
              Row(
                children: [
                  _IconBtn(icon: LucideIcons.x, onTap: () => Navigator.of(context).maybePop()),
                  Expanded(
                    child: Column(
                      children: [
                        const Eyebrow('Player card'),
                        const SizedBox(height: 2),
                        Text('Adjust photo', style: FCType.heading(size: 18, weight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
              SizedBox(height: top > 0 ? 24 : 16),
              Text('Pinch to zoom · drag to position. The frame is the shape on your card.',
                  textAlign: TextAlign.center,
                  style: FCType.body(size: 12.5, color: FC.text2, height: 1.35)),
              const Spacer(),

              // crop frame
              Center(
                child: SizedBox(
                  width: frameW,
                  height: frameH,
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        key: _boundaryKey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: ColoredBox(
                            color: FC.overlay,
                            child: InteractiveViewer(
                              minScale: 1,
                              maxScale: 5,
                              clipBehavior: Clip.hardEdge,
                              child: SizedBox(
                                width: frameW,
                                height: frameH,
                                child: Image.file(
                                  File(_path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(child: Icon(LucideIcons.imageOff, color: FC.text2)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // framing overlay (grid + glowing border) — not captured
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: FC.purple, width: 2),
                            boxShadow: FC.glowPurpleSm,
                          ),
                          child: CustomPaint(painter: _ThirdsGrid(), child: const SizedBox.expand()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // actions
              Row(
                children: [
                  Expanded(child: GButton('Choose another', size: 'md', variant: GBtn.secondary, icon: LucideIcons.imagePlus, full: true, onTap: _chooseAnother)),
                  const SizedBox(width: 10),
                  Expanded(child: GButton(_saving ? 'Saving…' : 'Use photo', size: 'md', variant: GBtn.teal, icon: LucideIcons.check, full: true, onTap: _save)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: FC.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FC.border),
        ),
        child: Icon(icon, size: 20, color: FC.text),
      ),
    );
  }
}

class _ThirdsGrid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final dx = size.width * i / 3;
      final dy = size.height * i / 3;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), p);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), p);
    }
  }

  @override
  bool shouldRepaint(covariant _ThirdsGrid oldDelegate) => false;
}
