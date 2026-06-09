import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/backend.dart';
import 'screens/app_shell.dart';
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
  runApp(const FC150App());
}

class FC150App extends StatelessWidget {
  const FC150App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'FC150 — Challenge Arena',
        debugShowCheckedModeBanner: false,
        theme: buildFcTheme(),
        home: const AppShell(),
      ),
    );
  }
}
