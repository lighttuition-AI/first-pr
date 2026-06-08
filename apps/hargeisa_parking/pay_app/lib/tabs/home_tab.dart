import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

import '../models/pay_models.dart';

final _money = NumberFormat.decimalPattern('en');

String slsh(int amount) => 'SLSH ${_money.format(amount)}';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.citizen,
    required this.citations,
    required this.onPaidAll,
  });

  final Citizen citizen;
  final List<Citation> citations;
  final VoidCallback onPaidAll;

  int get _outstanding => citations
      .where((c) => c.status == CitationStatus.outstanding)
      .fold(0, (sum, c) => sum + c.amount);

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
        _BalanceCard(
          outstanding: outstanding,
          onPay: outstanding > 0 ? () => _openPaySheet(context, outstanding) : null,
        ),
        const SizedBox(height: HpSpace.x6),
        Text('Your citations', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x3),
        for (final c in citations)
          Padding(
            padding: const EdgeInsets.only(bottom: HpSpace.x3),
            child: _CitationCard(citation: c),
          ),
      ],
    );
  }

  void _openPaySheet(BuildContext context, int amount) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: HpColors.elevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HpRadius.xl)),
      ),
      builder: (sheetCtx) => _PaySheet(
        amount: amount,
        onPaid: (method) {
          Navigator.pop(sheetCtx);
          onPaidAll();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: HpColors.elevated,
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: HpColors.success, size: 18),
                  const SizedBox(width: HpSpace.x3),
                  Text('Paid ${slsh(amount)} via $method',
                      style: const TextStyle(color: HpColors.text)),
                ],
              ),
            ),
          );
        },
      ),
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
            Row(
              children: [
                const Icon(Icons.check_circle, color: HpColors.success, size: 26),
                const SizedBox(width: HpSpace.x3),
                Text('All settled', style: HpType.heading(size: 26, color: HpColors.success)),
              ],
            )
          else
            ShaderMask(
              shaderCallback: (b) => HpColors.gradient.createShader(b),
              child: Text(slsh(outstanding),
                  style: HpType.mono(size: 34, weight: FontWeight.w700, color: Colors.white)),
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
  const _CitationCard({required this.citation});
  final Citation citation;

  @override
  Widget build(BuildContext context) {
    final (label, color, tint, glyph) = switch (citation.status) {
      CitationStatus.outstanding => ('Outstanding', HpColors.danger, HpColors.dangerTint, '▲'),
      CitationStatus.paid => ('Paid', HpColors.success, HpColors.successTint, '✓'),
      CitationStatus.appealReview => ('Appeal review', HpColors.purple300, HpColors.purpleTint, '◌'),
    };

    return HpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: HpSpace.x2, vertical: 3),
                decoration: BoxDecoration(
                  color: HpColors.overlay,
                  borderRadius: BorderRadius.circular(HpRadius.sm),
                  border: Border.all(color: HpColors.borderStrong),
                ),
                child: Text(citation.plate, style: HpType.mono(size: 13, weight: FontWeight.w700)),
              ),
              const Spacer(),
              HpBadge(label: label, color: color, tint: tint, glyph: glyph),
            ],
          ),
          const SizedBox(height: HpSpace.x3),
          Text(citation.violation,
              style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('${citation.districtName} · ${citation.id}',
              style: HpType.body(size: 12.5, color: HpColors.textMuted)),
          const SizedBox(height: HpSpace.x3),
          Text(slsh(citation.amount),
              style: HpType.mono(size: 18, weight: FontWeight.w700, color: HpColors.text)),
        ],
      ),
    );
  }
}

class _PaySheet extends StatelessWidget {
  const _PaySheet({required this.amount, required this.onPaid});
  final int amount;
  final ValueChanged<String> onPaid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: HpSpace.x5,
        right: HpSpace.x5,
        top: HpSpace.x5,
        bottom: HpSpace.x6 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: HpColors.borderStrong,
                borderRadius: BorderRadius.circular(HpRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: HpSpace.x5),
          Text('Pay ${slsh(amount)}', style: HpType.heading(size: 22)),
          const SizedBox(height: HpSpace.x2),
          Text('Choose a mobile money provider.', style: HpType.body(size: 14)),
          const SizedBox(height: HpSpace.x5),
          _ProviderTile(
            name: 'ZAAD',
            provider: 'Telesom',
            color: HpColors.teal,
            onTap: () => onPaid('ZAAD'),
          ),
          const SizedBox(height: HpSpace.x3),
          _ProviderTile(
            name: 'eDahab',
            provider: 'Dahabshiil',
            color: HpColors.purple300,
            onTap: () => onPaid('eDahab'),
          ),
        ],
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.name,
    required this.provider,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String provider;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(HpRadius.md),
            ),
            child: Icon(Icons.smartphone_rounded, color: color),
          ),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w700, fontSize: 16)),
                Text(provider, style: HpType.body(size: 12.5, color: HpColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: HpColors.textMuted),
        ],
      ),
    );
  }
}
