import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'l10n/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hpTheme.load();
  await localeCtrl.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  enableOfflineCache(); // keep working offline; sync when back online
  runApp(const HParkPayApp());
}

class HParkPayApp extends StatelessWidget {
  const HParkPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([hpTheme, localeCtrl]),
      builder: (context, _) => MaterialApp(
        title: 'HPark Pay',
        debugShowCheckedModeBanner: false,
        theme: HParkTheme.light,
        darkTheme: HParkTheme.dark,
        themeMode: hpTheme.mode,
        home: const PayRoot(),
      ),
    );
  }
}
