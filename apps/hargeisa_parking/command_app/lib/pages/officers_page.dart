import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

class OfficersPage extends StatelessWidget {
  const OfficersPage({super.key, required this.repo});

  final OfficerRepository repo;

  Future<void> _confirmDelete(BuildContext context, Officer officer) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HpColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
        title: Text('Delete officer?', style: HpType.heading(size: 18)),
        content: Text(
          '${officer.fullName} (${officer.badgeNumber}) will be removed from the '
          'system and can no longer sign in to HPark Enforce. This cannot be undone.',
          style: HpType.body(size: 14),
        ),
        actions: [
          HpButton(label: 'Cancel', variant: HpButtonVariant.ghost, onPressed: () => Navigator.pop(ctx, false)),
          HpButton(label: 'Delete', variant: HpButtonVariant.danger, onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await repo.delete(officer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: HpColors.elevated,
            content: Text('Removed ${officer.fullName}', style: TextStyle(color: HpColors.text)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: HpColors.elevated,
            content: Text('Could not delete: $e', style: const TextStyle(color: HpColors.danger)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final officers = repo.officers;
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        Text('${officers.length} officers', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x2),
        Text('Everyone who has registered for HPark Enforce, with their current access state. '
            'Delete an account to remove a rogue officer from the system.',
            style: HpType.body(size: 13.5)),
        const SizedBox(height: HpSpace.x5),
        if (officers.isEmpty)
          HpCard(
            padding: const EdgeInsets.symmetric(vertical: HpSpace.x10),
            child: Center(child: Text('No officers registered yet.', style: HpType.body(size: 14))),
          )
        else
          HpCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < officers.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _Row(officer: officers[i], onDelete: () => _confirmDelete(context, officers[i])),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.officer, required this.onDelete});
  final Officer officer;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final district = districtById(officer.assignedDistrictId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
      child: Row(
        children: [
          HpAvatar(
            initials: officer.initials,
            size: 40,
            statusColor: officer.canUseOfficerApp ? HpColors.success : null,
          ),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(officer.fullName,
                    style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600)),
                Text(officer.badgeNumber, style: HpType.mono(size: 12.5, color: HpColors.textMuted)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              district?.name ?? '—',
              style: HpType.body(size: 13.5, color: HpColors.text2),
            ),
          ),
          HpBadge.status(officer.status),
          const SizedBox(width: HpSpace.x3),
          IconButton(
            tooltip: 'Delete officer',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: HpColors.textMuted),
            hoverColor: HpColors.dangerTint,
          ),
        ],
      ),
    );
  }
}
