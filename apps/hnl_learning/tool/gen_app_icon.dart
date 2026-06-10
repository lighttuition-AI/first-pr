// App-icon generator (NOT a unit test — lives outside test/ so the normal
// suite ignores it). Renders the three Somali Village sisters into a 1024×1024
// PNG at /tmp/hnl_icon_1024.png.
//
//   flutter test tool/gen_app_icon.dart
//   scripts/gen-app-icon.sh            # slices it into every AppIcon slot
//
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnl_learning/widgets/village.dart';

void main() {
  testWidgets('generate the 1024 sisters app icon', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: const Directionality(textDirection: TextDirection.ltr, child: SisterIcon()),
      ),
    );
    await tester.pumpAndSettle();

    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    late Uint8List png;
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 1.0); // 1024 logical × 1 = 1024px
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      png = data!.buffer.asUint8List();
    });
    File('/tmp/hnl_icon_1024.png').writeAsBytesSync(png);
    // ignore: avoid_print
    print('WROTE /tmp/hnl_icon_1024.png (${png.length} bytes)');
  });
}

/// The app icon: a warm savanna ground with the three sisters (pink · gold ·
/// purple) grouped in a gentle triangle, gold centre-front. Full-bleed + fully
/// opaque (App Store rejects transparency).
class SisterIcon extends StatelessWidget {
  const SisterIcon({super.key});

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE86A9E);
    const gold = Color(0xFFF2C14E);
    const purple = Color(0xFF8E6FD0);
    return SizedBox(
      width: 1024,
      height: 1024,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // sky → sand gradient ground
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE7BE), Color(0xFFF8C97F), Color(0xFFE89A57)],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // soft sun glow, upper centre
          Positioned(
            top: 70,
            left: 312,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withValues(alpha: .80), Colors.white.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          // a warm ground mound the sisters stand on
          Positioned(
            left: -80,
            right: -80,
            bottom: -140,
            child: Container(
              height: 360,
              decoration: const BoxDecoration(
                color: Color(0xFFD98A47),
                borderRadius: BorderRadius.vertical(top: Radius.elliptical(700, 220)),
              ),
            ),
          ),
          // the three sisters — sides behind/lower, gold centre in front
          Positioned(left: 36, bottom: -70, child: SomaliGirl(dress: pink, hair: 'puffs', size: 440)),
          Positioned(right: 36, bottom: -70, child: SomaliGirl(dress: purple, hair: 'afro', size: 440)),
          Positioned(left: 277, bottom: -20, child: SomaliGirl(dress: gold, hair: 'bun', size: 470)),
        ],
      ),
    );
  }
}
