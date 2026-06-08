import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import '../widgets/auth_scaffold.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.repo,
    required this.onSignedIn,
    required this.onRegister,
  });

  final OfficerRepository repo;
  final ValueChanged<Officer> onSignedIn;
  final VoidCallback onRegister;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _signIn() {
    final officer = widget.repo.authenticate(_controller.text);
    if (officer == null) {
      setState(() => _error = 'No officer found for that badge or ID.');
      return;
    }
    widget.onSignedIn(officer);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const HpLogoMark(size: 56),
          const SizedBox(height: HpSpace.x6),
          Text('OFFICER APP', style: HpType.eyebrow),
          const SizedBox(height: HpSpace.x2),
          Text('Sign in to HPark Enforce', style: HpType.heading(size: 28)),
          const SizedBox(height: HpSpace.x2),
          Text('Enter your badge number or officer ID to start your shift.',
              style: HpType.body(size: 14)),
          const SizedBox(height: HpSpace.x6),
          HpInput(
            controller: _controller,
            label: 'Badge number / Officer ID',
            hint: 'HG-OFR-118',
            icon: Icons.badge_outlined,
            mono: true,
            error: _error,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: HpSpace.x5),
          HpButton(
            label: 'Sign in',
            size: HpButtonSize.lg,
            expand: true,
            icon: Icons.login_rounded,
            onPressed: _signIn,
          ),
          const SizedBox(height: HpSpace.x4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('New officer?', style: HpType.body(size: 14)),
              TextButton(
                onPressed: widget.onRegister,
                child: Text('Register',
                    style: HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.purple300)),
              ),
            ],
          ),
          const SizedBox(height: HpSpace.x4),
          _DemoHint(),
        ],
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HpCard(
      color: HpColors.surface,
      padding: const EdgeInsets.all(HpSpace.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('DEMO LOGINS', style: HpType.eyebrow),
          const SizedBox(height: HpSpace.x2),
          _line('HG-OFR-118', 'approved — opens patrol home'),
          _line('HG-OFR-127', 'pending — shows the approval gate'),
        ],
      ),
    );
  }

  Widget _line(String id, String note) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Text(id, style: HpType.mono(size: 13, color: HpColors.text)),
            const SizedBox(width: HpSpace.x3),
            Expanded(child: Text(note, style: HpType.body(size: 12.5, color: HpColors.textMuted))),
          ],
        ),
      );
}
