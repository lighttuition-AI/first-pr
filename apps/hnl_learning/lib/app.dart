// Root app: a fixed 1366×1024 iPad-landscape stage, scaled
// uniformly (letterboxed on black) to fit any viewport — mirrors
// the prototype's #bezel/#stage scaling. A single-screen state
// machine cross-fades between views.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'theme/tokens.dart';
import 'widgets/fx_layer.dart';
import 'screens/onboarding.dart';
import 'screens/setup.dart';
import 'screens/home.dart';
import 'screens/game.dart';
import 'screens/break_screen.dart';
import 'screens/parent.dart';
import 'screens/voice_studio.dart';
import 'screens/picture_studio.dart';
import 'screens/gif_studio.dart';
import 'screens/child_switcher.dart';
import 'screens/tweaks.dart';
import 'screens/continents.dart';
import 'screens/animal_quiz.dart';
import 'widgets/splash.dart';

class HnlApp extends StatelessWidget {
  const HnlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HNL Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: C.letterbox,
        useMaterial3: true,
      ),
      home: const Stage(),
    );
  }
}

class Stage extends StatelessWidget {
  const Stage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: C.letterbox,
      child: LayoutBuilder(
        builder: (context, box) {
          // Phone-class screens are small; tablets keep the framed "device" look.
          final isPhone = math.min(box.maxWidth, box.maxHeight) < 600;

          // The app is landscape-only. If a phone is held upright, ask for a
          // sideways turn rather than cram the wide stage into a tall sliver.
          if (isPhone && box.maxHeight > box.maxWidth) {
            return const _RotateHint();
          }

          // FittedBox lets the fixed 1366×1024 stage lay out at its full natural
          // size (it gets unbounded constraints) and THEN scales to fit. Plain
          // Transform.scale doesn't: the SizedBox would be constraint-clamped on
          // any screen shorter than 1024px (every iPhone, the 11" iPad) and the
          // content would overflow. Contain = fit + letterbox (never crops UI).
          if (isPhone) {
            return FittedBox(fit: BoxFit.contain, child: _stage()); // fill the phone
          }
          return Padding(
            padding: const EdgeInsets.all(20),
            child: FittedBox(fit: BoxFit.contain, child: _framed()),
          );
        },
      ),
    );
  }

  // The bare app stage (fixed 1366×1024). The transparent Material gives Text a
  // real DefaultTextStyle (else the debug yellow underline); the skin background
  // is painted inside by _StageContent.
  Widget _stage() => ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: const SizedBox(
          width: kStageW,
          height: kStageH,
          child: Material(color: Colors.transparent, child: _BootSplashGate()),
        ),
      );

  // Tablet "device" frame: a dark rounded bezel + drop shadow around the stage.
  Widget _framed() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(56),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F3742), Color(0xFF14181C)],
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x8C000000), offset: Offset(0, 40), blurRadius: 90),
          ],
        ),
        child: _stage(),
      );
}

/// Shown on a phone held upright — the app plays in landscape, so nudge a turn.
class _RotateHint extends StatelessWidget {
  const _RotateHint();
  @override
  Widget build(BuildContext context) {
    final white = Colors.white.withValues(alpha: .92);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.screen_rotation_rounded, size: 76, color: white),
          const SizedBox(height: 20),
          Text(
            'Turn me sideways\nto play! 🙂',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: white,
              decoration: TextDecoration.none, // no Material ancestor here
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the [SplashScreen] on cold start, then cross-fades into the app.
/// Purely a boot-time overlay — it doesn't touch the screen state machine.
class _BootSplashGate extends StatefulWidget {
  const _BootSplashGate();
  @override
  State<_BootSplashGate> createState() => _BootSplashGateState();
}

class _BootSplashGateState extends State<_BootSplashGate> {
  double _opacity = 1;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    // Safety net: even if audio never reports done (muted oddly, codec issue),
    // never trap the child on the splash.
    Future.delayed(const Duration(milliseconds: 10000), _fadeOut);
  }

  // Fade the splash away once the three names have finished playing.
  void _fadeOut() {
    if (mounted && _opacity != 0) setState(() => _opacity = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _StageContent(),
        if (!_gone)
          IgnorePointer(
            ignoring: _opacity == 0,
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              onEnd: () {
                if (_opacity == 0 && mounted) setState(() => _gone = true);
              },
              child: SplashScreen(onComplete: _fadeOut),
            ),
          ),
      ],
    );
  }
}

class _StageContent extends StatelessWidget {
  const _StageContent();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Stack(
      children: [
        // Active skin's full-stage background, behind every screen.
        Positioned.fill(child: DecoratedBox(decoration: activeSkin.appBackground)),

        // Ambient animated characters (skin-provided), behind the content.
        if (activeSkin.hasScene) Positioned.fill(child: activeSkin.sceneBuilder!()),

        // Routed screen with a cross-fade + slight scale.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 1.012, end: 1.0).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(app.screen),
            child: _routeFor(app.screen),
          ),
        ),

        // Celebration FX above everything.
        const Positioned.fill(child: FxLayer()),

        // Floating Tweaks gear (designer/parent live options). On the play
        // screens a big "Next / Finish" button sits bottom-right, so the gear
        // moves to the bottom-LEFT there — keeps little fingers reaching for
        // Next from fat-fingering Settings. Bottom-right everywhere else.
        Positioned(
          left: _gearOnLeft(app.screen) ? 22 : null,
          right: _gearOnLeft(app.screen) ? null : 22,
          bottom: 22,
          child: const TweaksButton(),
        ),
        if (app.showTweaks) const Positioned.fill(child: TweaksPanel()),

        // The creative-control Studios.
        if (app.showVoice) const Positioned.fill(child: VoiceStudio()),
        if (app.showPictures) const Positioned.fill(child: PictureStudio()),
        if (app.showGif) const Positioned.fill(child: GifStudio()),

        // Profile dropdown: switch between children.
        if (app.showChildMenu) const Positioned.fill(child: ChildSwitcher()),

        // Child-lock gate guarding the settings/Tweaks panel.
        if (app.showGate)
          Positioned.fill(
            child: GateScreen(
              onUnlock: () {
                final action = app.gateAction;
                app.closeGate();
                action?.call();
              },
              onClose: app.closeGate,
            ),
          ),
      ],
    );
  }

  Widget _routeFor(String screen) {
    if (screen.startsWith('onb-')) {
      return OnboardingScreen(index: int.parse(screen.split('-')[1]));
    }
    switch (screen) {
      case 'age':
        return const AgeScreen();
      case 'practise':
        return const PractiseScreen();
      case 'avatar':
        return const AvatarScreen();
      case 'ready':
        return const ReadyScreen();
      case 'home':
        return const HomeScreen();
      case 'game':
        return const GameRunner();
      case 'break':
        return const BreakScreen();
      case 'continents':
        return const ContinentMapScreen();
      case 'animal-quiz':
        return const AnimalQuizScreen();
      case 'gate':
        return const GateScreen();
      case 'parent':
        return const ParentScreen();
      default:
        return const HomeScreen();
    }
  }
}

/// The play screens put a big "Next / Finish" button in the bottom-right, so the
/// floating Settings gear moves to the bottom-LEFT on these to avoid overlap.
bool _gearOnLeft(String screen) => screen == 'game' || screen == 'animal-quiz';
