import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/app_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: FC.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
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
