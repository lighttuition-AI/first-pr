import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import '../data/audit_logger.dart';

/// Admin user management. Only an admin can reach the dashboard, and only an
/// admin can add others (enforced by the security rules). New accounts are
/// created without logging the current admin out.
class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.users, required this.audit});

  final FirebaseAdminUsers users;
  final AuditLogger audit;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _create() async {
    if (_email.text.trim().isEmpty || _password.text.length < 6 || _name.text.trim().isEmpty) {
      setState(() => _error = 'Enter a name, email, and a password of at least 6 characters.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.users.create(
        email: _email.text.trim(),
        password: _password.text,
        name: _name.text.trim(),
        by: widget.audit.by,
      );
      await widget.audit.log('Created admin user', target: _email.text.trim());
      if (!mounted) return;
      final email = _email.text.trim();
      _name.clear();
      _email.clear();
      _password.clear();
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HpColors.elevated,
        content: Text('Created admin $email', style: TextStyle(color: HpColors.text)),
      ));
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _pretty(e);
        });
      }
    }
  }

  String _pretty(Object e) {
    final s = e.toString();
    if (s.contains('email-already-in-use')) return 'That email already has an account.';
    if (s.contains('invalid-email')) return 'That email address looks invalid.';
    if (s.contains('weak-password')) return 'Password should be at least 6 characters.';
    return s.replaceFirst('Exception: ', '');
  }

  Future<void> _revoke(AdminUser u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HpColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
        title: Text('Revoke admin?', style: HpType.heading(size: 18)),
        content: Text('${u.email} will lose dashboard admin access. (Their sign-in account '
            'stays, but can no longer manage data.)', style: HpType.body(size: 14)),
        actions: [
          HpButton(label: 'Cancel', variant: HpButtonVariant.ghost, onPressed: () => Navigator.pop(ctx, false)),
          HpButton(label: 'Revoke', variant: HpButtonVariant.danger, onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok != true) return;
    await widget.users.revoke(u.uid);
    await widget.audit.log('Revoked admin', target: u.email);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        Text('Dashboard users', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x2),
        Text('Admins who can sign in to HPark Command and manage data. Only an admin can add others.',
            style: HpType.body(size: 13.5)),
        const SizedBox(height: HpSpace.x5),
        HpCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add an admin', style: HpType.heading(size: 16)),
              const SizedBox(height: HpSpace.x4),
              LayoutBuilder(builder: (context, c) {
                final wide = c.maxWidth > 720;
                final fields = [
                  HpInput(controller: _name, label: 'Full name', icon: Icons.person_outline, textCapitalization: TextCapitalization.words),
                  HpInput(controller: _email, label: 'Email', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
                  HpInput(controller: _password, label: 'Temporary password', icon: Icons.lock_outline, obscure: true),
                ];
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < fields.length; i++) ...[
                        if (i > 0) const SizedBox(width: HpSpace.x3),
                        Expanded(child: fields[i]),
                      ],
                    ],
                  );
                }
                return Column(children: [
                  for (var i = 0; i < fields.length; i++) ...[
                    if (i > 0) const SizedBox(height: HpSpace.x3),
                    fields[i],
                  ],
                ]);
              }),
              if (_error != null) ...[
                const SizedBox(height: HpSpace.x4),
                Text(_error!, style: HpType.body(size: 13, color: HpColors.danger)),
              ],
              const SizedBox(height: HpSpace.x4),
              Align(
                alignment: Alignment.centerLeft,
                child: HpButton(
                  label: 'Create admin',
                  icon: Icons.person_add_alt_1_outlined,
                  loading: _busy,
                  onPressed: _busy ? null : _create,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x6),
        Text('Admins', style: HpType.heading(size: 16)),
        const SizedBox(height: HpSpace.x3),
        StreamBuilder<List<AdminUser>>(
          stream: widget.users.watchAll(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: HpSpace.x8),
                child: Center(child: CircularProgressIndicator(color: HpColors.purple)),
              );
            }
            final admins = snap.data ?? const [];
            if (admins.isEmpty) {
              return HpCard(
                child: Text('No dashboard-created admins yet. (The original admin account signs in '
                    'with its bootstrap access and does not appear here.)',
                    style: HpType.body(size: 13)),
              );
            }
            return HpCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < admins.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _AdminRow(user: admins[i], onRevoke: () => _revoke(admins[i])),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AdminRow extends StatelessWidget {
  const _AdminRow({required this.user, required this.onRevoke});
  final AdminUser user;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
      child: Row(
        children: [
          HpAvatar(initials: user.initials, size: 38),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name.isEmpty ? user.email : user.name,
                    style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600)),
                Text(user.email, style: HpType.body(size: 12.5, color: HpColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Revoke admin',
            onPressed: onRevoke,
            icon: Icon(Icons.person_remove_outlined, size: 20, color: HpColors.textMuted),
          ),
        ],
      ),
    );
  }
}
