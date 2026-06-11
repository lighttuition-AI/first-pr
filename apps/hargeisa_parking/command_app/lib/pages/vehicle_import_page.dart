import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

/// Bulk vehicle-data import (Excel / CSV / Google Sheets) with a dedupe preview:
/// incoming rows are checked against the database and split into new / updated /
/// unchanged / conflicts before the admin commits the import.
class VehicleImportPage extends StatefulWidget {
  const VehicleImportPage({super.key});

  @override
  State<VehicleImportPage> createState() => _VehicleImportPageState();
}

class _VehicleImportPageState extends State<VehicleImportPage> {
  bool _uploaded = false;

  static final _preview = <(String, String, Color, Color)>[
    ('HG-9001', 'New', HpColors.success, HpColors.successTint),
    ('HG-4821', 'Updated · owner changed', HpColors.warning, HpColors.warningTint),
    ('HG-1190', 'Unchanged', HpColors.textMuted, HpColors.overlay),
    ('HG-7732', 'Conflict · two owners', HpColors.danger, HpColors.dangerTint),
    ('HG-5540', 'New', HpColors.success, HpColors.successTint),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        Text('Vehicle data', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x2),
        Text('Upload the licence-plate database from Excel, CSV or Google Sheets. '
            'New records are added; changes update existing ones; conflicts are flagged for review.',
            style: HpType.body(size: 13.5)),
        const SizedBox(height: HpSpace.x6),
        if (!_uploaded) _uploadCard() else _previewSection(),
      ],
    );
  }

  Widget _uploadCard() {
    return HpCard(
      padding: const EdgeInsets.all(HpSpace.x10),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: HpColors.purpleTint, borderRadius: BorderRadius.circular(HpRadius.lg)),
            child: const Icon(Icons.upload_file_outlined, color: HpColors.purple300, size: 30),
          ),
          const SizedBox(height: HpSpace.x4),
          Text('Upload vehicle data', style: HpType.heading(size: 18)),
          const SizedBox(height: HpSpace.x2),
          Text('.xlsx · .csv · Google Sheets link', style: HpType.body(size: 13)),
          const SizedBox(height: HpSpace.x5),
          HpButton(
            label: 'Choose file',
            icon: Icons.folder_open_outlined,
            onPressed: () => setState(() => _uploaded = true),
          ),
        ],
      ),
    );
  }

  Widget _previewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HpCard(
          padding: const EdgeInsets.all(HpSpace.x4),
          child: Row(children: [
            const Icon(Icons.description_outlined, color: HpColors.teal),
            const SizedBox(width: HpSpace.x3),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('hargeisa-vehicles.xlsx', style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600)),
                  Text('1,248 rows parsed', style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                ],
              ),
            ),
            HpButton(label: 'Replace', variant: HpButtonVariant.ghost, size: HpButtonSize.sm, onPressed: () => setState(() => _uploaded = false)),
          ]),
        ),
        const SizedBox(height: HpSpace.x5),
        Text('Dedupe preview', style: HpType.heading(size: 16)),
        const SizedBox(height: HpSpace.x3),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 720 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: HpSpace.x4,
            mainAxisSpacing: HpSpace.x4,
            childAspectRatio: 2.0,
            children: const [
              HpKpiCard(label: 'New', value: '312', icon: Icons.add_circle_outline, accent: HpColors.success),
              HpKpiCard(label: 'Updated', value: '86', icon: Icons.sync, accent: HpColors.warning),
              HpKpiCard(label: 'Unchanged', value: '842', icon: Icons.remove_circle_outline),
              HpKpiCard(label: 'Conflicts', value: '8', icon: Icons.error_outline, accent: HpColors.danger),
            ],
          );
        }),
        const SizedBox(height: HpSpace.x5),
        HpCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < _preview.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
                  child: Row(children: [
                    Text(_preview[i].$1, style: HpType.mono(size: 14, weight: FontWeight.w700)),
                    const Spacer(),
                    HpBadge(label: _preview[i].$2, color: _preview[i].$3, tint: _preview[i].$4),
                  ]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x5),
        Row(children: [
          HpButton(
            label: 'Import 398 records',
            icon: Icons.check_rounded,
            size: HpButtonSize.lg,
            onPressed: () {
              setState(() => _uploaded = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: HpColors.elevated,
                  content: Row(children: [
                    Icon(Icons.check_circle, color: HpColors.success, size: 18),
                    SizedBox(width: HpSpace.x3),
                    Text('Imported 398 records · 8 conflicts skipped', style: TextStyle(color: HpColors.text)),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(width: HpSpace.x3),
          Text('8 conflicts need manual review', style: HpType.body(size: 13, color: HpColors.danger)),
        ]),
      ],
    );
  }
}
