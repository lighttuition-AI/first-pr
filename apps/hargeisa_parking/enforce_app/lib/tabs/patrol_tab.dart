import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import '../screens/citation_flow.dart';
import '../state/shift_state.dart';

class PatrolTab extends StatelessWidget {
  const PatrolTab({super.key, required this.officer, required this.shift});

  final Officer officer;
  final ShiftState shift;

  void _startCitation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CitationFlow(officer: officer, shift: shift)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final district = districtById(officer.assignedDistrictId);
    return ListView(
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
            _OfflinePill(offline: shift.offline),
          ],
        ),
        const SizedBox(height: HpSpace.x5),
        HpCard(
          radius: HpRadius.xl,
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: HpColors.purpleTint, borderRadius: BorderRadius.circular(HpRadius.md)),
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
              const HpBadge(label: 'On shift', color: HpColors.success, tint: HpColors.successTint, glyph: '●'),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x5),
        _ScanCard(onTap: () => _startCitation(context)),
        const SizedBox(height: HpSpace.x5),
        Row(
          children: [
            Expanded(child: HpKpiCard(label: 'Issued today', value: '${shift.issuedTodayCount}', icon: Icons.receipt_long_outlined)),
            const SizedBox(width: HpSpace.x4),
            Expanded(child: HpKpiCard(label: 'Queued offline', value: '${shift.queuedCount}', icon: Icons.cloud_off_outlined, accent: HpColors.warning)),
          ],
        ),
        const SizedBox(height: HpSpace.x6),
        Text('This shift', style: HpType.heading(size: 16)),
        const SizedBox(height: HpSpace.x3),
        _InfoRow(icon: Icons.directions_car_outlined, title: 'Look up a vehicle', subtitle: 'Check permits & outstanding citations', onTap: () => _startCitation(context)),
        _InfoRow(icon: Icons.receipt_long_outlined, title: 'Issue a citation', subtitle: 'Scan → violation → evidence → issue', onTap: () => _startCitation(context)),
      ],
    );
  }
}

class _OfflinePill extends StatelessWidget {
  const _OfflinePill({required this.offline});
  final bool offline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3, vertical: 6),
      decoration: BoxDecoration(
        color: offline ? HpColors.warningTint : HpColors.successTint,
        borderRadius: BorderRadius.circular(HpRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(offline ? Icons.cloud_off : Icons.cloud_done, size: 14, color: offline ? HpColors.warning : HpColors.success),
          const SizedBox(width: 6),
          Text(offline ? 'Offline' : 'Online',
              style: HpType.body(size: 12, weight: FontWeight.w600, color: offline ? HpColors.warning : HpColors.success)),
        ],
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
          boxShadow: [BoxShadow(color: HpColors.purple.withValues(alpha: 0.45), blurRadius: 28, spreadRadius: -8, offset: const Offset(0, 10))],
        ),
        child: const Column(
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 40, color: Colors.white),
            SizedBox(height: HpSpace.x3),
            Text('Scan plate', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Fastest possible vehicle lookup', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.subtitle, required this.onTap});
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
              decoration: BoxDecoration(color: HpColors.overlay, borderRadius: BorderRadius.circular(HpRadius.md)),
              child: Icon(icon, color: HpColors.text2, size: 20),
            ),
            const SizedBox(width: HpSpace.x4),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: HpColors.textMuted),
          ],
        ),
      ),
    );
  }
}
