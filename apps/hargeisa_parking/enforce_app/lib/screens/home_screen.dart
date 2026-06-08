import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.officer, required this.onSignOut});

  final Officer officer;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final district = districtById(officer.assignedDistrictId);
    return Scaffold(
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(HpSpace.x5),
            children: [
              Row(
                children: [
                  HpAvatar(initials: officer.initials, size: 46, statusColor: HpColors.success),
                  const SizedBox(width: HpSpace.x3),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('On patrol', style: HpType.eyebrow),
                        Text(officer.fullName, style: HpType.heading(size: 20)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onSignOut,
                    icon: const Icon(Icons.logout_rounded, color: HpColors.text2),
                    tooltip: 'Sign out',
                  ),
                ],
              ),
              const SizedBox(height: HpSpace.x5),
              HpCard(
                radius: HpRadius.xl,
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: HpColors.purpleTint,
                        borderRadius: BorderRadius.circular(HpRadius.md),
                      ),
                      child: const Icon(Icons.location_on_outlined, color: HpColors.purple300),
                    ),
                    const SizedBox(width: HpSpace.x4),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("TODAY'S DISTRICT", style: HpType.eyebrow),
                          const SizedBox(height: 2),
                          Text(district?.name ?? 'Unassigned', style: HpType.heading(size: 18)),
                        ],
                      ),
                    ),
                    const HpBadge(
                      label: 'On shift',
                      color: HpColors.success,
                      tint: HpColors.successTint,
                      glyph: '●',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HpSpace.x5),
              _ScanCard(onTap: () => _comingSoon(context, 'Plate scan')),
              const SizedBox(height: HpSpace.x5),
              Row(
                children: [
                  Expanded(
                    child: HpKpiCard(
                      label: 'Issued today',
                      value: '12',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                  const SizedBox(width: HpSpace.x4),
                  Expanded(
                    child: HpKpiCard(
                      label: 'This shift',
                      value: '${officer.citationsIssued}',
                      icon: Icons.verified_outlined,
                      accent: HpColors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: HpSpace.x6),
              Text('Quick actions', style: HpType.heading(size: 16)),
              const SizedBox(height: HpSpace.x3),
              _ActionRow(
                icon: Icons.directions_car_outlined,
                title: 'Look up a vehicle',
                subtitle: 'Check permits & outstanding citations',
                onTap: () => _comingSoon(context, 'Vehicle lookup'),
              ),
              _ActionRow(
                icon: Icons.photo_camera_outlined,
                title: 'Capture evidence',
                subtitle: 'GPS + time-stamped photo / video',
                onTap: () => _comingSoon(context, 'Evidence capture'),
              ),
              _ActionRow(
                icon: Icons.sync_outlined,
                title: 'Offline queue',
                subtitle: 'Citations sync when back online',
                onTap: () => _comingSoon(context, 'Offline sync'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HpColors.elevated,
        content: Text('$feature — next build step', style: const TextStyle(color: HpColors.text)),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: HpSpace.x8),
        decoration: BoxDecoration(
          gradient: HpColors.gradient,
          borderRadius: BorderRadius.circular(HpRadius.xl),
          boxShadow: [
            BoxShadow(
              color: HpColors.purple.withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: -8,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 40, color: Colors.white),
            SizedBox(height: HpSpace.x3),
            Text('Scan plate',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Fastest possible vehicle lookup',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HpSpace.x3),
      child: HpCard(
        onTap: onTap,
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
                  Text(title,
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
