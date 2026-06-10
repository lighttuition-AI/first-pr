import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/backend.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';

/// First-run account flow. New players create an account (which becomes their
/// own player profile + a pending registration for the admin to approve),
/// returning players sign in, or anyone can explore as a guest (seed identity).
class OnboardingScreen extends StatefulWidget {
  /// Called when the player should enter the app. [guest] = explored without an account.
  final void Function({required bool guest}) onEnter;
  const OnboardingScreen({super.key, required this.onEnter});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Mode { welcome, signup, signin }

class _OnboardingScreenState extends State<OnboardingScreen> {
  _Mode _mode = _Mode.welcome;

  static const _countries = {
    'NL': 'Netherlands', 'SO': 'Somalia', 'SN': 'Senegal', 'IT': 'Italy', 'JP': 'Japan',
    'CZ': 'Czechia', 'SE': 'Sweden', 'BR': 'Brazil', 'PT': 'Portugal', 'MX': 'Mexico',
  };

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _psn = TextEditingController();
  String _pos = 'ATT';
  String _country = 'NL';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _psn.dispose();
    super.dispose();
  }

  void _go(_Mode m) => setState(() {
        _mode = m;
        _error = null;
      });

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = _mode == _Mode.signup
        ? await Backend.register(
            email: _email.text, password: _pass.text, name: _name.text,
            psn: _psn.text.isEmpty ? _name.text : _psn.text, pos: _pos, country: _country)
        : await Backend.signIn(email: _email.text, password: _pass.text);
    if (!mounted) return;
    if (res.ok) {
      widget.onEnter(guest: false);
    } else {
      setState(() {
        _busy = false;
        _error = res.error;
      });
    }
  }

  bool get _canSubmit {
    final base = _email.text.contains('@') && _pass.text.length >= 6;
    return _mode == _Mode.signin ? base : (base && _name.text.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FC.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _mode == _Mode.welcome ? _welcome() : _form(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(gradient: FC.gradient, borderRadius: BorderRadius.circular(22), boxShadow: FC.glowPurple),
          child: Text('150', style: FCType.heading(size: 34, weight: FontWeight.w800, color: Colors.white)),
        ),
        const SizedBox(height: 22),
        const Eyebrow('The Arena', color: FC.teal),
        const SizedBox(height: 4),
        Text('Welcome to FC150', style: FCType.heading(size: 28, weight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Create your player, challenge others on PS5, and climb the leagues.',
            style: FCType.body(size: 14, color: FC.text2, height: 1.4)),
        const SizedBox(height: 28),
        GButton('Create your player', icon: LucideIcons.userPlus, full: true, onTap: () => _go(_Mode.signup)),
        const SizedBox(height: 11),
        GButton('I already have an account', variant: GBtn.secondary, full: true, onTap: () => _go(_Mode.signin)),
        const SizedBox(height: 11),
        GButton('Explore as guest', variant: GBtn.ghost, full: true, onTap: () => widget.onEnter(guest: true)),
      ],
    );
  }

  Widget _form() {
    final signup = _mode == _Mode.signup;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _go(_Mode.welcome),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: FC.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: FC.border)),
                child: const Icon(LucideIcons.chevronLeft, size: 20, color: FC.text),
              ),
            ),
            const SizedBox(width: 12),
            Text(signup ? 'Create your player' : 'Sign in', style: FCType.heading(size: 22, weight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 20),
        if (signup) ...[
          _field(_name, 'Display name', LucideIcons.user),
          const SizedBox(height: 10),
        ],
        _field(_email, 'Email', LucideIcons.mail, keyboard: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _field(_pass, 'Password', LucideIcons.keyRound, obscure: true),
        if (signup) ...[
          const SizedBox(height: 10),
          _field(_psn, 'PSN ID (optional)', LucideIcons.gamepad2),
          const SizedBox(height: 16),
          Text('Position', style: FCType.body(size: 12.5, weight: FontWeight.w600, color: FC.text2)),
          const SizedBox(height: 8),
          Segmented(
            tabs: const [MapEntry('ATT', 'Attack'), MapEntry('MID', 'Midfield'), MapEntry('DEF', 'Defence')],
            value: _pos,
            onChange: (v) => setState(() => _pos = v),
          ),
          const SizedBox(height: 14),
          Text('Country', style: FCType.body(size: 12.5, weight: FontWeight.w600, color: FC.text2)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(FC.rInput + 4), border: Border.all(color: FC.border)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _country,
                isExpanded: true,
                dropdownColor: FC.elevated,
                icon: const Icon(LucideIcons.chevronDown, size: 18, color: FC.textMuted),
                style: FCType.body(size: 14, weight: FontWeight.w500),
                items: [for (final e in _countries.entries) DropdownMenuItem(value: e.key, child: Text('${e.value} (${e.key})'))],
                onChanged: (v) => setState(() => _country = v ?? 'NL'),
              ),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Row(children: [
            const Icon(LucideIcons.circleAlert, size: 15, color: FC.danger),
            const SizedBox(width: 6),
            Expanded(child: Text(_error!, style: FCType.body(size: 12.5, color: FC.danger))),
          ]),
        ],
        const SizedBox(height: 20),
        GButton(
          _busy ? 'Please wait…' : (signup ? 'Create account' : 'Sign in'),
          icon: signup ? LucideIcons.userPlus : LucideIcons.logIn,
          full: true,
          disabled: _busy || !_canSubmit,
          onTap: _submit,
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {bool obscure = false, TextInputType? keyboard}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: FC.overlay, borderRadius: BorderRadius.circular(FC.rInput + 4), border: Border.all(color: FC.border)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: FC.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: c,
              obscureText: obscure,
              keyboardType: keyboard,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() {}),
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
        ],
      ),
    );
  }
}
