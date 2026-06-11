import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

/// Video-appeal review queue. Staff watch a driver's recorded challenge and
/// uphold (citation stands) or dismiss (citation cancelled).
class AppealsReviewPage extends StatelessWidget {
  const AppealsReviewPage({
    super.key,
    required this.appeals,
    required this.adminName,
    required this.onDecide,
  });

  final List<Appeal> appeals;
  final String adminName;

  /// Persist an appeal decision (uphold = citation stands; dismiss = cancelled).
  final Future<void> Function(Appeal appeal, AppealStatus status) onDecide;

  @override
  Widget build(BuildContext context) {
    final review = appeals.where((a) => a.status == AppealStatus.review).toList();
    final decided = appeals.where((a) => a.status != AppealStatus.review).toList();

    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        Row(children: [
          Text('Appeals queue', style: HpType.heading(size: 18)),
          const SizedBox(width: HpSpace.x3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3, vertical: 3),
            decoration: BoxDecoration(color: HpColors.purpleTint, borderRadius: BorderRadius.circular(HpRadius.pill)),
            child: Text('${review.length}', style: HpType.mono(size: 13, weight: FontWeight.w700, color: HpColors.purple300)),
          ),
        ]),
        const SizedBox(height: HpSpace.x4),
        if (review.isEmpty)
          HpCard(
            padding: const EdgeInsets.symmetric(vertical: HpSpace.x12),
            child: Center(child: Text('No appeals awaiting review.', style: HpType.body(size: 14))),
          )
        else
          for (final a in review)
            Padding(
              padding: const EdgeInsets.only(bottom: HpSpace.x4),
              child: _AppealCard(
                appeal: a,
                onWatch: () => _watch(context, a),
                onUphold: () { a.status = AppealStatus.upheld; a.decidedBy = adminName; onDecide(a, AppealStatus.upheld); },
                onDismiss: () { a.status = AppealStatus.dismissed; a.decidedBy = adminName; onDecide(a, AppealStatus.dismissed); },
              ),
            ),
        if (decided.isNotEmpty) ...[
          const SizedBox(height: HpSpace.x6),
          Text('Decided', style: HpType.heading(size: 18)),
          const SizedBox(height: HpSpace.x4),
          HpCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < decided.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${decided[i].plate} · ${decided[i].violation}',
                                style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600)),
                            Text(decided[i].id, style: HpType.mono(size: 12, color: HpColors.textMuted)),
                          ],
                        ),
                      ),
                      HpBadge(label: decided[i].status.label, color: decided[i].status.color, tint: decided[i].status.tint, glyph: decided[i].status.glyph),
                    ]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _watch(BuildContext context, Appeal a) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: HpColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
        child: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(HpRadius.xl)),
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: Container(
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.play_circle_outline, size: 56, color: Colors.white70),
                        Positioned(bottom: 12, child: Text('${a.appellantName} · ${a.videoLabel}', style: HpType.mono(size: 13, color: Colors.white70))),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(HpSpace.x5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('"${a.reason}"', style: HpType.body(size: 14, color: HpColors.text)),
                    const SizedBox(height: HpSpace.x4),
                    HpButton(label: 'Close', variant: HpButtonVariant.secondary, expand: true, onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppealCard extends StatelessWidget {
  const _AppealCard({
    required this.appeal,
    required this.onWatch,
    required this.onUphold,
    required this.onDismiss,
  });

  final Appeal appeal;
  final VoidCallback onWatch;
  final VoidCallback onUphold;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onWatch,
            child: Container(
              width: 150, height: 96,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(HpRadius.md)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.play_circle_outline, size: 32, color: Colors.white70),
                  Positioned(bottom: 6, right: 8, child: Text(appeal.videoLabel, style: HpType.mono(size: 11, color: Colors.white))),
                ],
              ),
            ),
          ),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Text(appeal.plate, style: HpType.mono(size: 14, weight: FontWeight.w700)),
                  const SizedBox(width: HpSpace.x3),
                  Text(appeal.id, style: HpType.mono(size: 12, color: HpColors.textMuted)),
                  const Spacer(),
                  Text(DateFormat('d MMM, HH:mm').format(appeal.submittedAt), style: HpType.body(size: 12, color: HpColors.textMuted)),
                ]),
                const SizedBox(height: 4),
                Text(appeal.violation, style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text('"${appeal.reason}"', style: HpType.body(size: 13)),
                const SizedBox(height: HpSpace.x4),
                Row(children: [
                  HpButton(label: 'Dismiss citation', variant: HpButtonVariant.ghost, icon: Icons.check_rounded, onPressed: onDismiss),
                  const SizedBox(width: HpSpace.x3),
                  HpButton(label: 'Uphold', variant: HpButtonVariant.danger, icon: Icons.gavel_rounded, onPressed: onUphold),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
