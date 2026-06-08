import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import 'firebase_options.dart';
import 'screens/admin_auth_screen.dart';
import 'shell/command_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HParkCommandApp());
}

class HParkCommandApp extends StatelessWidget {
  const HParkCommandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HPark Command',
      debugShowCheckedModeBanner: false,
      theme: HParkTheme.dark,
      home: const CommandRoot(),
    );
  }
}

/// Auth gate for the admin dashboard. Admins sign in; the Firestore-backed
/// officer repository is created once signed in (admins may read all officers).
class CommandRoot extends StatefulWidget {
  const CommandRoot({super.key});

  @override
  State<CommandRoot> createState() => _CommandRootState();
}

class _CommandRootState extends State<CommandRoot> {
  final AuthService _auth = FirebaseAuthService();
  FirebaseOfficerRepository? _repo;

  @override
  void dispose() {
    _repo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: _auth.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: HpColors.purple)),
          );
        }
        final user = snap.data;
        if (user == null) {
          _repo?.dispose();
          _repo = null;
          return AdminAuthScreen(auth: _auth);
        }
        _repo ??= FirebaseOfficerRepository();
        final name = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : (user.email ?? 'Admin');
        return CommandShell(
          repo: _repo!,
          adminName: name,
          onSignOut: () => _auth.signOut(),
        );
      },
    );
  }
}
