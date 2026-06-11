import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.repo, required this.onSeeApprovals});

  final OfficerRepository repo;
  final VoidCallback onSeeApprovals;

  @override
  Widget build(BuildContext context) {
    final pending = repo.pending.length;
    final activeOfficers = repo.approved.length;

    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        if (pending > 0) ...[
          _PendingBanner(count: pending, onReview: onSeeApprovals),
          const SizedBox(height: HpSpace.x6),
        ],
        const _ComplianceHero(),
        const SizedBox(height: HpSpace.x6),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 1040 ? 4 : (c.maxWidth > 560 ? 2 : 1);
            final cards = [
              const HpKpiCard(
                label: 'Revenue today',
                value: 'SLSH 4.2M',
                delta: '+12%',
                icon: Icons.payments_outlined,
              ),
              HpKpiCard(
                label: 'Active officers',
                value: '$activeOfficers',
                delta: 'on patrol',
                icon: Icons.badge_outlined,
                accent: HpColors.teal,
              ),
              const HpKpiCard(
                label: 'Compliance rate',
                value: '87%',
                delta: '+4%',
                icon: Icons.verified_outlined,
                accent: HpColors.success,
              ),
              const HpKpiCard(
                label: 'Active violations',
                value: '38',
                delta: '-6%',
                deltaUp: false,
                icon: Icons.report_gmailerrorred_outlined,
                accent: HpColors.danger,
              ),
            ];
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: HpSpace.x4,
              mainAxisSpacing: HpSpace.x4,
              childAspectRatio: 1.9,
              children: cards,
            );
          },
        ),
        const SizedBox(height: HpSpace.x6),
        Text('Officers on duty', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x4),
        HpCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < repo.approved.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _OfficerRow(officer: repo.approved[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.count, required this.onReview});
  final int count;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      borderColor: HpColors.warning.withValues(alpha: 0.4),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: HpColors.warningTint,
              borderRadius: BorderRadius.circular(HpRadius.md),
            ),
            child: const Icon(Icons.pending_actions_outlined, color: HpColors.warning),
          ),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count officer${count == 1 ? '' : 's'} waiting for approval',
                  style: HpType.heading(size: 16),
                ),
                Text('Review their identity before they can sign in to HPark Enforce.',
                    style: HpType.body(size: 13)),
              ],
            ),
          ),
          HpButton(label: 'Review now', onPressed: onReview),
        ],
      ),
    );
  }
}

class _ComplianceHero extends StatelessWidget {
  const _ComplianceHero();

  @override
  Widget build(BuildContext context) {
    return HpCard(
      radius: HpRadius.xxl,
      padding: const EdgeInsets.all(HpSpace.x8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('CITY COMPLIANCE', style: HpType.eyebrow),
                const SizedBox(height: HpSpace.x3),
                ShaderMask(
                  shaderCallback: (b) => HpColors.gradient.createShader(b),
                  child: Text('87%',
                      style: HpType.heading(size: 64, weight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(height: HpSpace.x2),
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, size: 16, color: HpColors.success),
                    const SizedBox(width: 4),
                    Text('+4% this week',
                        style: HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.success)),
                    const SizedBox(width: HpSpace.x3),
                    Text('· 8 districts · Hargeisa', style: HpType.body(size: 14)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              gradient: HpColors.gradientSoft,
              borderRadius: BorderRadius.circular(HpRadius.xl),
            ),
            child: const Icon(Icons.trending_up_rounded, size: 48, color: HpColors.teal),
          ),
        ],
      ),
    );
  }
}

class _OfficerRow extends StatelessWidget {
  const _OfficerRow({required this.officer});
  final Officer officer;

  @override
  Widget build(BuildContext context) {
    final district = districtById(officer.assignedDistrictId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
      child: Row(
        children: [
          HpAvatar(initials: officer.initials, size: 38, statusColor: HpColors.success),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(officer.fullName,
                    style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600)),
                Text(district?.name ?? 'Unassigned',
                    style: HpType.body(size: 12.5, color: HpColors.textMuted)),
              ],
            ),
          ),
          Text('${officer.citationsIssued} citations',
              style: HpType.mono(size: 13, color: HpColors.text2)),
        ],
      ),
    );
  }
}
