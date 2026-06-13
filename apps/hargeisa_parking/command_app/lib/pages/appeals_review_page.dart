// Command runs only on Flutter web; a native <video> element is the most
// reliable player there (Flutter's video_player struggled with these clips).
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Video-appeal review queue. Staff watch a driver's recorded challenge and
/// uphold (citation stands) or dismiss (citation cancelled).
class AppealsReviewPage extends StatelessWidget {
  const AppealsReviewPage({
    super.key,
    required this.appeals,
    required this.adminName,
    required this.onDecide,
    this.canDecide = true,
  });

  final List<Appeal> appeals;
  final String adminName;

  /// Admins decide appeals; normal users review (watch) read-only.
  final bool canDecide;

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
                canDecide: canDecide,
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
                                style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600)),
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
    showDialog<void>(context: context, builder: (_) => _AppealVideoDialog(appeal: a));
  }
}

/// Plays a submitted appeal video using a native browser <video> element (the
/// most reliable web player — native controls + fullscreen). "Open in new tab"
/// is a backup; a clear note shows when no video is attached.
class _AppealVideoDialog extends StatefulWidget {
  const _AppealVideoDialog({required this.appeal});
  final Appeal appeal;

  @override
  State<_AppealVideoDialog> createState() => _AppealVideoDialogState();
}

class _AppealVideoDialogState extends State<_AppealVideoDialog> {
  late final String _viewType;

  bool get _hasVideo => widget.appeal.videoUrl.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Unique per dialog so re-opening never double-registers the factory.
    _viewType = 'appeal-video-${DateTime.now().microsecondsSinceEpoch}';
    if (_hasVideo) {
      final url = widget.appeal.videoUrl;
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
        final v = html.VideoElement()
          ..src = url
          ..controls = true
          ..autoplay = true
          // Safari blocks autoplay of UN-muted video (Chrome is laxer) — start
          // muted so it always plays; the reviewer unmutes via the controls.
          ..muted = true
          ..defaultMuted = true
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..style.backgroundColor = '#000'
          ..style.objectFit = 'contain';
        v.setAttribute('muted', '');
        v.setAttribute('playsinline', 'true');
        v.setAttribute('preload', 'auto');
        return v;
      });
    }
  }

  Future<void> _openInTab() async {
    try {
      await launchUrl(Uri.parse(widget.appeal.videoUrl), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appeal;
    return Dialog(
      backgroundColor: HpColors.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
      child: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(HpRadius.xl)),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  color: Colors.black,
                  child: _hasVideo
                      ? HtmlElementView(viewType: _viewType)
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam_off_outlined, size: 44, color: Colors.white38),
                              const SizedBox(height: HpSpace.x3),
                              Text('No video attached to this appeal.', style: HpType.body(size: 13, color: Colors.white60)),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(HpSpace.x5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${a.appellantName} · ${a.videoLabel}', style: HpType.mono(size: 12.5, color: HpColors.textMuted)),
                  const SizedBox(height: HpSpace.x2),
                  Text('"${a.reason}"', style: HpType.body(size: 14, color: HpColors.text)),
                  const SizedBox(height: HpSpace.x4),
                  Row(
                    children: [
                      if (_hasVideo) ...[
                        Expanded(
                          child: HpButton(label: 'Open in new tab', icon: Icons.open_in_new_rounded, onPressed: _openInTab),
                        ),
                        const SizedBox(width: HpSpace.x3),
                      ],
                      Expanded(
                        child: HpButton(label: 'Close', variant: HpButtonVariant.secondary, onPressed: () => Navigator.pop(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppealCard extends StatelessWidget {
  const _AppealCard({
    required this.appeal,
    required this.canDecide,
    required this.onWatch,
    required this.onUphold,
    required this.onDismiss,
  });

  final Appeal appeal;
  final bool canDecide;
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
                Text(appeal.violation, style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text('"${appeal.reason}"', style: HpType.body(size: 13)),
                const SizedBox(height: HpSpace.x4),
                if (canDecide)
                  Row(children: [
                    HpButton(label: 'Dismiss citation', variant: HpButtonVariant.ghost, icon: Icons.check_rounded, onPressed: onDismiss),
                    const SizedBox(width: HpSpace.x3),
                    HpButton(label: 'Uphold', variant: HpButtonVariant.danger, icon: Icons.gavel_rounded, onPressed: onUphold),
                  ])
                else
                  HpButton(label: 'Watch appeal', variant: HpButtonVariant.secondary, icon: Icons.play_arrow_rounded, onPressed: onWatch),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
