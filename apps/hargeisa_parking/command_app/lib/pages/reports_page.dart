import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

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
            final trend = HpCard(
              child: _CitationsTrend(),
            );
            final split = HpCard(child: _PaymentSplit());
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
        HpCard(child: _RevenueByDistrict()),
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
          Text(trailing!, style: HpType.body(size: 13, weight: FontWeight.w600, color: HpColors.success)),
      ],
    );
  }
}

class _CitationsTrend extends StatelessWidget {
  // Citations issued over the last 7 days.
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _values = [28, 34, 31, 42, 38, 22, 19];

  @override
  Widget build(BuildContext context) {
    final maxV = _values.reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Citations this week', trailing: '+8% vs last week'),
        const SizedBox(height: HpSpace.x5),
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < _days.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${_values[i]}', style: HpType.mono(size: 12, color: HpColors.text2)),
                        const SizedBox(height: 6),
                        Container(
                          height: 110 * (_values[i] / maxV),
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
                        Text(_days[i], style: HpType.body(size: 11, color: HpColors.textMuted)),
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

class _PaymentSplit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const zaad = 62;
    const edahab = 38;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Payments'),
        const SizedBox(height: HpSpace.x5),
        ClipRRect(
          borderRadius: BorderRadius.circular(HpRadius.pill),
          child: Row(
            children: [
              Expanded(flex: zaad, child: Container(height: 16, color: HpColors.teal)),
              Expanded(flex: edahab, child: Container(height: 16, color: HpColors.purple)),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x4),
        _legend(HpColors.teal, 'ZAAD · Telesom', '$zaad%'),
        const SizedBox(height: HpSpace.x3),
        _legend(HpColors.purple, 'eDahab · Dahabshiil', '$edahab%'),
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
  // Synthesised monthly revenue (SLSH millions) per district.
  static const _revenue = {
    'Ahmed Dhagah': 6.2,
    'Mohamed Mooge': 5.4,
    '26 June': 4.8,
    'Ibrahim Koodbuur': 4.1,
    '31 May': 3.6,
    'Maxamuud Haybe': 2.9,
    'Gacan Libaax': 2.4,
    'Macalin Haroon': 2.1,
  };

  @override
  Widget build(BuildContext context) {
    final maxV = _revenue.values.reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Revenue by district', trailing: 'SLSH, this month'),
        const SizedBox(height: HpSpace.x5),
        for (final e in _revenue.entries)
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
                        widthFactor: e.value / maxV,
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
                SizedBox(width: 54, child: Text('${e.value}M', textAlign: TextAlign.right, style: HpType.mono(size: 13, weight: FontWeight.w700))),
              ],
            ),
          ),
      ],
    );
  }
}
