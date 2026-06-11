import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import 'data/citizen_store.dart';
import 'models/pay_models.dart';
import 'screens/citizen_auth_screen.dart';
import 'screens/main_shell.dart';

class PayRoot extends StatefulWidget {
  const PayRoot({super.key});

  @override
  State<PayRoot> createState() => _PayRootState();
}

class _PayRootState extends State<PayRoot> {
  final AuthService _auth = FirebaseAuthService();
  final CitizenStore _store = CitizenStore();

  Future<void> _signOut() => _auth.signOut();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: _auth.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const _Loading();
        final user = snap.data;
        if (user == null) {
          return CitizenAuthScreen(auth: _auth, store: _store);
        }
        return FutureBuilder<Citizen?>(
          future: _store.get(user.uid),
          builder: (context, cs) {
            if (cs.connectionState == ConnectionState.waiting) return const _Loading();
            final citizen = cs.data ??
                Citizen(
                  fullName: user.displayName ?? 'Citizen',
                  nationalId: '—',
                  dateOfBirth: DateTime(1990),
                  email: user.email ?? '',
                );
            return MainShell(
              uid: user.uid,
              citizen: citizen,
              store: _store,
              onSignOut: _signOut,
            );
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
