import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:intl/intl.dart';

/// Officer approvals — the gate that keeps unauthorized people from operating as
/// officers. Officers self-register in HPark Enforce and land here as *pending*;
/// an admin reviews their identity and approves (assigning a district) or rejects.
/// Only approved officers can sign in to the officer app.
class ApprovalsPage extends StatelessWidget {
  const ApprovalsPage({super.key, required this.repo, required this.adminName});

  final OfficerRepository repo;
  final String adminName;

  @override
  Widget build(BuildContext context) {
    final pending = repo.pending;
    final reviewed = repo.officers
        .where((o) => o.status != ApprovalStatus.pending)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        _IntroCard(pendingCount: pending.length),
        const SizedBox(height: HpSpace.x6),
        Row(
          children: [
            Text('Pending review', style: HpType.heading(size: 18)),
            const SizedBox(width: HpSpace.x3),
            _CountChip(count: pending.length, color: HpColors.warning),
          ],
        ),
        const SizedBox(height: HpSpace.x4),
        if (pending.isEmpty)
          const _EmptyState()
        else
          for (final officer in pending)
            Padding(
              padding: const EdgeInsets.only(bottom: HpSpace.x4),
              child: _PendingOfficerCard(
                officer: officer,
                onApprove: () => _approve(context, officer),
                onReject: () => _reject(context, officer),
              ),
            ),
        const SizedBox(height: HpSpace.x8),
        Text('Reviewed', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x4),
        if (reviewed.isEmpty)
          Text('No decisions yet.', style: HpType.body(size: 14))
        else
          HpCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < reviewed.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _ReviewedRow(officer: reviewed[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _approve(BuildContext context, Officer officer) async {
    final districtId = await showDialog<String>(
      context: context,
      builder: (_) => _ApproveDialog(officer: officer),
    );
    if (districtId == null) return;
    await repo.approve(officer.id, by: adminName, districtId: districtId);
    if (context.mounted) {
      _toast(context, '${officer.fullName} approved — they can now sign in to HPark Enforce.',
          HpColors.success);
    }
  }

  Future<void> _reject(BuildContext context, Officer officer) async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _RejectDialog(officer: officer),
    );
    if (note == null) return;
    await repo.reject(officer.id, by: adminName, note: note);
    if (context.mounted) {
      _toast(context, '${officer.fullName}\'s application was rejected.', HpColors.danger);
    }
  }

  void _toast(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: HpColors.elevated,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: HpSpace.x3),
            Expanded(child: Text(msg, style: const TextStyle(color: HpColors.text))),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.pendingCount});
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      color: HpColors.surface,
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: HpColors.purpleTint,
              borderRadius: BorderRadius.circular(HpRadius.md),
            ),
            child: const Icon(Icons.verified_user_outlined, color: HpColors.purple300),
          ),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Officer access control', style: HpType.heading(size: 16)),
                const SizedBox(height: 4),
                Text(
                  'Officers who register in HPark Enforce stay locked out until you approve '
                  'them here. Verify the national ID and badge, then approve and assign a district.',
                  style: HpType.body(size: 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingOfficerCard extends StatelessWidget {
  const _PendingOfficerCard({
    required this.officer,
    required this.onApprove,
    required this.onReject,
  });

  final Officer officer;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HpAvatar(initials: officer.initials, size: 48),
              const SizedBox(width: HpSpace.x4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(officer.fullName, style: HpType.heading(size: 17)),
                        const SizedBox(width: HpSpace.x3),
                        HpBadge.status(officer.status),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('Applied ${_applied(officer.appliedAt)}',
                        style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                  ],
                ),
              ),
              Text(officer.badgeNumber,
                  style: HpType.mono(size: 13, color: HpColors.text2)),
            ],
          ),
          const SizedBox(height: HpSpace.x5),
          Wrap(
            spacing: HpSpace.x8,
            runSpacing: HpSpace.x4,
            children: [
              _Field(label: 'National ID', value: officer.nationalId, mono: true),
              _Field(label: 'Phone', value: officer.phone, mono: true),
              _Field(
                label: 'Date of birth',
                value: DateFormat('d MMM yyyy').format(officer.dateOfBirth),
              ),
            ],
          ),
          const SizedBox(height: HpSpace.x5),
          Row(
            children: [
              HpButton(
                label: 'Approve',
                icon: Icons.check_rounded,
                onPressed: onApprove,
              ),
              const SizedBox(width: HpSpace.x3),
              HpButton(
                label: 'Reject',
                variant: HpButtonVariant.ghost,
                icon: Icons.close_rounded,
                onPressed: onReject,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _applied(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return DateFormat('d MMM, HH:mm').format(t);
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: HpType.eyebrow),
        const SizedBox(height: 4),
        Text(
          value,
          style: mono
              ? HpType.mono(size: 14, color: HpColors.text)
              : HpType.body(size: 14, color: HpColors.text, weight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _ReviewedRow extends StatelessWidget {
  const _ReviewedRow({required this.officer});
  final Officer officer;

  @override
  Widget build(BuildContext context) {
    final district = districtById(officer.assignedDistrictId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
      child: Row(
        children: [
          HpAvatar(initials: officer.initials, size: 36),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(officer.fullName,
                    style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600)),
                Text(
                  district != null ? 'Assigned · ${district.name}' : officer.badgeNumber,
                  style: HpType.body(size: 12.5, color: HpColors.textMuted),
                ),
              ],
            ),
          ),
          HpBadge.status(officer.status),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(HpRadius.pill),
      ),
      child: Text('$count',
          style: HpType.mono(size: 13, weight: FontWeight.w700, color: color)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return HpCard(
      padding: const EdgeInsets.symmetric(vertical: HpSpace.x12),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.task_alt_rounded, size: 36, color: HpColors.success),
            const SizedBox(height: HpSpace.x3),
            Text('All caught up', style: HpType.heading(size: 16)),
            const SizedBox(height: 4),
            Text('No officers are waiting for review.', style: HpType.body(size: 13)),
          ],
        ),
      ),
    );
  }
}

