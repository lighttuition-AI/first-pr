import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import 'screens/officer_auth_screen.dart';
import 'screens/officer_shell.dart';
import 'screens/pending_screen.dart';
import 'widgets/auth_scaffold.dart';

/// Root of the officer app. Enforces the approval gate against the live backend:
/// a signed-in officer only reaches the patrol home once their Firestore record
/// is [ApprovalStatus.approved]. Because the record is watched live, an admin's
/// approval in HPark Command unlocks this device in real time.
class EnforceRoot extends StatefulWidget {
  const EnforceRoot({super.key});

  @override
  State<EnforceRoot> createState() => _EnforceRootState();
}

class _EnforceRootState extends State<EnforceRoot> {
  final AuthService _auth = FirebaseAuthService();
  final FirebaseOfficerAccount _account = FirebaseOfficerAccount();

  Future<void> _signOut() => _auth.signOut();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: _auth.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }
        final user = authSnap.data;
        if (user == null) {
          return OfficerAuthScreen(auth: _auth, account: _account);
        }

        // Signed in — watch this officer's record so approval updates live.
        return StreamBuilder<Officer?>(
          stream: _account.watch(user.uid),
          builder: (context, offSnap) {
            if (offSnap.connectionState == ConnectionState.waiting) {
              return const _Loading();
            }
            final officer = offSnap.data;
            if (officer == null) {
              return _NoProfile(email: user.email, onSignOut: _signOut);
            }
            if (officer.canUseOfficerApp) {
              return OfficerShell(officer: officer, onSignOut: _signOut);
            }
            return PendingScreen(officer: officer, onSignOut: _signOut);
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: HpColors.purple)),
      );
}

class _NoProfile extends StatelessWidget {
  const _NoProfile({required this.email, required this.onSignOut});
  final String? email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_off_outlined, size: 48, color: HpColors.warning),
          const SizedBox(height: HpSpace.x4),
          Text('No officer profile', style: HpType.heading(size: 22), textAlign: TextAlign.center),
          const SizedBox(height: HpSpace.x3),
          Text(
            'This account (${email ?? ''}) is signed in but has no officer record. '
            'Create one by registering again, or contact your supervisor.',
            textAlign: TextAlign.center,
            style: HpType.body(size: 14),
          ),
          const SizedBox(height: HpSpace.x6),
          HpButton(label: 'Sign out', variant: HpButtonVariant.secondary, expand: true, onPressed: onSignOut),
        ],
      ),
    );
  }
}
