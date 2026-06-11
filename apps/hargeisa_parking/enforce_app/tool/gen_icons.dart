// Generates the HPark app-store / Play-store icon masters for BOTH mobile apps,
// straight from the brand: the gradient "P" parking mark on the dark surface,
// with a per-app role badge (shield = Enforce / officer, coin = Pay / citizen).
//
// Run from enforce_app:   flutter test tool/gen_icons.dart
// Writes (per app)  assets/launcher/icon.png      — full-bleed master (iOS + Android legacy)
//                   assets/launcher/icon_fg.png   — mark on transparent (Android adaptive foreground)
// Then `dart run flutter_launcher_icons` in each app slices these into every slot.
//
// The "P" is drawn as vector paths (not text) on purpose — the flutter_test font
// can't render real glyphs, so geometry keeps it crisp and reproducible.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _purple = Color(0xFF7C6CF8);
const _purple600 = Color(0xFF6655F0);
const _teal = Color(0xFF00D8D6);
const _teal600 = Color(0xFF00B6B4);
const _base = Color(0xFF0F0F17); // icon background (a touch above app bg)

enum _App { enforce, pay }

const _outputs = {
  _App.enforce: 'assets/launcher',
  _App.pay: '../pay_app/assets/launcher',
};

void main() {
  test('generate HPark app icons (enforce + pay)', () async {
    for (final app in _App.values) {
      final dir = _outputs[app]!;
      await _writePng('$dir/icon.png', _render(app, background: true));
      await _writePng('$dir/icon_fg.png', _render(app, background: false));
      // ignore: avoid_print
      print('✓ ${app.name}: wrote $dir/icon.png + icon_fg.png');
    }
  });
}

Future<void> _writePng(String path, Future<Uint8List> bytes) async {
  await File(path).writeAsBytes(await bytes);
}

Future<Uint8List> _render(_App app, {required bool background}) async {
  const s = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, s, s));

  if (background) _paintBackground(canvas, s);

  // Foreground (Android adaptive) keeps the mark inside the ~66% safe zone.
  if (!background) {
    canvas.translate(s / 2, s / 2);
    canvas.scale(0.72);
    canvas.translate(-s / 2, -s / 2);
  }

  _paintP(canvas);
  _paintBadge(canvas, app);

  final image = await recorder.endRecording().toImage(s.toInt(), s.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void _paintBackground(Canvas canvas, double s) {
  final rect = Rect.fromLTWH(0, 0, s, s);
  canvas.drawRect(rect, Paint()..color = _base);
  // Brand glow: purple from the top-left, teal from the bottom-right.
  canvas.drawRect(
    rect,
    Paint()
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(
        const Offset(250, 230), 760,
        [_purple.withValues(alpha: 0.34), _purple.withValues(alpha: 0)],
      ),
  );
  canvas.drawRect(
    rect,
    Paint()
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(
        const Offset(820, 840), 780,
        [_teal.withValues(alpha: 0.30), _teal.withValues(alpha: 0)],
      ),
  );
}

/// The bold gradient "P" — a stem plus a D-shaped bowl with a counter hole.
void _paintP(Canvas canvas) {
  const t = 124.0; // stroke thickness
  const lx = 312.0; // stem left
  const top = 250.0;
  const bottomY = 792.0; // stem bottom
  const bowlBottom = 600.0; // bowl lower edge
  const rx = 690.0; // bowl right edge

  final stem = Path()
    ..addRRect(RRect.fromLTRBR(
        lx, top, lx + t, bottomY, const Radius.circular(28)));

  final bowlOuter = Path()
    ..addRRect(RRect.fromRectAndCorners(
      const Rect.fromLTRB(lx, top, rx, bowlBottom),
      topRight: const Radius.circular(175),
      bottomRight: const Radius.circular(175),
      topLeft: Radius.zero,
      bottomLeft: Radius.zero,
    ));
  final bowlInner = Path()
    ..addRRect(RRect.fromRectAndCorners(
      Rect.fromLTRB(lx + t, top + t, rx - t, bowlBottom - t),
      topRight: const Radius.circular(95),
      bottomRight: const Radius.circular(95),
      topLeft: Radius.zero,
      bottomLeft: Radius.zero,
    ));
  final bowl = Path.combine(PathOperation.difference, bowlOuter, bowlInner);
  final p = Path.combine(PathOperation.union, stem, bowl);

  canvas.drawPath(
    p,
    Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.linear(
        const Offset(lx, top), const Offset(rx, bottomY), [_purple, _teal]),
  );
}

/// Per-app role badge, bottom-right (inside the circular safe zone): a shield for
/// HPark Enforce (officer / authority), a coin for HPark Pay (citizen / payment).
void _paintBadge(Canvas canvas, _App app) {
  const cx = 712.0;
  const cy = 706.0;

  final Path shape;
  final List<Color> fill;
  if (app == _App.enforce) {
    const w = 132.0;
    shape = Path()
      ..moveTo(cx, cy - 158)
      ..lineTo(cx + w, cy - 96)
      ..lineTo(cx + w, cy + 26)
      ..quadraticBezierTo(cx + w, cy + 104, cx, cy + 178)
      ..quadraticBezierTo(cx - w, cy + 104, cx - w, cy + 26)
      ..lineTo(cx - w, cy - 96)
      ..close();
    fill = const [_purple, _purple600];
  } else {
    shape = Path()
      ..addOval(Rect.fromCircle(center: const Offset(cx, cy), radius: 140));
    fill = const [_teal, _teal600];
  }

  // Dark halo so the badge reads cleanly against the gradient "P".
  canvas.drawPath(
    shape.shift(Offset.zero),
    Paint()
      ..color = _base
      ..style = PaintingStyle.stroke
      ..strokeWidth = 56
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.drawPath(shape, Paint()..color = _base); // fill the halo gap solid dark

  canvas.drawPath(
    shape,
    Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.linear(
        Offset(cx - 140, cy - 150), Offset(cx + 140, cy + 160), fill),
  );

  // White check mark inside the badge.
  final check = Path()
    ..moveTo(cx - 58, cy + 4)
    ..lineTo(cx - 14, cy + 50)
    ..lineTo(cx + 66, cy - 52);
  canvas.drawPath(
    check,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
}
