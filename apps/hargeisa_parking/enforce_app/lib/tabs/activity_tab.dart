import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

import '../models/issued_citation.dart';
import '../state/shift_state.dart';

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key, required this.shift});

  final ShiftState shift;

  @override
  Widget build(BuildContext context) {
    final items = shift.issued;
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x5),
      children: [
        Text('Activity', style: HpType.heading(size: 22)),
        const SizedBox(height: HpSpace.x2),
        Text('Citations you\'ve issued this shift.', style: HpType.body(size: 14)),
        if (shift.queuedCount > 0) ...[
          const SizedBox(height: HpSpace.x4),
          HpCard(
            borderColor: HpColors.warning.withValues(alpha: 0.4),
            padding: const EdgeInsets.all(HpSpace.x4),
            child: Row(children: [
              const Icon(Icons.cloud_off_outlined, color: HpColors.warning, size: 20),
              const SizedBox(width: HpSpace.x3),
              Expanded(child: Text('${shift.queuedCount} citation${shift.queuedCount == 1 ? '' : 's'} queued offline — turn connectivity on in Profile to sync.', style: HpType.body(size: 13))),
            ]),
          ),
        ],
        const SizedBox(height: HpSpace.x5),
        if (items.isEmpty)
          HpCard(
            padding: const EdgeInsets.symmetric(vertical: HpSpace.x12),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_outlined, size: 36, color: HpColors.textMuted),
                  const SizedBox(height: HpSpace.x3),
                  Text('No citations yet', style: HpType.heading(size: 16)),
                  const SizedBox(height: 4),
                  Text('Issued citations appear here.', style: HpType.body(size: 13)),
                ],
              ),
            ),
          )
        else
          for (final c in items)
            Padding(padding: const EdgeInsets.only(bottom: HpSpace.x3), child: _CitationRow(citation: c)),
      ],
    );
  }
}

class _CitationRow extends StatelessWidget {
  const _CitationRow({required this.citation});
  final IssuedCitation citation;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.decimalPattern('en');
    return HpCard(
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
              HpBadge(
                label: citation.synced ? 'Synced' : 'Queued',
                color: citation.synced ? HpColors.success : HpColors.warning,
                tint: citation.synced ? HpColors.successTint : HpColors.warningTint,
                glyph: citation.synced ? '✓' : '◷',
              ),
            ],
          ),
          const SizedBox(height: HpSpace.x3),
          Text(citation.violation, style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('${citation.id} · ${DateFormat('HH:mm').format(citation.issuedAt)} · ${citation.photoCount} photo${citation.photoCount == 1 ? '' : 's'}${citation.hasVideo ? ' · video' : ''}',
              style: HpType.body(size: 12.5, color: HpColors.textMuted)),
          const SizedBox(height: HpSpace.x3),
          Text('SLSH ${money.format(citation.fine)}', style: HpType.mono(size: 17, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
