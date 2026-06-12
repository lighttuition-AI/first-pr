import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

/// Operations overview. Every number is computed live from Firestore — officers
/// from the repository, the rest from the citations stream. No mock data.
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.repo,
    required this.citations,
    required this.onSeeApprovals,
  });

  final OfficerRepository repo;
  final List<Citation> citations;

  /// Jump to the approvals queue. Null for normal users (who can't approve), so
  /// the pending-approvals banner is hidden for them.
  final VoidCallback? onSeeApprovals;

  @override
  Widget build(BuildContext context) {
    final pending = repo.pending.length;
    final activeOfficers = repo.approved.length;

    final total = citations.length;
    final outstanding = citations.where((c) => c.status == CitationStatus.outstanding).length;
    final paid = citations.where((c) => c.status == CitationStatus.paid).toList();
    final resolved = citations
        .where((c) => c.status == CitationStatus.paid || c.status == CitationStatus.dismissed)
        .length;
    final revenue = paid.fold<int>(0, (s, c) => s + c.amount);
    final compliance = total == 0 ? 100 : ((resolved / total) * 100).round();

    // Live citations-issued count per officer (by auth uid).
    final byOfficer = <String, int>{};
    for (final c in citations) {
      if (c.officerId.isNotEmpty) byOfficer[c.officerId] = (byOfficer[c.officerId] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        if (pending > 0 && onSeeApprovals != null) ...[
          _PendingBanner(count: pending, onReview: onSeeApprovals!),
          const SizedBox(height: HpSpace.x6),
        ],
        _ComplianceHero(compliance: compliance, total: total),
        const SizedBox(height: HpSpace.x6),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 1040 ? 4 : (c.maxWidth > 560 ? 2 : 1);
            final cards = [
              HpKpiCard(
                label: 'Revenue collected',
                value: 'SLSH ${_money(revenue)}',
                delta: '${paid.length} paid',
                icon: Icons.payments_outlined,
              ),
              HpKpiCard(
                label: 'Active officers',
                value: '$activeOfficers',
                delta: 'on patrol',
                icon: Icons.badge_outlined,
                accent: HpColors.teal,
              ),
              HpKpiCard(
                label: 'Citations issued',
                value: '$total',
                delta: '$outstanding open',
                icon: Icons.receipt_long_outlined,
                accent: HpColors.success,
              ),
              HpKpiCard(
                label: 'Outstanding',
                value: '$outstanding',
                delta: 'unpaid',
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
              childAspectRatio: 1.8,
              children: cards,
            );
          },
        ),
        const SizedBox(height: HpSpace.x6),
        Text('Officers on duty', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x4),
        if (repo.approved.isEmpty)
          HpCard(
            padding: const EdgeInsets.symmetric(vertical: HpSpace.x10),
            child: Center(child: Text('No approved officers yet.', style: HpType.body(size: 14))),
          )
        else
          HpCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < repo.approved.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _OfficerRow(
                    officer: repo.approved[i],
                    citationCount: byOfficer[repo.approved[i].id] ?? 0,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

String _money(int v) {
  if (v == 0) return '0';
  return NumberFormat.compact().format(v); // 4.2M / 370K / 250
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
  const _ComplianceHero({required this.compliance, required this.total});
  final int compliance;
  final int total;

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
                  child: Text('$compliance%',
                      style: HpType.heading(size: 64, weight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(height: HpSpace.x2),
                Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 16, color: HpColors.text2),
                    const SizedBox(width: 6),
                    Text(
                      '$total citation${total == 1 ? '' : 's'} · ${kHargeisaDistricts.length} districts · Hargeisa',
                      style: HpType.body(size: 14),
                    ),
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
  const _OfficerRow({required this.officer, required this.citationCount});
  final Officer officer;
  final int citationCount;

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
          Text('$citationCount citation${citationCount == 1 ? '' : 's'}',
              style: HpType.mono(size: 13, color: HpColors.text2)),
        ],
      ),
    );
  }
}
