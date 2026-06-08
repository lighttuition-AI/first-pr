import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

import '../models/pay_models.dart';

/// Citizen onboarding — register with name, Somaliland national ID and DOB.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onRegistered});

  final ValueChanged<Citizen> onRegistered;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _name = TextEditingController();
  final _nationalId = TextEditingController();
  DateTime? _dob;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _nationalId.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1998),
      firstDate: DateTime(1930),
      lastDate: DateTime(2010),
      builder: (context, child) => Theme(data: HParkTheme.dark, child: child!),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _submit() {
    if (_name.text.trim().isEmpty || _nationalId.text.trim().isEmpty || _dob == null) {
      setState(() => _error = 'Please fill in every field, including date of birth.');
      return;
    }
    widget.onRegistered(Citizen(
      fullName: _name.text.trim(),
      nationalId: _nationalId.text.trim(),
      dateOfBirth: _dob!,
    ));
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
                    const HpLogoMark(size: 56),
                    const SizedBox(height: HpSpace.x6),
                    Text('CITIZEN APP', style: HpType.eyebrow),
                    const SizedBox(height: HpSpace.x2),
                    Text('Welcome to HPark Pay', style: HpType.heading(size: 28)),
                    const SizedBox(height: HpSpace.x2),
                    Text(
                      'Register to see your parking citations and pay them via ZAAD or eDahab.',
                      style: HpType.body(size: 14),
                    ),
                    const SizedBox(height: HpSpace.x6),
                    HpInput(
                      controller: _name,
                      label: 'Full name',
                      hint: 'Your name',
                      icon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: HpSpace.x4),
                    HpInput(
                      controller: _nationalId,
                      label: 'Somaliland national ID',
                      hint: 'SL-0000-0000',
                      icon: Icons.badge_outlined,
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
                      label: 'Continue',
                      size: HpButtonSize.lg,
                      expand: true,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _submit,
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
