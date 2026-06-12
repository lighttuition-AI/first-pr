import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';
import 'package:intl/intl.dart';

import '../l10n/strings.dart';
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

  /// Null for a read-only view (e.g. opened from Payment history) — the Pay /
  /// Challenge actions only appear for an outstanding citation with a repo.
  final FirebaseCitationRepository? repo;
  final FirebaseAppealRepository? appeals;

  @override
  State<CitationDetailScreen> createState() => _CitationDetailScreenState();
}

class _CitationDetailScreenState extends State<CitationDetailScreen> {
  Citation get c => widget.citation;

  void _pay() {
    showPaySheet(context, amount: c.amount, onPaid: (method) {
      setState(() => c.status = CitationStatus.paid);
      widget.repo?.setStatus(c.id, CitationStatus.paid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: HpColors.elevated,
          content: Row(children: [
            const Icon(Icons.check_circle, color: HpColors.success, size: 18),
            const SizedBox(width: HpSpace.x3),
            Text(trf('Paid {amount} via {method}', {'amount': slsh(c.amount), 'method': method}), style: TextStyle(color: HpColors.text)),
          ]),
        ),
      );
    });
  }

  Future<void> _appeal() async {
    final repo = widget.repo, appeals = widget.appeals;
    if (repo == null || appeals == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppealFlow(
          citation: c,
          appellantName: widget.citizen.fullName,
          repo: repo,
          appeals: appeals,
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
      appBar: AppBar(title: Text(tr('Citation'), style: HpType.heading(size: 18))),
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
                        HpBadge(label: tr(label), color: color, tint: tint, glyph: glyph),
                      ],
                    ),
                    const SizedBox(height: HpSpace.x5),
                    Text(c.violation, style: HpType.heading(size: 20)),
                    const SizedBox(height: HpSpace.x5),
                    HpCard(
                      child: Column(
                        children: [
                          _kv(tr('Reference'), c.id, mono: true),
                          const Divider(height: HpSpace.x6),
                          _kv(tr('District'), c.districtName),
                          const Divider(height: HpSpace.x6),
                          _kv(tr('Issued'), DateFormat('d MMM yyyy · HH:mm').format(c.issuedAt)),
                          const Divider(height: HpSpace.x6),
                          _kv(tr('Fine'), slsh(c.amount), mono: true),
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
                          Expanded(child: Text(tr("Your video appeal is under review. We'll notify you of the decision."), style: HpType.body(size: 13.5))),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
              if (c.status == CitationStatus.outstanding && widget.repo != null)
                Container(
                  padding: const EdgeInsets.all(HpSpace.x5),
                  decoration: BoxDecoration(color: HpColors.surface, border: Border(top: BorderSide(color: HpColors.border))),
                  child: Row(
                    children: [
                      HpButton(label: tr('Challenge'), variant: HpButtonVariant.ghost, size: HpButtonSize.lg, icon: Icons.videocam_outlined, onPressed: _appeal),
                      const SizedBox(width: HpSpace.x3),
                      Expanded(child: HpButton(label: tr('Pay now'), size: HpButtonSize.lg, expand: true, icon: Icons.account_balance_wallet_outlined, onPressed: _pay)),
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
