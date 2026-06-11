import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import '../l10n/strings.dart';
import '../models/pay_models.dart';
import '../screens/citation_detail.dart';
import '../util/format.dart';
import '../widgets/pay_sheet.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.citizen,
    required this.citations,
    required this.repo,
    required this.appeals,
    required this.onAddPlate,
    required this.onOpenProfile,
  });

  final Citizen citizen;
  final List<Citation> citations;
  final FirebaseCitationRepository repo;
  final FirebaseAppealRepository appeals;

  /// Prompt the citizen to set their vehicle plate (so their citations load).
  final VoidCallback onAddPlate;

  /// Open the Profile tab (tapping the avatar).
  final VoidCallback onOpenProfile;

  int get _outstanding => citations
      .where((c) => c.status == CitationStatus.outstanding)
      .fold(0, (sum, c) => sum + c.amount);

  void _payAll(BuildContext context) {
    final amount = _outstanding;
    showPaySheet(context, amount: amount, onPaid: (method) {
      for (final c in citations) {
        if (c.status == CitationStatus.outstanding) {
          c.status = CitationStatus.paid; // optimistic; the stream reconciles
          repo.setStatus(c.id, CitationStatus.paid);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: HpColors.elevated,
          content: Row(children: [
            const Icon(Icons.check_circle, color: HpColors.success, size: 18),
            const SizedBox(width: HpSpace.x3),
            Text(trf('Paid {amount} via {method}', {'amount': slsh(amount), 'method': method}), style: TextStyle(color: HpColors.text)),
          ]),
        ),
      );
    });
  }

  void _openDetail(BuildContext context, Citation c) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CitationDetailScreen(
          citation: c,
          citizen: citizen,
          repo: repo,
          appeals: appeals,
        ),
      ),
    );
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
            GestureDetector(
              onTap: onOpenProfile,
              behavior: HitTestBehavior.opaque,
              child: HpAvatar(initials: citizen.initials, size: 44),
            ),
          ],
        ),
        const SizedBox(height: HpSpace.x5),
        if (citizen.plate.isEmpty)
          _AddPlateCard(onAddPlate: onAddPlate)
        else ...[
          _BalanceCard(outstanding: outstanding, onPay: outstanding > 0 ? () => _payAll(context) : null),
          const SizedBox(height: HpSpace.x6),
          Row(children: [
            Expanded(child: Text(tr('Your citations'), style: HpType.heading(size: 18))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: HpSpace.x2, vertical: 3),
              decoration: BoxDecoration(color: HpColors.overlay, borderRadius: BorderRadius.circular(HpRadius.sm), border: Border.all(color: HpColors.borderStrong)),
              child: Text(citizen.plate, style: HpType.mono(size: 13, weight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: HpSpace.x3),
          if (citations.isEmpty)
            HpCard(
              padding: const EdgeInsets.symmetric(vertical: HpSpace.x10),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_outlined, size: 36, color: HpColors.success),
                    const SizedBox(height: HpSpace.x3),
                    Text(tr('No citations'), style: HpType.heading(size: 16)),
                    const SizedBox(height: 4),
                    Text(trf('You have a clean record for {plate}.', {'plate': citizen.plate}), style: HpType.body(size: 13)),
                  ],
                ),
              ),
            )
          else
            for (final c in citations)
              Padding(
                padding: const EdgeInsets.only(bottom: HpSpace.x3),
                child: _CitationCard(citation: c, onTap: () => _openDetail(context, c)),
              ),
        ],
      ],
    );
  }
}

class _AddPlateCard extends StatelessWidget {
  const _AddPlateCard({required this.onAddPlate});
  final VoidCallback onAddPlate;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      radius: HpRadius.xxl,
      padding: const EdgeInsets.all(HpSpace.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: HpColors.purpleTint, borderRadius: BorderRadius.circular(HpRadius.md)),
            child: const Icon(Icons.directions_car_outlined, color: HpColors.purple300),
          ),
          const SizedBox(height: HpSpace.x4),
          Text(tr('Add your vehicle'), style: HpType.heading(size: 20)),
          const SizedBox(height: HpSpace.x2),
          Text(tr('Enter your number plate to see and pay your parking citations.'),
              style: HpType.body(size: 14)),
          const SizedBox(height: HpSpace.x5),
          HpButton(
            label: tr('Add number plate'),
            icon: Icons.add_rounded,
            size: HpButtonSize.lg,
            expand: true,
            onPressed: onAddPlate,
          ),
        ],
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
          Text(tr('OUTSTANDING BALANCE'), style: HpType.eyebrow),
          const SizedBox(height: HpSpace.x3),
          if (settled)
            Row(children: [
              const Icon(Icons.check_circle, color: HpColors.success, size: 26),
              const SizedBox(width: HpSpace.x3),
              Text(tr('All settled'), style: HpType.heading(size: 26, color: HpColors.success)),
            ])
          else
            ShaderMask(
              shaderCallback: (b) => HpColors.gradient.createShader(b),
              child: Text(slsh(outstanding), style: HpType.mono(size: 34, weight: FontWeight.w700, color: Colors.white)),
            ),
          const SizedBox(height: HpSpace.x5),
          HpButton(
            label: tr(settled ? 'Nothing to pay' : 'Pay now'),
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
    final status = citation.status;
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
              HpBadge(label: tr(status.label), color: status.color, tint: status.tint, glyph: status.glyph),
            ],
          ),
          const SizedBox(height: HpSpace.x3),
          Text(citation.violation, style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('${citation.districtName} · ${citation.id}', style: HpType.body(size: 12.5, color: HpColors.textMuted)),
          const SizedBox(height: HpSpace.x3),
          Row(
            children: [
              Text(slsh(citation.amount), style: HpType.mono(size: 18, weight: FontWeight.w700, color: HpColors.text)),
              const Spacer(),
              Icon(Icons.chevron_right, color: HpColors.textMuted, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
