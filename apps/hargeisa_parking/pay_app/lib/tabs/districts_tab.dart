import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/pay_data.dart';
import '../models/pay_models.dart';

/// Browse Hargeisa's 8 districts; each opens the shop deals advertised there.
class DistrictsTab extends StatelessWidget {
  const DistrictsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x5),
      children: [
        Text('Districts & deals', style: HpType.heading(size: 22)),
        const SizedBox(height: HpSpace.x2),
        Text('Tap a district to see shops advertising deals nearby.',
            style: HpType.body(size: 14)),
        const SizedBox(height: HpSpace.x5),
        for (final d in kHargeisaDistricts)
          Padding(
            padding: const EdgeInsets.only(bottom: HpSpace.x3),
            child: _DistrictCard(district: d),
          ),
      ],
    );
  }
}

class _DistrictCard extends StatelessWidget {
  const _DistrictCard({required this.district});
  final District district;

  @override
  Widget build(BuildContext context) {
    final count = dealsForDistrict(district.id).length;
    return HpCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DealsScreen(district: district)),
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              gradient: HpColors.gradientSoft,
              borderRadius: BorderRadius.circular(HpRadius.md),
            ),
            child: const Icon(Icons.location_on_outlined, color: HpColors.purple300),
          ),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(district.name, style: HpType.heading(size: 16)),
                Text(count == 0 ? 'No deals yet' : '$count deal${count == 1 ? '' : 's'} available',
                    style: HpType.body(size: 12.5, color: HpColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: HpColors.textMuted),
        ],
      ),
    );
  }
}

class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key, required this.district});
  final District district;

  @override
  Widget build(BuildContext context) {
    final deals = dealsForDistrict(district.id);
    return Scaffold(
      appBar: AppBar(title: Text(district.name, style: HpType.heading(size: 18))),
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: deals.isEmpty
            ? Center(
                child: Text('No deals in this district yet.', style: HpType.body(size: 14)),
              )
            : ListView(
                padding: const EdgeInsets.all(HpSpace.x5),
                children: [
                  for (final deal in deals)
                    Padding(
                      padding: const EdgeInsets.only(bottom: HpSpace.x3),
                      child: _DealCard(deal: deal),
                    ),
                ],
              ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal});
  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      onTap: () => showDialog<void>(context: context, builder: (_) => _CouponDialog(deal: deal)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    HpBadge(
                      label: deal.category,
                      color: HpColors.teal,
                      tint: HpColors.tealTint,
                    ),
                  ],
                ),
                const SizedBox(height: HpSpace.x3),
                Text(deal.title, style: HpType.heading(size: 16)),
                const SizedBox(height: 2),
                Text(deal.shop, style: HpType.body(size: 13, color: HpColors.text2)),
              ],
            ),
          ),
          const Icon(Icons.qr_code_2_rounded, color: HpColors.purple300, size: 30),
        ],
      ),
    );
  }
}

/// The coupon — a real scannable QR encoding the deal code, redeemed at the till.
class _CouponDialog extends StatelessWidget {
  const _CouponDialog({required this.deal});
  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HpColors.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
      child: Padding(
        padding: const EdgeInsets.all(HpSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(deal.shop, style: HpType.eyebrow),
            const SizedBox(height: HpSpace.x2),
            Text(deal.title, textAlign: TextAlign.center, style: HpType.heading(size: 20)),
            const SizedBox(height: HpSpace.x5),
            Container(
              padding: const EdgeInsets.all(HpSpace.x4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(HpRadius.lg),
              ),
              child: QrImageView(
                data: 'HPARK-DEAL:${deal.code}',
                size: 176,
                gapless: true,
                // ignore: deprecated_member_use
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: HpSpace.x4),
            Text('Scan at the till to redeem', style: HpType.body(size: 13)),
            const SizedBox(height: 4),
            Text(deal.code, style: HpType.mono(size: 15, weight: FontWeight.w700)),
            const SizedBox(height: HpSpace.x5),
            HpButton(
              label: 'Done',
              variant: HpButtonVariant.secondary,
              expand: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
