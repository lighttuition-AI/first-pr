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
    required this.onEditNationalId,
    required this.onEditDob,
    required this.onOpenAppeals,
  });

  final Citizen citizen;
  final List<Citation> citations;
  final VoidCallback onSignOut;
  final VoidCallback onEditPlate;
  final VoidCallback onEditNationalId;
  final VoidCallback onEditDob;
  final VoidCallback onOpenAppeals;

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
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _EditRow(label: 'National ID', value: citizen.nationalId, mono: true, onTap: onEditNationalId),
              const Divider(height: 1),
              _EditRow(
                label: 'Date of birth',
                value: DateFormat('d MMMM yyyy').format(citizen.dateOfBirth),
                onTap: onEditDob,
              ),
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
        _NavRow(
          icon: Icons.gavel_outlined,
          label: 'Appeals',
          subtitle: 'Track your video appeals',
          onTap: onOpenAppeals,
        ),
        _NavRow(
          icon: Icons.translate_rounded,
          label: 'Language',
          subtitle: 'English · Somali',
          onTap: () => _showLanguage(context),
        ),
        _NavRow(
          icon: Icons.help_outline_rounded,
          label: 'Help & support',
          subtitle: 'Contact the city office',
          onTap: () => _showHelp(context),
        ),
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

  void _showLanguage(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: HpColors.elevated,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(HpRadius.xl))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(HpSpace.x5, HpSpace.x5, HpSpace.x5, HpSpace.x8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Language', style: HpType.heading(size: 20)),
            const SizedBox(height: HpSpace.x4),
            const _LangTile(name: 'English', selected: true, enabled: true),
            const SizedBox(height: HpSpace.x3),
            const _LangTile(name: 'Somali (Soomaali)', selected: false, enabled: false),
            const SizedBox(height: HpSpace.x4),
            Text('A full Somali translation is on the way.',
                style: HpType.body(size: 12.5, color: HpColors.textMuted)),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: HpColors.elevated,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(HpRadius.xl))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(HpSpace.x5, HpSpace.x5, HpSpace.x5, HpSpace.x8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Help & support', style: HpType.heading(size: 20)),
            const SizedBox(height: HpSpace.x2),
            Text('Hargeisa City Parking Office', style: HpType.body(size: 14, color: HpColors.text2)),
            const SizedBox(height: HpSpace.x5),
            const _HelpRow(icon: Icons.phone_outlined, label: 'Phone', value: '+252 63 4000 000'),
            const SizedBox(height: HpSpace.x3),
            const _HelpRow(icon: Icons.mail_outline, label: 'Email', value: 'support@hargeisaparking.so'),
            const SizedBox(height: HpSpace.x3),
            const _HelpRow(icon: Icons.schedule_outlined, label: 'Hours', value: 'Sat–Thu · 8:00–16:00'),
          ],
        ),
      ),
    );
  }
}

class _EditRow extends StatelessWidget {
  const _EditRow({required this.label, required this.value, required this.onTap, this.mono = false});
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
        child: Row(
          children: [
            Text(label, style: HpType.body(size: 13.5, color: HpColors.textMuted)),
            const Spacer(),
            Text(
              value,
              style: mono
                  ? HpType.mono(size: 14, color: HpColors.text)
                  : HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.text),
            ),
            const SizedBox(width: HpSpace.x3),
            const Icon(Icons.edit_outlined, size: 16, color: HpColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({required this.name, required this.selected, required this.enabled});
  final String name;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      padding: const EdgeInsets.all(HpSpace.x4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: enabled ? HpColors.text : HpColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: HpColors.purple300, size: 20)
          else if (!enabled)
            Text('Coming soon', style: HpType.body(size: 12, color: HpColors.textMuted)),
        ],
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: HpColors.text2),
        const SizedBox(width: HpSpace.x4),
        Text(label, style: HpType.body(size: 13.5, color: HpColors.textMuted)),
        const Spacer(),
        Text(value, style: HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.text)),
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
