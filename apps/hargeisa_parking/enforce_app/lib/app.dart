import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import 'screens/officer_shell.dart';
import 'screens/pending_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';

/// Root of the officer app. Acts as a small state machine that enforces the
/// approval gate: a signed-in / newly-registered officer only reaches the home
/// screen once their account is [ApprovalStatus.approved]; otherwise they see the
/// pending/rejected/suspended screen.
class EnforceRoot extends StatefulWidget {
  const EnforceRoot({super.key});

  @override
  State<EnforceRoot> createState() => _EnforceRootState();
}

class _EnforceRootState extends State<EnforceRoot> {
  final OfficerRepository repo = OfficerRepository.demo();

  String? _sessionOfficerId; // null = signed out
  bool _registering = false;

  @override
  void dispose() {
    repo.dispose();
    super.dispose();
  }

  void _signIn(Officer officer) => setState(() {
        _sessionOfficerId = officer.id;
        _registering = false;
      });

  void _signOut() => setState(() {
        _sessionOfficerId = null;
        _registering = false;
      });

  @override
  Widget build(BuildContext context) {
    if (_sessionOfficerId == null) {
      if (_registering) {
        return RegisterScreen(
          repo: repo,
          onRegistered: _signIn,
          onBack: () => setState(() => _registering = false),
        );
      }
      return WelcomeScreen(
        repo: repo,
        onSignedIn: _signIn,
        onRegister: () => setState(() => _registering = true),
      );
    }

    // Signed in — watch the repo so an approval (or suspension) updates live.
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final officer = repo.byId(_sessionOfficerId!);
        if (officer == null) {
          // Account vanished — bounce to welcome.
          WidgetsBinding.instance.addPostFrameCallback((_) => _signOut());
          return const SizedBox.shrink();
        }
        if (officer.canUseOfficerApp) {
          return OfficerShell(officer: officer, onSignOut: _signOut);
        }
        return PendingScreen(officer: officer, repo: repo, onSignOut: _signOut);
      },
    );
  }
}
