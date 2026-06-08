import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

import '../widgets/auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.repo,
    required this.onRegistered,
    required this.onBack,
  });

  final OfficerRepository repo;
  final ValueChanged<Officer> onRegistered;
  final VoidCallback onBack;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _nationalId = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _dob;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _nationalId.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: DateTime(2008),
      builder: (context, child) => Theme(data: HParkTheme.dark, child: child!),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _nationalId.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _dob == null) {
      setState(() => _error = 'Please fill in every field, including date of birth.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final officer = await widget.repo.register(
      fullName: _name.text,
      nationalId: _nationalId.text,
      phone: _phone.text,
      dateOfBirth: _dob!,
    );
    if (mounted) widget.onRegistered(officer);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('OFFICER REGISTRATION', style: HpType.eyebrow),
          const SizedBox(height: HpSpace.x2),
          Text('Request officer access', style: HpType.heading(size: 26)),
          const SizedBox(height: HpSpace.x2),
          Text(
            'Submit your details. An administrator verifies your identity in HPark '
            'Command before your account is activated.',
            style: HpType.body(size: 14),
          ),
          const SizedBox(height: HpSpace.x6),
          HpInput(
            controller: _name,
            label: 'Full name',
            hint: 'Amina Yusuf',
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: HpSpace.x4),
          HpInput(
            controller: _nationalId,
            label: 'Somaliland national ID',
            hint: 'SL-0000-0000',
            icon: Icons.fingerprint,
            mono: true,
          ),
          const SizedBox(height: HpSpace.x4),
          HpInput(
            controller: _phone,
            label: 'Phone number',
            hint: '+252 63 0000000',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            mono: true,
          ),
          const SizedBox(height: HpSpace.x4),
          _DobField(dob: _dob, onTap: _pickDob),
          if (_error != null) ...[
            const SizedBox(height: HpSpace.x3),
            Text(_error!, style: HpType.body(size: 13, color: HpColors.danger)),
          ],
          const SizedBox(height: HpSpace.x5),
          HpButton(
            label: 'Submit for approval',
            size: HpButtonSize.lg,
            expand: true,
            loading: _submitting,
            icon: Icons.send_rounded,
            onPressed: _submit,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Date of birth',
            style: HpType.body(size: 13, weight: FontWeight.w600, color: HpColors.text2)),
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
                  style: TextStyle(
                    color: dob == null ? HpColors.textMuted : HpColors.text,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
