import 'package:flutter/material.dart';

import 'models/pay_models.dart';
import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';

class PayRoot extends StatefulWidget {
  const PayRoot({super.key});

  @override
  State<PayRoot> createState() => _PayRootState();
}

class _PayRootState extends State<PayRoot> {
  Citizen? _citizen;

  @override
  Widget build(BuildContext context) {
    if (_citizen == null) {
      return WelcomeScreen(onRegistered: (c) => setState(() => _citizen = c));
    }
    return MainShell(
      citizen: _citizen!,
      onSignOut: () => setState(() => _citizen = null),
    );
  }
}
