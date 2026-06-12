import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import 'firebase_options.dart';
import 'screens/admin_auth_screen.dart';
import 'shell/command_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hpTheme.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HParkCommandApp());
}

class HParkCommandApp extends StatelessWidget {
  const HParkCommandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: hpTheme,
      builder: (context, _) => MaterialApp(
        title: 'HPark Command',
        debugShowCheckedModeBanner: false,
        theme: HParkTheme.light,
        darkTheme: HParkTheme.dark,
        themeMode: hpTheme.mode,
        home: const CommandRoot(),
      ),
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
  final FirebaseAdminUsers _adminUsers = FirebaseAdminUsers();
  FirebaseOfficerRepository? _repo;

  // Resolved role for the signed-in user: admin (full powers) vs normal user.
  bool? _isAdmin;
  String? _roleUid;
  bool _resolving = false;

  @override
  void dispose() {
    _repo?.dispose();
    super.dispose();
  }

  Future<void> _resolveRole(String uid) async {
    final admin = await _adminUsers.isAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = admin;
      _roleUid = uid;
      _resolving = false;
    });
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
          _isAdmin = null;
          _roleUid = null;
          _resolving = false;
          return AdminAuthScreen(auth: _auth);
        }
        _repo ??= FirebaseOfficerRepository();

        // Resolve the role once per signed-in user before showing the shell.
        if (_roleUid != user.uid) {
          if (!_resolving) {
            _resolving = true;
            _resolveRole(user.uid);
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: HpColors.purple)),
          );
        }

        final name = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : (user.email ?? 'Admin');
        return CommandShell(
          repo: _repo!,
          adminName: name,
          isAdmin: _isAdmin ?? false,
          onSignOut: () => _auth.signOut(),
        );
      },
    );
  }
}
