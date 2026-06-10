import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/backend.dart';
import 'data/seed_data.dart';
import 'screens/app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: FC.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  // Connect to Firebase and load live data into Seed.* before the first frame.
  // Bounded so a slow/offline network can't hang the launch — falls back to the
  // bundled seed content if Firebase is unavailable.
  await Backend.init().timeout(const Duration(seconds: 8), onTimeout: () {});
  await Backend.load().timeout(const Duration(seconds: 8), onTimeout: () {});
  if (kDebugMode) {
    // Boot diagnostic (debug only): confirms whether live Firestore data loaded.
    // ignore: avoid_print
    print('FC150_BOOT backend.ready=${Backend.ready} signedIn=${Backend.signedIn} players=${Seed.players.length} me=${Seed.me.short}/${Seed.me.rating}');
  }
  runApp(const FC150App());
}

class FC150App extends StatelessWidget {
  const FC150App({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider sits ABOVE MaterialApp so every route — including modal bottom
    // sheets (submit result, broadcast, sign-in, new season…) — can read AppState.
    // currentUser is a getter, so it reflects the signed-in player after onboarding.
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'FC150 — Challenge Arena',
        debugShowCheckedModeBanner: false,
        theme: buildFcTheme(),
        home: const RootGate(),
      ),
    );
  }
}

enum _Phase { loading, onboarding, app }

/// Decides what to show on launch: the account/onboarding flow for new players,
/// or the app for signed-in players and guests. Fail-safe — if Firebase is
/// unavailable (or a QA hook is set) it goes straight to the app with the seed
/// identity, so there's never a lockout.
class RootGate extends StatefulWidget {
  const RootGate({super.key});
  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  late _Phase _phase;

  @override
  void initState() {
    super.initState();
    const qa = bool.fromEnvironment('FC_SKIP_TOP3') ||
        bool.fromEnvironment('FC_QA_ADMIN') ||
        int.fromEnvironment('FC_QA_TAB', defaultValue: -1) >= 0;
    if (qa || !Backend.ready) {
      _phase = _Phase.app; // offline / QA / tests → straight in
    } else {
      _phase = _Phase.loading;
      _decide();
    }
    Backend.session.addListener(_onSession);
  }

  @override
  void dispose() {
    Backend.session.removeListener(_onSession);
    super.dispose();
  }

  void _onSession() {
    if (!mounted) return;
    setState(() => _phase = _Phase.loading);
    _decide();
  }

  Future<void> _decide() async {
    final prefs = await SharedPreferences.getInstance();
    final guest = prefs.getBool('guest') ?? false;
    if (Backend.isRegistered) await Backend.loadCurrentPlayer();
    if (!mounted) return;
    final inApp = guest || Backend.currentPlayer != null;
    if (kDebugMode) {
      // ignore: avoid_print
      print('FC150_GATE registered=${Backend.isRegistered} guest=$guest player=${Backend.currentPlayer?.short} -> ${inApp ? 'app' : 'onboarding'}');
    }
    setState(() => _phase = inApp ? _Phase.app : _Phase.onboarding);
  }

  Future<void> _enter({required bool guest}) async {
    if (guest) (await SharedPreferences.getInstance()).setBool('guest', true);
    if (mounted) setState(() => _phase = _Phase.app);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.loading:
        return const Scaffold(
          backgroundColor: FC.bg,
          body: Center(child: CircularProgressIndicator(strokeWidth: 2.6, valueColor: AlwaysStoppedAnimation(FC.purple300))),
        );
      case _Phase.onboarding:
        return OnboardingScreen(onEnter: _enter);
      case _Phase.app:
        return const AppShell();
    }
  }
}
