// Robo's speech bubble + the audio-first speaker buttons.
// The speaker pulses and shows a ripple while a line is playing.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/vo_service.dart';
import '../theme/tokens.dart';

enum Tail { left, down }

class SpeechBubble extends StatelessWidget {
  final String text;
  final Tail tail;
  final String voId;
  final String voText;
  const SpeechBubble({
    super.key,
    required this.text,
    required this.voId,
    required this.voText,
    this.tail = Tail.left,
  });

  @override
  Widget build(BuildContext context) {
    final vo = context.watch<VoService>();
    final speaking = vo.isActive(voId);

    final card = Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.fromLTRB(22, 22, 30, 22),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(34),
        boxShadow: Sh.md,
        border: activeSkin.cardBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SpeakerButton(
            size: 64,
            speaking: speaking,
            onTap: () => context.read<VoService>().play(voId, voText),
          ),
          const SizedBox(width: 18),
          Flexible(child: Text(text, style: AppText.bubble)),
        ],
      ),
    );

    return CustomPaint(
      painter: _TailPainter(tail),
      child: Padding(
        padding: EdgeInsets.only(
          left: tail == Tail.left ? 14 : 0,
          bottom: tail == Tail.down ? 14 : 0,
        ),
        child: card,
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  final Tail tail;
  _TailPainter(this.tail);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final path = Path();
    if (tail == Tail.down) {
      final cx = size.width / 2;
      path
        ..moveTo(cx - 18, size.height - 16)
        ..lineTo(cx + 18, size.height - 16)
        ..lineTo(cx, size.height)
        ..close();
    } else {
      final cy = size.height / 2;
      path
        ..moveTo(16, cy - 18)
        ..lineTo(16, cy + 18)
        ..lineTo(0, cy)
        ..close();
    }
    canvas.drawShadow(path, C.inkA(.12), 4, false);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _TailPainter old) => old.tail != tail;
}

/// Round sunny speaker button with pulse + ripple while speaking.
class SpeakerButton extends StatefulWidget {
  final double size;
  final bool speaking;
  final VoidCallback onTap;
  const SpeakerButton({
    super.key,
    required this.size,
    required this.speaking,
    required this.onTap,
  });

  @override
  State<SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<SpeakerButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    if (widget.speaking) _c.repeat();
  }

  @override
  void didUpdateWidget(SpeakerButton old) {
    super.didUpdateWidget(old);
    if (widget.speaking && !_c.isAnimating) _c.repeat();
    if (!widget.speaking && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, child) {
            final r = _c.value;
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (widget.speaking)
                  Container(
                    width: widget.size * (1 + r * 0.7),
                    height: widget.size * (1 + r * 0.7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: C.sun.withValues(alpha: (1 - r) * 0.35),
                    ),
                  ),
                Transform.scale(
                  scale: widget.speaking ? 1 + 0.06 * (0.5 - (r - 0.5).abs()) * 2 : 1,
                  child: child,
                ),
              ],
            );
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: C.sun,
              boxShadow: [
                BoxShadow(color: const Color(0xFFE0A21F), offset: const Offset(0, 4)),
                BoxShadow(color: C.inkA(.12), offset: const Offset(0, 6), blurRadius: 14),
              ],
            ),
            child: Icon(Icons.volume_up_rounded, color: Colors.white, size: widget.size * 0.5),
          ),
        ),
      ),
    );
  }
}

/// Floating in-game speaker (bottom-left). Auto-plays the round line.
class FloatingSpeaker extends StatefulWidget {
  final String voId;
  final String voText;
  final bool autoplay;
  const FloatingSpeaker({
    super.key,
    required this.voId,
    required this.voText,
    this.autoplay = true,
  });

  @override
  State<FloatingSpeaker> createState() => _FloatingSpeakerState();
}

class _FloatingSpeakerState extends State<FloatingSpeaker> {
  @override
  void initState() {
    super.initState();
    if (widget.autoplay) {
      Future.delayed(const Duration(milliseconds: 360), () {
        if (mounted) context.read<VoService>().play(widget.voId, widget.voText);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final speaking = context.watch<VoService>().isActive(widget.voId);
    return SpeakerButton(
      size: 96,
      speaking: speaking,
      onTap: () => context.read<VoService>().play(widget.voId, widget.voText),
    );
  }
}
