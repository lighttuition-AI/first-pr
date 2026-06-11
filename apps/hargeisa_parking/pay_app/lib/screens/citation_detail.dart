import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';
import 'package:intl/intl.dart';

import '../models/pay_models.dart';
import '../util/format.dart';
import '../widgets/pay_sheet.dart';
import 'appeal_flow.dart';

/// Detail view for one citation, with Pay / Challenge actions backed by Firestore.
class CitationDetailScreen extends StatefulWidget {
  const CitationDetailScreen({
    super.key,
    required this.citation,
    required this.citizen,
    required this.repo,
    required this.appeals,
  });

  final Citation citation;
  final Citizen citizen;
  final FirebaseCitationRepository repo;
  final FirebaseAppealRepository appeals;

  @override
  State<CitationDetailScreen> createState() => _CitationDetailScreenState();
}

class _CitationDetailScreenState extends State<CitationDetailScreen> {
  Citation get c => widget.citation;

  void _pay() {
    showPaySheet(context, amount: c.amount, onPaid: (method) {
      setState(() => c.status = CitationStatus.paid);
      widget.repo.setStatus(c.id, CitationStatus.paid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: HpColors.elevated,
          content: Row(children: [
            const Icon(Icons.check_circle, color: HpColors.success, size: 18),
            const SizedBox(width: HpSpace.x3),
            Text('Paid ${slsh(c.amount)} via $method', style: const TextStyle(color: HpColors.text)),
          ]),
        ),
      );
    });
  }

  Future<void> _appeal() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppealFlow(
          citation: c,
          appellantName: widget.citizen.fullName,
          repo: widget.repo,
          appeals: widget.appeals,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final (label, color, tint, glyph) =
        (c.status.label, c.status.color, c.status.tint, c.status.glyph);

    return Scaffold(
      appBar: AppBar(title: Text('Citation', style: HpType.heading(size: 18))),
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(HpSpace.x5),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3, vertical: 6),
                          decoration: BoxDecoration(color: HpColors.overlay, borderRadius: BorderRadius.circular(HpRadius.sm), border: Border.all(color: HpColors.borderStrong)),
                          child: Text(c.plate, style: HpType.mono(size: 16, weight: FontWeight.w700)),
                        ),
                        const Spacer(),
                        HpBadge(label: label, color: color, tint: tint, glyph: glyph),
                      ],
                    ),
                    const SizedBox(height: HpSpace.x5),
                    Text(c.violation, style: HpType.heading(size: 20)),
                    const SizedBox(height: HpSpace.x5),
                    HpCard(
                      child: Column(
                        children: [
                          _kv('Reference', c.id, mono: true),
                          const Divider(height: HpSpace.x6),
                          _kv('District', c.districtName),
                          const Divider(height: HpSpace.x6),
                          _kv('Issued', DateFormat('d MMM yyyy · HH:mm').format(c.issuedAt)),
                          const Divider(height: HpSpace.x6),
                          _kv('Fine', slsh(c.amount), mono: true),
                        ],
                      ),
                    ),
                    if (c.status == CitationStatus.appealReview) ...[
                      const SizedBox(height: HpSpace.x4),
                      HpCard(
                        borderColor: HpColors.purple.withValues(alpha: 0.35),
                        child: Row(children: [
                          const Icon(Icons.gavel_outlined, color: HpColors.purple300, size: 20),
                          const SizedBox(width: HpSpace.x3),
                          Expanded(child: Text('Your video appeal is under review. We\'ll notify you of the decision.', style: HpType.body(size: 13.5))),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
              if (c.status == CitationStatus.outstanding)
                Container(
                  padding: const EdgeInsets.all(HpSpace.x5),
                  decoration: const BoxDecoration(color: HpColors.surface, border: Border(top: BorderSide(color: HpColors.border))),
                  child: Row(
                    children: [
                      HpButton(label: 'Challenge', variant: HpButtonVariant.ghost, size: HpButtonSize.lg, icon: Icons.videocam_outlined, onPressed: _appeal),
                      const SizedBox(width: HpSpace.x3),
                      Expanded(child: HpButton(label: 'Pay now', size: HpButtonSize.lg, expand: true, icon: Icons.account_balance_wallet_outlined, onPressed: _pay)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v, {bool mono = false}) => Row(
        children: [
          Text(k, style: HpType.body(size: 13.5, color: HpColors.textMuted)),
          const Spacer(),
          Text(v, style: mono ? HpType.mono(size: 14) : HpType.body(size: 14, weight: FontWeight.w600, color: HpColors.text)),
        ],
      );
}
