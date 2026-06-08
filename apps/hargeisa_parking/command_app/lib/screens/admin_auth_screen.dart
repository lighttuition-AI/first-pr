import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

/// Admin sign-in / account creation for HPark Command. A new account is just an
/// authenticated user until granted the `admin` claim (see tool/grant_admin.mjs).
class AdminAuthScreen extends StatefulWidget {
  const AdminAuthScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<AdminAuthScreen> createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  bool _signUp = false;
  bool _busy = false;
  String? _error;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      if (_signUp) {
        await widget.auth.register(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
        );
      } else {
        await widget.auth.signIn(email: _email.text.trim(), password: _password.text);
      }
    } catch (e) {
      setState(() => _error = _pretty(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _pretty(Object e) {
    final s = e.toString();
    if (s.contains('email-already-in-use')) return 'That email already has an account. Sign in instead.';
    if (s.contains('invalid-credential') || s.contains('wrong-password') || s.contains('user-not-found')) {
      return 'Email or password is incorrect.';
    }
    if (s.contains('weak-password')) return 'Password should be at least 6 characters.';
    if (s.contains('invalid-email')) return 'That email address looks invalid.';
    return s.replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HpSpace.x8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: HpCard(
                radius: HpRadius.xl,
                padding: const EdgeInsets.all(HpSpace.x8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HpWordmark(markSize: 40),
                    const SizedBox(height: HpSpace.x6),
                    Text('ADMIN DASHBOARD', style: HpType.eyebrow),
                    const SizedBox(height: HpSpace.x2),
                    Text(_signUp ? 'Create an admin account' : 'Sign in to HPark Command',
                        style: HpType.heading(size: 24)),
                    const SizedBox(height: HpSpace.x2),
                    Text(
                      _signUp
                          ? 'New accounts need the admin role granted before they can approve officers.'
                          : 'Manage officers, approvals and city operations.',
                      style: HpType.body(size: 14),
                    ),
                    const SizedBox(height: HpSpace.x6),
                    if (_signUp) ...[
                      HpInput(controller: _name, label: 'Name', hint: 'Your name', icon: Icons.person_outline, textCapitalization: TextCapitalization.words),
                      const SizedBox(height: HpSpace.x4),
                    ],
                    HpInput(controller: _email, label: 'Email', hint: 'you@example.com', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: HpSpace.x4),
                    HpInput(controller: _password, label: 'Password', hint: '••••••••', icon: Icons.lock_outline, obscure: true),
                    if (_error != null) ...[
                      const SizedBox(height: HpSpace.x4),
                      Container(
                        padding: const EdgeInsets.all(HpSpace.x3),
                        decoration: BoxDecoration(color: HpColors.dangerTint, borderRadius: BorderRadius.circular(HpRadius.sm)),
                        child: Row(children: [
                          const Icon(Icons.error_outline, size: 18, color: HpColors.danger),
                          const SizedBox(width: HpSpace.x3),
                          Expanded(child: Text(_error!, style: HpType.body(size: 13, color: HpColors.text))),
                        ]),
                      ),
                    ],
                    const SizedBox(height: HpSpace.x6),
                    HpButton(
                      label: _signUp ? 'Create account' : 'Sign in',
                      size: HpButtonSize.lg,
                      expand: true,
                      loading: _busy,
                      onPressed: _busy ? null : _submit,
                    ),
                    const SizedBox(height: HpSpace.x3),
                    Center(
                      child: TextButton(
                        onPressed: _busy ? null : () => setState(() {
                          _signUp = !_signUp;
                          _error = null;
                        }),
                        child: Text.rich(
                          TextSpan(
                            text: _signUp ? 'Already have an account?  ' : 'Need an account?  ',
                            style: HpType.body(size: 13.5, color: HpColors.text2),
                            children: [
                              TextSpan(
                                text: _signUp ? 'Sign in' : 'Create one',
                                style: HpType.body(size: 13.5, weight: FontWeight.w700, color: HpColors.purple300),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
