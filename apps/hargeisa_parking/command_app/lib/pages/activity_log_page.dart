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
    return Padding(
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
                  Text(entry.details, style: HpType.body(size: 12.5, color: HpColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: HpSpace.x3),
          Text(DateFormat('d MMM · HH:mm').format(entry.at),
              style: HpType.body(size: 12, color: HpColors.textMuted)),
        ],
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
