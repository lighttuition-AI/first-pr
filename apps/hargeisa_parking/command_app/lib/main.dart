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

  // Resolved role for the signed-in user: 'admin', 'user', or null (no access).
  String? _role;
  String? _roleUid;
  bool _roleResolved = false;
  bool _resolving = false;

  @override
  void dispose() {
    _repo?.dispose();
    super.dispose();
  }

  Future<void> _resolveRole(String uid) async {
    final role = await _adminUsers.currentRole();
    if (!mounted) return;
    setState(() {
      _role = role;
      _roleUid = uid;
      _roleResolved = true;
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
          _role = null;
          _roleUid = null;
          _roleResolved = false;
          _resolving = false;
          return AdminAuthScreen(auth: _auth);
        }
        _repo ??= FirebaseOfficerRepository();

        // Resolve the role once per signed-in user before showing the shell.
        if (_roleUid != user.uid || !_roleResolved) {
          if (!_resolving) {
            _resolving = true;
            _resolveRole(user.uid);
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: HpColors.purple)),
          );
        }

        // A signed-in account that isn't a provisioned dashboard user (e.g. a
        // Pay citizen) gets no dashboard access.
        if (_role == null) {
          return _NoAccessScreen(
            email: user.email ?? '',
            onSignOut: () => _auth.signOut(),
          );
        }

        final name = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : (user.email ?? 'Admin');
        return CommandShell(
          repo: _repo!,
          adminName: name,
          isAdmin: _role == 'admin',
          onSignOut: () => _auth.signOut(),
        );
      },
    );
  }
}

/// Shown when a signed-in account has no dashboard access (not an admin and not
/// a provisioned normal user). An admin must add them on the Users page first.
class _NoAccessScreen extends StatelessWidget {
  const _NoAccessScreen({required this.email, required this.onSignOut});

  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(HpSpace.x8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 48, color: HpColors.textMuted),
                const SizedBox(height: HpSpace.x5),
                Text('No dashboard access', style: HpType.heading(size: 20), textAlign: TextAlign.center),
                const SizedBox(height: HpSpace.x3),
                Text(
                  '${email.isEmpty ? 'This account' : email} is not set up for HPark Command. '
                  'Ask an admin to add you on the Users page, then sign in again.',
                  style: HpType.body(size: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: HpSpace.x6),
                HpButton(label: 'Sign out', variant: HpButtonVariant.secondary, onPressed: onSignOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
