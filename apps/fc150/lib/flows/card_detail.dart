import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/fc_card.dart';
import '../widgets/primitives.dart';
import '../widgets/sheet.dart';

/// Card detail sheet. The Mid-season card offers a "Half-season upgrade" reveal
/// that counts the rating up (+6), grows the bars, and bursts confetti.
Future<void> showCardDetail(BuildContext context, CareerCard card) {
  return showFcSheet(context, builder: (_) => _CardDetail(card: card));
}

class _CardDetail extends StatefulWidget {
  final CareerCard card;
  const _CardDetail({required this.card});
  @override
  State<_CardDetail> createState() => _CardDetailState();
}

class _CardDetailState extends State<_CardDetail> {
  bool _upgraded = false;
  final _confetti = ConfettiController(duration: const Duration(milliseconds: 2200));

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _reveal() {
    setState(() => _upgraded = true);
    _confetti.play();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    final me = Seed.me;
    final isMid = c.label == 'Mid-season';
    final base = c.stats.minus(const Stats(pac: 6, sho: 5, pas: 4, dri: 5, def: 2, phy: 3));
    final shown = _upgraded ? c.stats : (isMid ? base : c.stats);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            FCCard(
              variant: c.variant,
              tier: c.tier,
              rating: c.rating,
              name: me.name,
              pos: me.pos,
              psn: me.psn,
              stats: c.stats,
              flagBands: Seed.flagOf('NL'),
              width: 228,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Pill(c.comp, tone: PillTone.purple),
                Pill(c.season),
                Pill(c.record, tone: PillTone.teal),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionTitle('Attributes'),
                Text('Created ${c.date}', style: FCType.mono(size: 11, color: FC.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            StatBars(stats: {
              'pac': shown.pac, 'sho': shown.sho, 'pas': shown.pas,
              'dri': shown.dri, 'def': shown.def, 'phy': shown.phy,
            }, animate: true),
            if (isMid) ...[
              const SizedBox(height: 16),
              Surface(
                borderColor: const Color(0x4D00C853),
                child: Row(
                  children: [
                    const Icon(LucideIcons.trendingUp, size: 20, color: FC.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Half-season upgrade ready', style: FCType.body(size: 13, weight: FontWeight.w600)),
                          Row(
                            children: [
                              Text('OVR ', style: FCType.body(size: 11.5, color: FC.text2)),
                              if (_upgraded)
                                CountUp(from: c.rating - 6, to: c.rating, style: FCType.mono(size: 11.5, weight: FontWeight.w700, color: FC.success))
                              else
                                Text('${c.rating - 6}', style: FCType.body(size: 11.5, color: FC.text2)),
                              if (_upgraded) Text('  → +6', style: FCType.body(size: 11.5, weight: FontWeight.w600, color: FC.success)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!_upgraded) GButton('Reveal', size: 'sm', variant: GBtn.teal, onTap: _reveal),
                  ],
                ),
              ),
            ],
          ],
        ),
        Positioned(top: 40, child: FCConfetti(_confetti)),
      ],
    );
  }
}
