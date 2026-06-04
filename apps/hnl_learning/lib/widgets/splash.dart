// ============================================================
// SplashScreen — the launch / loading screen.
// ------------------------------------------------------------
// A bright, friendly start screen: the three Somali Village sisters'
// faces in a cheerful cluster with playful floating accents (A · 5 · +
// · ♪) and the HNL Learning wordmark, bouncing in on cold start. Shown
// by the boot gate in app.dart, then it fades into the app.
// ============================================================
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import 'branding.dart';
import 'village.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  final AudioPlayer _harp = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playIntro());
  }

  // Soft harp under the splash + the three sisters' names announced in order
  // with a growing stretch (slower rate = more stretched). Each name plays the
  // family's recording if made (Studio → "Splash screen"), else default TTS.
  Future<void> _playIntro() async {
    if (!mounted) return;
    if (!context.read<AppState>().sound) return; // respect the mute switch
    final vo = context.read<VoService>();
    try {
      await _harp.setReleaseMode(ReleaseMode.stop);
      await _harp.setVolume(0.55);
      await _harp.play(AssetSource('audio/harp.wav'));
    } catch (_) {/* audio unavailable here */}
    const rates = [0.42, 0.34, 0.26]; // name 1 stretches least … name 3 most
    const startMs = [450, 2000, 3650];
    for (var i = 0; i < kSplashVo.length && i < 3; i++) {
      final line = kSplashVo[i];
      Future.delayed(Duration(milliseconds: startMs[i]), () {
        if (mounted) vo.play(line.id, line.text, rate: rates[i]);
      });
    }
  }

  @override
  void dispose() {
    _harp.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final pop = Curves.easeOutBack.transform(_c.value);
        final fade = Curves.easeOut.transform((_c.value * 1.5).clamp(0.0, 1.0));
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.25),
              radius: 1.15,
              colors: [Color(0xFFFFF8EC), Color(0xFFFCE6CC)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(scale: 0.6 + 0.4 * pop, child: Opacity(opacity: fade, child: _cluster())),
                const SizedBox(height: 26),
                Opacity(opacity: fade, child: const Logo()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cluster() => SizedBox(
        width: 470,
        height: 350,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // playful floating accents (letters · numbers · maths · music)
            _accent('A', const Color(0xFFF2B233), left: 0, top: 0, angle: -0.26, size: 66),
            _accent('5', const Color(0xFF4FB477), right: 2, top: 16, angle: 0.22, size: 62),
            _accent('+', const Color(0xFF4F9DDB), right: 24, bottom: 12, angle: 0.12, size: 70),
            _accent('🎵', null, left: 6, bottom: 46, angle: -0.16, size: 50),
            // the three sisters' faces
            Positioned(
              left: 60,
              top: 52,
              child: Transform.rotate(
                  angle: -0.09, child: const _Head(dress: Color(0xFFF2B233), hair: 'afro', size: 172)),
            ),
            Positioned(
              right: 60,
              top: 46,
              child: Transform.rotate(
                  angle: 0.09, child: const _Head(dress: Color(0xFF9B5DE5), hair: 'bun', size: 172)),
            ),
            Positioned(
              bottom: 4,
              child: const _Head(dress: Color(0xFFF368A0), hair: 'puffs', size: 196),
            ),
          ],
        ),
      );

  Widget _accent(String glyph, Color? color,
          {double? left, double? right, double? top, double? bottom, required double angle, required double size}) =>
      Positioned(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
        child: Transform.rotate(
          angle: angle,
          child: Text(
            glyph,
            style: color == null
                ? TextStyle(fontSize: size)
                : TextStyle(fontSize: size, fontWeight: FontWeight.w900, color: color),
          ),
        ),
      );
}

// One sister's head: the top of a [SomaliGirl] in head-only mode, cropped
// to the hair + face + tiara (no gown / scepter).
class _Head extends StatelessWidget {
  final Color dress;
  final String hair;
  final double size;
  const _Head({required this.dress, required this.hair, required this.size});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size * 0.86,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.61,
            child: SomaliGirl(dress: dress, hair: hair, size: size, headOnly: true),
          ),
        ),
      );
}
