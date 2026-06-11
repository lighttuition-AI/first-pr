import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';
import 'package:intl/intl.dart';

import '../util/format.dart';

/// "Track your video appeals" — live list of the citizen's appeals (by plate),
/// with their current decision status from HPark Command.
class AppealsScreen extends StatelessWidget {
  const AppealsScreen({super.key, required this.repo, required this.plate});

  final FirebaseAppealRepository repo;
  final String plate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your appeals', style: HpType.heading(size: 18))),
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: SafeArea(
          top: false,
          child: plate.isEmpty
              ? _empty('Add your vehicle plate in Profile to track appeals.')
              : StreamBuilder<List<Appeal>>(
                  stream: repo.watchByPlate(plate),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: HpColors.purple));
                    }
                    final appeals = snap.data ?? const [];
                    if (appeals.isEmpty) {
                      return _empty('You haven\'t submitted any appeals.\n'
                          'Open a citation and tap "Challenge" to appeal.');
                    }
                    return ListView(
                      padding: const EdgeInsets.all(HpSpace.x5),
                      children: [
                        for (final a in appeals)
                          Padding(
                            padding: const EdgeInsets.only(bottom: HpSpace.x3),
                            child: _AppealCard(appeal: a),
                          ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _empty(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(HpSpace.x8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gavel_outlined, size: 40, color: HpColors.textMuted),
              const SizedBox(height: HpSpace.x4),
              Text(message, textAlign: TextAlign.center, style: HpType.body(size: 14)),
            ],
          ),
        ),
      );
}

class _AppealCard extends StatelessWidget {
  const _AppealCard({required this.appeal});
  final Appeal appeal;

  @override
  Widget build(BuildContext context) {
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
                    border: Border.all(color: HpColors.borderStrong)),
                child: Text(appeal.plate, style: HpType.mono(size: 13, weight: FontWeight.w700)),
              ),
              const Spacer(),
              HpBadge(
                  label: appeal.status.label,
                  color: appeal.status.color,
                  tint: appeal.status.tint,
                  glyph: appeal.status.glyph),
            ],
          ),
          const SizedBox(height: HpSpace.x3),
          Text(appeal.violation,
              style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('${appeal.citationId} · ${DateFormat('d MMM yyyy').format(appeal.submittedAt)}',
              style: HpType.body(size: 12.5, color: HpColors.textMuted)),
          if (appeal.reason.isNotEmpty) ...[
            const SizedBox(height: HpSpace.x3),
            Text('"${appeal.reason}"', style: HpType.body(size: 13)),
          ],
          const SizedBox(height: HpSpace.x3),
          Row(
            children: [
              Text(slsh(appeal.fine), style: HpType.mono(size: 15, weight: FontWeight.w700, color: HpColors.text)),
              const Spacer(),
              if (appeal.status == AppealStatus.dismissed)
                Text('Citation cancelled', style: HpType.body(size: 12.5, color: HpColors.success))
              else if (appeal.status == AppealStatus.upheld)
                Text('Citation stands', style: HpType.body(size: 12.5, color: HpColors.warning))
              else
                Text('Awaiting decision', style: HpType.body(size: 12.5, color: HpColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
