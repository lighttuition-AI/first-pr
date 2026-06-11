import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

class OfficersPage extends StatelessWidget {
  const OfficersPage({super.key, required this.repo});

  final OfficerRepository repo;

  @override
  Widget build(BuildContext context) {
    final officers = repo.officers;
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        Text('${officers.length} officers', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x2),
        Text('Everyone who has registered for HPark Enforce, with their current access state.',
            style: HpType.body(size: 13.5)),
        const SizedBox(height: HpSpace.x5),
        HpCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < officers.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _Row(officer: officers[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.officer});
  final Officer officer;

  @override
  Widget build(BuildContext context) {
    final district = districtById(officer.assignedDistrictId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
      child: Row(
        children: [
          HpAvatar(
            initials: officer.initials,
            size: 40,
            statusColor: officer.canUseOfficerApp ? HpColors.success : null,
          ),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(officer.fullName,
                    style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600)),
                Text(officer.badgeNumber, style: HpType.mono(size: 12.5, color: HpColors.textMuted)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              district?.name ?? '—',
              style: HpType.body(size: 13.5, color: HpColors.text2),
            ),
          ),
          HpBadge.status(officer.status),
        ],
      ),
    );
  }
}
