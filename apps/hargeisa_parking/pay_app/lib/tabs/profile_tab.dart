import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

import '../models/pay_models.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.citizen, required this.onSignOut});

  final Citizen citizen;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x5),
      children: [
        const SizedBox(height: HpSpace.x4),
        Center(child: HpAvatar(initials: citizen.initials, size: 84)),
        const SizedBox(height: HpSpace.x4),
        Center(child: Text(citizen.fullName, style: HpType.heading(size: 22))),
        const SizedBox(height: HpSpace.x6),
        HpCard(
          child: Column(
            children: [
              _row('National ID', citizen.nationalId, mono: true),
              const Divider(height: HpSpace.x6),
              _row('Date of birth', DateFormat('d MMMM yyyy').format(citizen.dateOfBirth)),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x5),
        _NavRow(icon: Icons.gavel_outlined, label: 'Appeals', subtitle: 'Challenge a citation by video'),
        _NavRow(icon: Icons.receipt_long_outlined, label: 'Payment history', subtitle: 'Past ZAAD & eDahab payments'),
        _NavRow(icon: Icons.translate_rounded, label: 'Language', subtitle: 'English · Somali'),
        _NavRow(icon: Icons.help_outline_rounded, label: 'Help & support', subtitle: 'Contact the city office'),
        const SizedBox(height: HpSpace.x5),
        HpButton(
          label: 'Sign out',
          variant: HpButtonVariant.secondary,
          expand: true,
          icon: Icons.logout_rounded,
          onPressed: onSignOut,
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool mono = false}) {
    return Row(
      children: [
        Text(label, style: HpType.body(size: 13.5, color: HpColors.textMuted)),
        const Spacer(),
        Text(
          value,
          style: mono
              ? HpType.mono(size: 14, color: HpColors.text)
              : HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.text),
        ),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.label, required this.subtitle});
  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HpSpace.x3),
      child: HpCard(
        onTap: () {},
        padding: const EdgeInsets.all(HpSpace.x4),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: HpColors.overlay,
                borderRadius: BorderRadius.circular(HpRadius.md),
              ),
              child: Icon(icon, color: HpColors.text2, size: 20),
            ),
            const SizedBox(width: HpSpace.x4),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: HpColors.textMuted),
          ],
        ),
      ),
    );
  }
}
