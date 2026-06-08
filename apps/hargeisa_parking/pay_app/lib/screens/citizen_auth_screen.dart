import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

import '../data/citizen_store.dart';
import '../models/pay_models.dart';

/// Real email/password auth for citizens. Sign in, or create an account that
/// stores the citizen's profile (name, national ID, DOB) in Firestore.
class CitizenAuthScreen extends StatefulWidget {
  const CitizenAuthScreen({super.key, required this.auth, required this.store});

  final AuthService auth;
  final CitizenStore store;

  @override
  State<CitizenAuthScreen> createState() => _CitizenAuthScreenState();
}

class _CitizenAuthScreenState extends State<CitizenAuthScreen> {
  bool _signUp = false;
  bool _busy = false;
  String? _error;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nationalId = TextEditingController();
  DateTime? _dob;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _nationalId]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      if (_signUp) {
        if (_name.text.trim().isEmpty || _nationalId.text.trim().isEmpty || _dob == null) {
          throw 'Please fill in all fields, including date of birth.';
        }
        final user = await widget.auth.register(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
        );
        await widget.store.create(
          user.uid,
          Citizen(
            fullName: _name.text.trim(),
            nationalId: _nationalId.text.trim(),
            dateOfBirth: _dob!,
            email: user.email ?? _email.text.trim(),
          ),
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

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1998),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(data: HParkTheme.dark, child: child!),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(HpSpace.x6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(child: HpLogoMark(size: 56)),
                    const SizedBox(height: HpSpace.x6),
                    Text('CITIZEN APP', style: HpType.eyebrow),
                    const SizedBox(height: HpSpace.x2),
                    Text(_signUp ? 'Create your account' : 'Welcome to HPark Pay',
                        style: HpType.heading(size: 28)),
                    const SizedBox(height: HpSpace.x2),
                    Text(
                      _signUp
                          ? 'Register to see your citations and pay via ZAAD or eDahab.'
                          : 'Sign in to see and pay your parking citations.',
                      style: HpType.body(size: 14),
                    ),
                    const SizedBox(height: HpSpace.x6),
                    if (_signUp) ...[
                      HpInput(controller: _name, label: 'Full name', hint: 'Your name', icon: Icons.person_outline, textCapitalization: TextCapitalization.words),
                      const SizedBox(height: HpSpace.x4),
                    ],
                    HpInput(controller: _email, label: 'Email', hint: 'you@example.com', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: HpSpace.x4),
                    HpInput(controller: _password, label: 'Password', hint: '••••••••', icon: Icons.lock_outline, obscure: true),
                    if (_signUp) ...[
                      const SizedBox(height: HpSpace.x4),
                      HpInput(controller: _nationalId, label: 'Somaliland national ID', hint: 'SL-0000-0000', icon: Icons.badge_outlined, mono: true, textCapitalization: TextCapitalization.characters),
                      const SizedBox(height: HpSpace.x4),
                      _DobField(dob: _dob, onTap: _pickDob),
                    ],
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
                            text: _signUp ? 'Already have an account?  ' : 'New here?  ',
                            style: HpType.body(size: 13.5, color: HpColors.text2),
                            children: [
                              TextSpan(
                                text: _signUp ? 'Sign in' : 'Create an account',
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

class _DobField extends StatelessWidget {
  const _DobField({required this.dob, required this.onTap});
  final DateTime? dob;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Date of birth', style: HpType.body(size: 13, weight: FontWeight.w600, color: HpColors.text2)),
        const SizedBox(height: HpSpace.x2),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HpRadius.sm),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: HpSpace.x4),
            decoration: BoxDecoration(
              color: HpColors.overlay,
              borderRadius: BorderRadius.circular(HpRadius.sm),
              border: Border.all(color: HpColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, size: 18, color: HpColors.textMuted),
                const SizedBox(width: HpSpace.x3),
                Text(
                  dob == null ? 'Select date' : DateFormat('d MMMM yyyy').format(dob!),
                  style: TextStyle(color: dob == null ? HpColors.textMuted : HpColors.text, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
