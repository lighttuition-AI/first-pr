import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Rasterise the RepaintBoundary behind [key] to PNG bytes. Used to turn the
/// live player card into a shareable / savable image.
///
/// Note: do NOT gate on `boundary.debugNeedsPaint` here — that getter throws a
/// LateInitializationError in release/profile builds (asserts are stripped), which
/// broke crop + share on TestFlight. Instead we wait for the current frame to
/// finish so the boundary is guaranteed painted before rasterising.
Future<Uint8List?> captureBoundaryPng(GlobalKey key, {double pixelRatio = 3}) async {
  await WidgetsBinding.instance.endOfFrame;
  final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data?.buffer.asUint8List();
}

/// "Share card" sheet — render the card, then save it to the gallery or send it
/// via WhatsApp / Email. [boundaryKey] wraps the on-screen card in a
/// RepaintBoundary so we capture exactly what the player sees.
void showShareCardSheet(BuildContext context, {required GlobalKey boundaryKey, required String playerName}) {
  showFcSheet(context, builder: (_) => _ShareSheet(boundaryKey: boundaryKey, playerName: playerName));
}

class _ShareSheet extends StatefulWidget {
  final GlobalKey boundaryKey;
  final String playerName;
  const _ShareSheet({required this.boundaryKey, required this.playerName});
  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  bool _busy = false;

  String get _fileStem => 'FC150_${widget.playerName.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_')}';
  String get _caption => 'My FC150 player card · ${widget.playerName} ⚽';

  Future<File> _writeTempPng(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$_fileStem.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _run(Future<void> Function(Uint8List bytes) action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await captureBoundaryPng(widget.boundaryKey);
      if (bytes == null) {
        if (mounted) flashToast(context, "Couldn't render the card");
        return;
      }
      await action(bytes);
    } catch (_) {
      if (mounted) flashToast(context, 'Something went wrong');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveToGallery() => _run((bytes) async {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          if (mounted) flashToast(context, 'Photo access denied');
          return;
        }
        await Gal.putImageBytes(bytes, name: _fileStem);
        if (mounted) {
          Navigator.of(context).maybePop();
          flashToast(context, 'Saved to your gallery');
        }
      });

  Future<void> _shareImage({String? subject}) => _run((bytes) async {
        final file = await _writeTempPng(bytes);
        if (!mounted) return;
        final box = context.findRenderObject() as RenderBox?;
        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: _caption,
          subject: subject,
          // iPad popover anchor.
          sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ));
        if (mounted) Navigator.of(context).maybePop();
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(alignment: Alignment.centerLeft, child: SectionTitle('Share your card')),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Send your player card or save it to your phone.',
              style: FCType.body(size: 12.5, color: FC.text2)),
        ),
        const SizedBox(height: 14),
        _ShareRow(icon: LucideIcons.messageCircle, iconColor: FC.success, title: 'WhatsApp', sub: 'Send it in a chat', onTap: () => _shareImage()),
        const SizedBox(height: 10),
        _ShareRow(icon: LucideIcons.mail, iconColor: FC.purple300, title: 'Email', sub: 'Attach to a new email', onTap: () => _shareImage(subject: 'My FC150 player card')),
        const SizedBox(height: 10),
        _ShareRow(icon: LucideIcons.download, iconColor: FC.teal, title: 'Save to gallery', sub: 'Keep it in your photos', onTap: _saveToGallery),
        if (_busy) ...[
          const SizedBox(height: 16),
          const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(FC.purple300)))),
        ],
        const SizedBox(height: 6),
      ],
    );
  }
}

class _ShareRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, sub;
  final VoidCallback onTap;
  const _ShareRow({required this.icon, required this.iconColor, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Surface(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: FCType.body(size: 14, weight: FontWeight.w700)),
                Text(sub, style: FCType.body(size: 11.5, color: FC.text2)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, size: 18, color: FC.textMuted),
        ],
      ),
    );
  }
}
