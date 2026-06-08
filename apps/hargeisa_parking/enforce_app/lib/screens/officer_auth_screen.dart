import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';
import 'package:intl/intl.dart';

import '../widgets/auth_scaffold.dart';

/// Real email/password auth for officers. Sign in, or create an account that
/// registers a **pending** officer record — locked until an admin approves it.
class OfficerAuthScreen extends StatefulWidget {
  const OfficerAuthScreen({super.key, required this.auth, required this.account});

  final AuthService auth;
  final FirebaseOfficerAccount account;

  @override
  State<OfficerAuthScreen> createState() => _OfficerAuthScreenState();
}

class _OfficerAuthScreenState extends State<OfficerAuthScreen> {
  bool _signUp = false;
  bool _busy = false;
  String? _error;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _nationalId = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _dob;

  @override
  void dispose() {
    for (final c in [_email, _password, _name, _nationalId, _phone]) {
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
        if (_name.text.trim().isEmpty ||
            _nationalId.text.trim().isEmpty ||
            _phone.text.trim().isEmpty ||
            _dob == null) {
          throw 'Please fill in all fields, including date of birth.';
        }
        final user = await widget.auth.register(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
        );
        await widget.account.createPending(
          uid: user.uid,
          email: user.email ?? _email.text.trim(),
          fullName: _name.text.trim(),
          nationalId: _nationalId.text.trim(),
          phone: _phone.text.trim(),
          dateOfBirth: _dob!,
        );
      } else {
        await widget.auth.signIn(email: _email.text.trim(), password: _password.text);
      }
      // Auth state stream drives navigation from the root — nothing else to do.
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
    if (s.contains('network')) return 'Network error — check your connection.';
    return s.replaceFirst('Exception: ', '');
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(child: HpLogoMark(size: 54)),
          const SizedBox(height: HpSpace.x5),
          Text('OFFICER APP', style: HpType.eyebrow, textAlign: TextAlign.center),
          const SizedBox(height: HpSpace.x2),
          Text(_signUp ? 'Create your officer account' : 'Sign in to HPark Enforce',
              style: HpType.heading(size: 24), textAlign: TextAlign.center),
          const SizedBox(height: HpSpace.x2),
          Text(
            _signUp
                ? 'Register to request officer access. An admin must approve you before you can operate.'
                : 'Enter your email and password to start your shift.',
            style: HpType.body(size: 14),
            textAlign: TextAlign.center,
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
            HpInput(controller: _phone, label: 'Phone', hint: '+252 ...', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: HpSpace.x4),
            _DobField(dob: _dob, onTap: _pickDob),
          ],
          if (_error != null) ...[
            const SizedBox(height: HpSpace.x4),
            _ErrorBanner(_error!),
          ],
          const SizedBox(height: HpSpace.x6),
          HpButton(
            label: _signUp ? 'Create account' : 'Sign in',
            size: HpButtonSize.lg,
            expand: true,
            loading: _busy,
            onPressed: _busy ? null : _submit,
          ),
          const SizedBox(height: HpSpace.x4),
          TextButton(
            onPressed: _busy ? null : () => setState(() {
              _signUp = !_signUp;
              _error = null;
            }),
            child: Text.rich(
              TextSpan(
                text: _signUp ? 'Already registered?  ' : 'New officer?  ',
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
        ],
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
      children: [
        Text('Date of birth', style: HpType.body(size: 13, weight: FontWeight.w600, color: HpColors.text2)),
        const SizedBox(height: HpSpace.x2),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HpRadius.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: HpSpace.x4, vertical: 15),
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
                  dob == null ? 'Select date' : DateFormat('d MMM yyyy').format(dob!),
                  style: HpType.body(size: 15, color: dob == null ? HpColors.textMuted : HpColors.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HpSpace.x3),
      decoration: BoxDecoration(
        color: HpColors.dangerTint,
        borderRadius: BorderRadius.circular(HpRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: HpColors.danger),
          const SizedBox(width: HpSpace.x3),
          Expanded(child: Text(message, style: HpType.body(size: 13, color: HpColors.text))),
        ],
      ),
    );
  }
}
