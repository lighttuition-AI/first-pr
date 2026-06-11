import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

import '../models/pay_models.dart';
import '../screens/payment_history.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.citizen,
    required this.citations,
    required this.onSignOut,
    required this.onEditPlate,
  });

  final Citizen citizen;
  final List<Citation> citations;
  final VoidCallback onSignOut;
  final VoidCallback onEditPlate;

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
        _NavRow(
          icon: Icons.directions_car_outlined,
          label: 'Vehicle plate',
          subtitle: citizen.plate.isEmpty ? 'Tap to add your number plate' : citizen.plate,
          onTap: onEditPlate,
        ),
        _NavRow(
          icon: Icons.receipt_long_outlined,
          label: 'Payment history',
          subtitle: 'Past ZAAD & eDahab payments',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PaymentHistoryScreen(citations: citations)),
          ),
        ),
        _NavRow(icon: Icons.gavel_outlined, label: 'Appeals', subtitle: 'Track your video appeals'),
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
  const _NavRow({required this.icon, required this.label, required this.subtitle, this.onTap});
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HpSpace.x3),
      child: HpCard(
        onTap: onTap ?? () {},
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
