import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import '../state/shift_state.dart';

class OfficerProfileTab extends StatelessWidget {
  const OfficerProfileTab({
    super.key,
    required this.officer,
    required this.shift,
    required this.onSignOut,
  });

  final Officer officer;
  final ShiftState shift;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final district = districtById(officer.assignedDistrictId);
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x5),
      children: [
        const SizedBox(height: HpSpace.x4),
        Center(child: HpAvatar(initials: officer.initials, size: 84, statusColor: HpColors.success)),
        const SizedBox(height: HpSpace.x4),
        Center(child: Text(officer.fullName, style: HpType.heading(size: 22))),
        const SizedBox(height: 4),
        Center(child: Text(officer.badgeNumber, style: HpType.mono(size: 13, color: HpColors.text2))),
        const SizedBox(height: HpSpace.x6),
        HpCard(
          child: Column(
            children: [
              _kv('Officer ID', officer.id, mono: true),
              const Divider(height: HpSpace.x6),
              _kv('Assigned district', district?.name ?? 'Unassigned'),
              const Divider(height: HpSpace.x6),
              _kv('Status', officer.status.label),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x5),
        Text('Connectivity', style: HpType.heading(size: 16)),
        const SizedBox(height: HpSpace.x3),
        HpCard(
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: shift.offline ? HpColors.warningTint : HpColors.successTint,
                  borderRadius: BorderRadius.circular(HpRadius.md),
                ),
                child: Icon(shift.offline ? Icons.cloud_off : Icons.cloud_done,
                    color: shift.offline ? HpColors.warning : HpColors.success, size: 20),
              ),
              const SizedBox(width: HpSpace.x4),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shift.offline ? 'Offline mode' : 'Online',
                        style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(
                      shift.offline
                          ? 'Citations queue locally and sync when back online'
                          : 'Citations sync to HPark Command in real time',
                      style: HpType.body(size: 12.5, color: HpColors.textMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: shift.offline,
                onChanged: (v) => shift.setOffline(v),
                activeThumbColor: HpColors.warning,
                inactiveThumbColor: HpColors.text2,
                inactiveTrackColor: HpColors.overlay,
              ),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x5),
        Text('Appearance', style: HpType.heading(size: 16)),
        const SizedBox(height: HpSpace.x3),
        HpCard(
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: HpColors.overlay, borderRadius: BorderRadius.circular(HpRadius.md)),
                child: Icon(hpTheme.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: HpColors.text2, size: 20),
              ),
              const SizedBox(width: HpSpace.x4),
              Expanded(
                child: Text(hpTheme.isDark ? 'Dark theme' : 'Light theme',
                    style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              Switch(
                value: hpTheme.isDark,
                onChanged: (v) => hpTheme.setDark(v),
                activeThumbColor: HpColors.purple300,
                inactiveThumbColor: HpColors.text2,
                inactiveTrackColor: HpColors.overlay,
              ),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x6),
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

  Widget _kv(String k, String v, {bool mono = false}) => Row(
        children: [
          Text(k, style: HpType.body(size: 13.5, color: HpColors.textMuted)),
          const Spacer(),
          Text(v, style: mono ? HpType.mono(size: 14) : HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.text)),
        ],
      );
}
