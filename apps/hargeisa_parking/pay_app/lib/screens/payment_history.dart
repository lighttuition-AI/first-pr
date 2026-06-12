import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
import '../models/pay_models.dart';
import '../util/format.dart';
import 'citation_detail.dart';

/// Past payments — every citation the citizen has settled. Tap one to see the
/// full citation.
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key, required this.citations, required this.citizen});

  final List<Citation> citations;
  final Citizen citizen;

  @override
  Widget build(BuildContext context) {
    final paid = citations.where((c) => c.status == CitationStatus.paid).toList();
    final total = paid.fold(0, (sum, c) => sum + c.amount);

    return Scaffold(
      appBar: AppBar(title: Text(tr('Payment history'), style: HpType.heading(size: 18))),
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: SafeArea(
          top: false,
          child: paid.isEmpty
              ? Center(child: Text(tr('No payments yet.'), style: HpType.body(size: 14)))
              : ListView(
                  padding: const EdgeInsets.all(HpSpace.x5),
                  children: [
                    HpCard(
                      radius: HpRadius.xl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('TOTAL PAID'), style: HpType.eyebrow),
                          const SizedBox(height: HpSpace.x2),
                          Text(slsh(total), style: HpType.mono(size: 28, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: HpSpace.x5),
                    for (final c in paid)
                      Padding(
                        padding: const EdgeInsets.only(bottom: HpSpace.x3),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => CitationDetailScreen(
                              citation: c,
                              citizen: citizen,
                              repo: null,
                              appeals: null,
                            ),
                          )),
                          child: HpCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(color: HpColors.successTint, borderRadius: BorderRadius.circular(HpRadius.md)),
                                  child: const Icon(Icons.check_rounded, color: HpColors.success),
                                ),
                                const SizedBox(width: HpSpace.x4),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.violation, style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text('${c.id} · ${DateFormat('d MMM yyyy').format(c.issuedAt)}',
                                          style: HpType.body(size: 12, color: HpColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Text(slsh(c.amount), style: HpType.mono(size: 14, weight: FontWeight.w700)),
                                const SizedBox(width: HpSpace.x2),
                                Icon(Icons.chevron_right_rounded, size: 18, color: HpColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
