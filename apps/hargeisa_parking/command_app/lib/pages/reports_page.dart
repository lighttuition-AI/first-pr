import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

/// Reporting — everything computed live from the citations stream. No mock data.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key, required this.citations});

  final List<Citation> citations;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        Text('Reports', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x2),
        Text('Citations, payments and revenue across Hargeisa.', style: HpType.body(size: 13.5)),
        const SizedBox(height: HpSpace.x6),
        LayoutBuilder(
          builder: (context, c) {
            final twoCol = c.maxWidth > 900;
            final trend = HpCard(child: _CitationsTrend(citations: citations));
            final split = HpCard(child: _StatusSplit(citations: citations));
            if (twoCol) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: trend),
                  const SizedBox(width: HpSpace.x4),
                  Expanded(flex: 2, child: split),
                ],
              );
            }
            return Column(children: [trend, const SizedBox(height: HpSpace.x4), split]);
          },
        ),
        const SizedBox(height: HpSpace.x4),
        HpCard(child: _RevenueByDistrict(citations: citations)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, {this.trailing});
  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: HpType.heading(size: 16)),
        const Spacer(),
        if (trailing != null)
          Text(trailing!, style: HpType.body(size: 13, weight: FontWeight.w600, color: HpColors.text2)),
      ],
    );
  }
}

class _CitationsTrend extends StatelessWidget {
  const _CitationsTrend({required this.citations});
  final List<Citation> citations;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final days = List.generate(7, (i) => base.subtract(Duration(days: 6 - i)));
    final values = days
        .map((d) => citations.where((c) {
              final ci = DateTime(c.issuedAt.year, c.issuedAt.month, c.issuedAt.day);
              return ci == d;
            }).length)
        .toList();
    final labels = days.map((d) => DateFormat('EEE').format(d)).toList();
    final maxV = values.fold<int>(1, (m, v) => v > m ? v : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Citations this week', trailing: '${values.fold<int>(0, (s, v) => s + v)} total'),
        const SizedBox(height: HpSpace.x5),
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < days.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${values[i]}', style: HpType.mono(size: 12, color: HpColors.text2)),
                        const SizedBox(height: 6),
                        Container(
                          height: 4 + 106 * (values[i] / maxV),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [HpColors.purple, HpColors.teal],
                            ),
                            borderRadius: BorderRadius.circular(HpRadius.sm),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(labels[i], style: HpType.body(size: 11, color: HpColors.textMuted)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusSplit extends StatelessWidget {
  const _StatusSplit({required this.citations});
  final List<Citation> citations;

  int _count(CitationStatus s) => citations.where((c) => c.status == s).length;

  @override
  Widget build(BuildContext context) {
    final outstanding = _count(CitationStatus.outstanding);
    final paid = _count(CitationStatus.paid);
    final review = _count(CitationStatus.appealReview);
    final dismissed = _count(CitationStatus.dismissed);
    final total = citations.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Citations by status'),
        const SizedBox(height: HpSpace.x5),
        if (total == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: HpSpace.x6),
            child: Center(child: Text('No citations yet.', style: HpType.body(size: 13))),
          )
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(HpRadius.pill),
            child: Row(
              children: [
                if (outstanding > 0) Expanded(flex: outstanding, child: Container(height: 16, color: HpColors.danger)),
                if (paid > 0) Expanded(flex: paid, child: Container(height: 16, color: HpColors.success)),
                if (review > 0) Expanded(flex: review, child: Container(height: 16, color: HpColors.purple300)),
                if (dismissed > 0) Expanded(flex: dismissed, child: Container(height: 16, color: HpColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: HpSpace.x4),
          _legend(HpColors.danger, 'Outstanding', '$outstanding'),
          const SizedBox(height: HpSpace.x3),
          _legend(HpColors.success, 'Paid', '$paid'),
          const SizedBox(height: HpSpace.x3),
          _legend(HpColors.purple300, 'Under appeal', '$review'),
          const SizedBox(height: HpSpace.x3),
          _legend(HpColors.textMuted, 'Dismissed', '$dismissed'),
        ],
      ],
    );
  }

  Widget _legend(Color color, String label, String value) => Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: HpSpace.x3),
          Expanded(child: Text(label, style: HpType.body(size: 13, color: HpColors.text2))),
          Text(value, style: HpType.mono(size: 13, weight: FontWeight.w700)),
        ],
      );
}

class _RevenueByDistrict extends StatelessWidget {
  const _RevenueByDistrict({required this.citations});
  final List<Citation> citations;

  @override
  Widget build(BuildContext context) {
    final byDistrict = <String, int>{};
    for (final c in citations) {
      if (c.status == CitationStatus.paid) {
        final key = c.districtName.isEmpty ? 'Unassigned' : c.districtName;
        byDistrict[key] = (byDistrict[key] ?? 0) + c.amount;
      }
    }
    final entries = byDistrict.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxV = entries.fold<int>(1, (m, e) => e.value > m ? e.value : m);
    final money = NumberFormat.compact();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Revenue by district', trailing: 'SLSH collected'),
        const SizedBox(height: HpSpace.x5),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: HpSpace.x6),
            child: Center(child: Text('No payments collected yet.', style: HpType.body(size: 13))),
          )
        else
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: HpSpace.x3),
              child: Row(
                children: [
                  SizedBox(width: 150, child: Text(e.key, style: HpType.body(size: 13, color: HpColors.text2), overflow: TextOverflow.ellipsis)),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(height: 22, decoration: BoxDecoration(color: HpColors.overlay, borderRadius: BorderRadius.circular(HpRadius.sm))),
                        FractionallySizedBox(
                          widthFactor: (e.value / maxV).clamp(0.02, 1.0),
                          child: Container(
                            height: 22,
                            decoration: BoxDecoration(
                              gradient: HpColors.gradient,
                              borderRadius: BorderRadius.circular(HpRadius.sm),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: HpSpace.x3),
                  SizedBox(width: 64, child: Text(money.format(e.value), textAlign: TextAlign.right, style: HpType.mono(size: 13, weight: FontWeight.w700))),
                ],
              ),
            ),
      ],
    );
  }
}