class _ApproveDialog extends StatefulWidget {
  const _ApproveDialog({required this.officer});
  final Officer officer;

  @override
  State<_ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<_ApproveDialog> {
  String? _districtId = kHargeisaDistricts.first.id;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HpColors.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(HpSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Approve ${widget.officer.fullName}', style: HpType.heading(size: 18)),
            const SizedBox(height: HpSpace.x2),
            Text(
              'They will be able to sign in to HPark Enforce and patrol the district you assign.',
              style: HpType.body(size: 13.5),
            ),
            const SizedBox(height: HpSpace.x5),
            Text('Assign district', style: HpType.eyebrow),
            const SizedBox(height: HpSpace.x2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: HpSpace.x4),
              decoration: BoxDecoration(
                color: HpColors.overlay,
                borderRadius: BorderRadius.circular(HpRadius.sm),
                border: Border.all(color: HpColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _districtId,
                  isExpanded: true,
                  dropdownColor: HpColors.elevated,
                  icon: const Icon(Icons.expand_more, color: HpColors.textMuted),
                  style: const TextStyle(color: HpColors.text, fontSize: 15),
                  items: [
                    for (final d in kHargeisaDistricts)
                      DropdownMenuItem(value: d.id, child: Text(d.name)),
                  ],
                  onChanged: (v) => setState(() => _districtId = v),
                ),
              ),
            ),
            const SizedBox(height: HpSpace.x6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                HpButton(
                  label: 'Cancel',
                  variant: HpButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: HpSpace.x3),
                HpButton(
                  label: 'Approve officer',
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.pop(context, _districtId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog({required this.officer});
  final Officer officer;

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HpColors.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(HpSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject ${widget.officer.fullName}', style: HpType.heading(size: 18)),
            const SizedBox(height: HpSpace.x2),
            Text('They will not be able to sign in. You can add a reason for the record.',
                style: HpType.body(size: 13.5)),
            const SizedBox(height: HpSpace.x5),
            HpInput(
              controller: _controller,
              label: 'Reason (optional)',
              hint: 'e.g. National ID could not be verified',
            ),
            const SizedBox(height: HpSpace.x6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                HpButton(
                  label: 'Cancel',
                  variant: HpButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: HpSpace.x3),
                HpButton(
                  label: 'Reject',
                  variant: HpButtonVariant.danger,
                  onPressed: () => Navigator.pop(context, _controller.text.trim()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
