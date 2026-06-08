import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Circular avatar showing initials over a soft gradient, or a photo if present.
class AvatarInitials extends StatelessWidget {
  final String initials;
  final double size;
  final String? photo;
  const AvatarInitials({super.key, required this.initials, this.size = 38, this.photo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: FC.gradientSoft,
        shape: BoxShape.circle,
        border: Border.all(color: FC.borderStrong),
      ),
      child: photo != null
          ? Image.file(File(photo!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _label())
          : _label(),
    );
  }

  Widget _label() => Center(
        child: Text(initials,
            style: FCType.heading(size: size * 0.37, weight: FontWeight.w800, color: Colors.white)),
      );
}

/// Transient floating pill toast (~1.8s) — used by the admin control room.
void flashToast(BuildContext context, String text) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(ctx).padding.bottom + 96,
      child: IgnorePointer(
        child: Center(
          child: _ToastBubble(text: text),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Timer(const Duration(milliseconds: 1800), () => entry.remove());
}

class _ToastBubble extends StatefulWidget {
  final String text;
  const _ToastBubble({required this.text});
  @override
  State<_ToastBubble> createState() => _ToastBubbleState();
}

class _ToastBubbleState extends State<_ToastBubble> {
  double _o = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _o = 1));
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _o = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _o,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: FC.elevated,
            borderRadius: BorderRadius.circular(FC.rPill),
            border: Border.all(color: FC.borderStrong),
            boxShadow: FC.elevPopover,
          ),
          child: Text(widget.text, style: FCType.body(size: 13, weight: FontWeight.w600, height: 1)),
        ),
      ),
    );
  }
}
