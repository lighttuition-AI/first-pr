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
import 'screens/rewards.dart';
import 'screens/parent.dart';
import 'screens/voice_studio.dart';
import 'screens/picture_studio.dart';
import 'screens/gif_studio.dart';
import 'screens/child_switcher.dart';
import 'screens/tweaks.dart';

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
          const margin = 20.0;
          final bezelW = kStageW + 40;
          final bezelH = kStageH + 40;
          final s = math.min(
            math.min((box.maxWidth - margin * 2) / bezelW,
                (box.maxHeight - margin * 2) / bezelH),
            1.35,
          );
          return Center(
            child: Transform.scale(
              scale: s <= 0 ? 0.1 : s,
              child: _bezel(),
            ),
          );
        },
      ),
    );
  }

  Widget _bezel() {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: const SizedBox(
          width: kStageW,
          height: kStageH,
          // Material provides a proper DefaultTextStyle so Text never falls
          // back to the debug yellow-underline style. It's transparent so the
          // active skin's background (painted in _StageContent) shows through.
          child: Material(
            color: Colors.transparent,
            child: _StageContent(),
          ),
        ),
      ),
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

        // Floating Tweaks gear (designer/parent live options).
        const Positioned(right: 22, bottom: 22, child: TweaksButton()),
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
      case 'rewards':
        return const RewardsScreen();
      case 'gate':
        return const GateScreen();
      case 'parent':
        return const ParentScreen();
      default:
        return const HomeScreen();
    }
  }
}
