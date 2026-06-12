import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';
import 'package:intl/intl.dart';

/// Live activity / audit feed — who changed or added what in the dashboard.
class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key, required this.repo});

  final AuditRepository repo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(HpSpace.x8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity log', style: HpType.heading(size: 18)),
          const SizedBox(height: HpSpace.x2),
          Text('Every change made in the dashboard, with who made it and when.',
              style: HpType.body(size: 13.5)),
          const SizedBox(height: HpSpace.x5),
          Expanded(
            child: StreamBuilder<List<AuditEntry>>(
              stream: repo.watchRecent(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: HpColors.purple));
                }
                final entries = snap.data ?? const [];
                if (entries.isEmpty) {
                  return HpCard(
                    padding: const EdgeInsets.symmetric(vertical: HpSpace.x12),
                    child: Center(child: Text('No activity recorded yet.', style: HpType.body(size: 14))),
                  );
                }
                return HpCard(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _Row(entry: entries[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry});
  final AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context, entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HpAvatar(initials: _initials(entry.by), size: 34),
            const SizedBox(width: HpSpace.x4),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(text: entry.by, style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                    TextSpan(text: '  ${entry.action}', style: HpType.body(size: 14, color: HpColors.text2)),
                    if (entry.target.isNotEmpty)
                      TextSpan(text: '  ${entry.target}', style: HpType.mono(size: 13, weight: FontWeight.w700, color: HpColors.purple300)),
                  ])),
                  if (entry.details.isNotEmpty)
                    Text(entry.details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: HpSpace.x3),
            Text(DateFormat('d MMM · HH:mm').format(entry.at),
                style: HpType.body(size: 12, color: HpColors.textMuted)),
            const SizedBox(width: HpSpace.x2),
            Icon(Icons.chevron_right_rounded, size: 18, color: HpColors.textMuted),
          ],
        ),
      ),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'[\s@.]+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

/// Full detail of one logged change: the action, the affected record (and its
/// owner / national ID / make / colour for a vehicle), who did it, and when.
void _showDetail(BuildContext context, AuditEntry entry) {
  // Details are stored as "Label: value · Label: value"; split for display.
  final parts = entry.details.isEmpty
      ? <String>[]
      : entry.details.split(' · ').where((p) => p.trim().isNotEmpty).toList();

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: HpColors.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
      title: Row(
        children: [
          Expanded(child: Text(entry.action, style: HpType.heading(size: 18))),
          if (entry.target.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3, vertical: 4),
              decoration: BoxDecoration(color: HpColors.purpleTint, borderRadius: BorderRadius.circular(HpRadius.pill)),
              child: Text(entry.target, style: HpType.mono(size: 13, weight: FontWeight.w700, color: HpColors.purple300)),
            ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in parts) _DetailLine(part: p),
            if (parts.isNotEmpty) const SizedBox(height: HpSpace.x4),
            const Divider(height: 1),
            const SizedBox(height: HpSpace.x4),
            _kv('By', entry.by),
            const SizedBox(height: HpSpace.x2),
            _kv('When', DateFormat('d MMM yyyy · HH:mm').format(entry.at)),
          ],
        ),
      ),
      actions: [
        HpButton(label: 'Close', variant: HpButtonVariant.secondary, onPressed: () => Navigator.pop(ctx)),
      ],
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.part});
  final String part;

  @override
  Widget build(BuildContext context) {
    final i = part.indexOf(': ');
    if (i <= 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: HpSpace.x2),
        child: Text(part, style: HpType.body(size: 13.5, color: HpColors.text)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: HpSpace.x2),
      child: _kv(part.substring(0, i), part.substring(i + 2)),
    );
  }
}

Widget _kv(String label, String value) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: HpType.eyebrow)),
        Expanded(child: Text(value.isEmpty ? '—' : value, style: HpType.body(size: 13.5, color: HpColors.text))),
      ],
    );
