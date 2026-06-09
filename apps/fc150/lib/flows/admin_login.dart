import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Admin sign-in. Only the two provisioned admin accounts unlock the Admin +
/// Roster tabs; players never see this unless they tap the lock in the header.
void showAdminLogin(BuildContext context) {
  showFcSheet(context, builder: (_) => const _AdminLogin());
}

/// Sign out of admin — hides the Admin + Roster tabs again.
void showAdminLogout(BuildContext context) {
  showFcSheet(context, builder: (sheetCtx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: FC.purpleTint, shape: BoxShape.circle, boxShadow: FC.glowPurpleSm),
            child: const Icon(LucideIcons.shieldCheck, size: 26, color: FC.purple300),
          ),
        ),
        const SizedBox(height: 14),
        Center(child: Text("You're signed in", style: FCType.heading(size: 18, weight: FontWeight.w700))),
        const SizedBox(height: 6),
        Text('Sign out to return to the standard view.',
            textAlign: TextAlign.center, style: FCType.body(size: 12.5, color: FC.text2, height: 1.35)),
        const SizedBox(height: 18),
        GButton('Sign out', variant: GBtn.danger, icon: LucideIcons.logOut, full: true, onTap: () {
          sheetCtx.read<AppState>().logoutAdmin();
          Navigator.of(sheetCtx).maybePop();
          flashToast(sheetCtx, 'Signed out');
        }),
        const SizedBox(height: 4),
      ],
    );
  });
}

class _AdminLogin extends StatefulWidget {
  const _AdminLogin();
  @override
  State<_AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<_AdminLogin> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = context.read<AppState>().tryAdminLogin(_email.text, _pass.text);
    if (ok) {
      Navigator.of(context).maybePop();
      flashToast(context, 'Signed in');
    } else {
      setState(() => _error = 'Those credentials are not recognised.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: FC.purpleTint, borderRadius: BorderRadius.circular(11)),
              child: const Icon(LucideIcons.lock, size: 20, color: FC.purple300),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Account'),
                  const SizedBox(height: 2),
                  Text('Sign in', style: FCType.heading(size: 19, weight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Enter your account email and password to continue.',
            style: FCType.body(size: 12.5, color: FC.text2, height: 1.35)),
        const SizedBox(height: 16),
        _Field(controller: _email, hint: 'Email', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress, onChanged: _clearError),
        const SizedBox(height: 10),
        _Field(
          controller: _pass,
          hint: 'Password',
          icon: LucideIcons.keyRound,
          obscure: _obscure,
          onChanged: _clearError,
          onSubmitted: (_) => _submit(),
          trailing: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff, size: 18, color: FC.textMuted),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.circleAlert, size: 15, color: FC.danger),
              const SizedBox(width: 6),
              Expanded(child: Text(_error!, style: FCType.body(size: 12, color: FC.danger))),
            ],
          ),
        ],
        const SizedBox(height: 16),
        GButton('Sign in', icon: LucideIcons.logIn, full: true, onTap: _submit),
        const SizedBox(height: 4),
      ],
    );
  }

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }
}

/// Dark themed text field matching the FC150 surfaces.
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: FC.overlay,
        borderRadius: BorderRadius.circular(FC.rInput + 4),
        border: Border.all(color: FC.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: FC.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: FCType.body(size: 14, weight: FontWeight.w500),
              cursorColor: FC.purple300,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: FCType.body(size: 14, color: FC.textMuted),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
