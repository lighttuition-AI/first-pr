// Avatar creature — a simple bright round buddy drawn with
// CustomPaint (ported from the Avatar SVG in js/ui.jsx). Supports
// an uploaded photo / custom art override and a gentle bounce.
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/image_service.dart';

class Avatar extends StatefulWidget {
  final AvatarData data;
  final double size;

  /// Direct photo bytes (the setup "Add photo" path).
  final Uint8List? photo;
  final bool bouncing;

  const Avatar({
    super.key,
    required this.data,
    this.size = 120,
    this.photo,
    this.bouncing = false,
  });

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.bouncing) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final custom =
        widget.photo ?? context.watch<ImageService>().bytesFor('img-avatar-${widget.data.id}');

    Widget art = custom != null
        ? ClipOval(
            child: Image.memory(custom, width: widget.size, height: widget.size, fit: BoxFit.cover),
          )
        : CustomPaint(size: Size.square(widget.size), painter: _AvatarPainter(widget.data));

    if (widget.bouncing) {
      art = AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -10 * Curves.easeInOut.transform(_c.value)),
          child: child,
        ),
        child: art,
      );
    }
    return SizedBox(width: widget.size, height: widget.size, child: art);
  }
}

class _AvatarPainter extends CustomPainter {
  final AvatarData d;
  _AvatarPainter(this.d);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.scale(s);
    const ink = Color(0xFF2B3A43);

    // shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 104), width: 60, height: 14),
      Paint()..color = const Color(0xFF2B3A43).withValues(alpha: .12),
    );

    final headGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.24, -0.4),
        radius: 0.95,
        colors: [Colors.white.withValues(alpha: .55), d.color, d.color],
        stops: const [0, .4, 1],
      ).createShader(Rect.fromCircle(center: const Offset(60, 56), radius: 40));

    // ears
    final solid = Paint()..color = d.color;
    canvas.drawCircle(const Offset(30, 40), 11, solid);
    canvas.drawCircle(const Offset(90, 40), 11, solid);

    // body hint + head
    canvas.drawCircle(const Offset(60, 56), 36, headGrad);

    // eyes
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(48, 54), 9, white);
    canvas.drawCircle(const Offset(72, 54), 9, white);
    final pupil = Paint()..color = ink;
    canvas.drawCircle(const Offset(49, 56), 4.5, pupil);
    if (d.face == 'wink') {
      final p = Path()..moveTo(66, 54)..quadraticBezierTo(72, 59, 78, 54);
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round
          ..color = ink,
      );
    } else {
      canvas.drawCircle(const Offset(73, 56), 4.5, pupil);
    }

    // cheeks
    final cheek = Paint()..color = Colors.white.withValues(alpha: .4);
    canvas.drawCircle(const Offset(40, 66), 5, cheek);
    canvas.drawCircle(const Offset(80, 66), 5, cheek);

    // mouth
    if (d.face == 'grin') {
      final m = Path()
        ..moveTo(50, 66)
        ..quadraticBezierTo(60, 78, 70, 66)
        ..quadraticBezierTo(60, 71, 50, 66)
        ..close();
      canvas.drawPath(m, white);
    } else {
      final m = Path()..moveTo(52, 66)..quadraticBezierTo(60, 75, 68, 66);
      canvas.drawPath(
        m,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) => old.d != d;
}
