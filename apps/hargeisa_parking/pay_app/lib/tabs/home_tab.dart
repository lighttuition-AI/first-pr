import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import '../models/pay_models.dart';
import '../screens/citation_detail.dart';
import '../util/format.dart';
import '../widgets/pay_sheet.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.citizen,
    required this.citations,
    required this.onChanged,
  });

  final Citizen citizen;
  final List<Citation> citations;

  /// Called whenever a citation's state changes (paid / appealed) so the shell
  /// can rebuild the balance + lists.
  final VoidCallback onChanged;

  int get _outstanding => citations
      .where((c) => c.status == CitationStatus.outstanding)
      .fold(0, (sum, c) => sum + c.amount);

  void _payAll(BuildContext context) {
    final amount = _outstanding;
    showPaySheet(context, amount: amount, onPaid: (method) {
      for (final c in citations) {
        if (c.status == CitationStatus.outstanding) c.status = CitationStatus.paid;
      }
      onChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: HpColors.elevated,
          content: Row(children: [
            const Icon(Icons.check_circle, color: HpColors.success, size: 18),
            const SizedBox(width: HpSpace.x3),
            Text('Paid ${slsh(amount)} via $method', style: const TextStyle(color: HpColors.text)),
          ]),
        ),
      );
    });
  }

  void _openDetail(BuildContext context, Citation c) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CitationDetailScreen(citation: c, onChanged: onChanged)),
    ).then((_) => onChanged());
  }

  @override
  Widget build(BuildContext context) {
    final outstanding = _outstanding;
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x5),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Salaan,', style: HpType.body(size: 14)),
                  Text(citizen.fullName, style: HpType.heading(size: 22)),
                ],
              ),
            ),
            HpAvatar(initials: citizen.initials, size: 44),
          ],
        ),
        const SizedBox(height: HpSpace.x5),
        _BalanceCard(outstanding: outstanding, onPay: outstanding > 0 ? () => _payAll(context) : null),
        const SizedBox(height: HpSpace.x6),
        Text('Your citations', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x3),
        for (final c in citations)
          Padding(
            padding: const EdgeInsets.only(bottom: HpSpace.x3),
            child: _CitationCard(citation: c, onTap: () => _openDetail(context, c)),
          ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.outstanding, required this.onPay});
  final int outstanding;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final settled = outstanding == 0;
    return HpCard(
      radius: HpRadius.xxl,
      padding: const EdgeInsets.all(HpSpace.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OUTSTANDING BALANCE', style: HpType.eyebrow),
          const SizedBox(height: HpSpace.x3),
          if (settled)
            Row(children: [
              const Icon(Icons.check_circle, color: HpColors.success, size: 26),
              const SizedBox(width: HpSpace.x3),
              Text('All settled', style: HpType.heading(size: 26, color: HpColors.success)),
            ])
          else
            ShaderMask(
              shaderCallback: (b) => HpColors.gradient.createShader(b),
              child: Text(slsh(outstanding), style: HpType.mono(size: 34, weight: FontWeight.w700, color: Colors.white)),
            ),
          const SizedBox(height: HpSpace.x5),
          HpButton(
            label: settled ? 'Nothing to pay' : 'Pay now',
            size: HpButtonSize.lg,
            expand: true,
            icon: settled ? Icons.done_all_rounded : Icons.account_balance_wallet_outlined,
            onPressed: onPay,
          ),
        ],
      ),
    );
  }
}

class _CitationCard extends StatelessWidget {
  const _CitationCard({required this.citation, required this.onTap});
  final Citation citation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (label, color, tint, glyph) = switch (citation.status) {
      CitationStatus.outstanding => ('Outstanding', HpColors.danger, HpColors.dangerTint, '▲'),
      CitationStatus.paid => ('Paid', HpColors.success, HpColors.successTint, '✓'),
      CitationStatus.appealReview => ('Appeal review', HpColors.purple300, HpColors.purpleTint, '◌'),
    };

    return HpCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: HpSpace.x2, vertical: 3),
                decoration: BoxDecoration(color: HpColors.overlay, borderRadius: BorderRadius.circular(HpRadius.sm), border: Border.all(color: HpColors.borderStrong)),
                child: Text(citation.plate, style: HpType.mono(size: 13, weight: FontWeight.w700)),
              ),
              const Spacer(),
              HpBadge(label: label, color: color, tint: tint, glyph: glyph),
            ],
          ),
          const SizedBox(height: HpSpace.x3),
          Text(citation.violation, style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('${citation.districtName} · ${citation.id}', style: HpType.body(size: 12.5, color: HpColors.textMuted)),
          const SizedBox(height: HpSpace.x3),
          Row(
            children: [
              Text(slsh(citation.amount), style: HpType.mono(size: 18, weight: FontWeight.w700, color: HpColors.text)),
              const Spacer(),
              const Icon(Icons.chevron_right, color: HpColors.textMuted, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
