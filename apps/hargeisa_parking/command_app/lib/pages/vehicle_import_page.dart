import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import 'vehicle_grid.dart';

/// Real bulk vehicle-data import. Pick a CSV, it's parsed and deduped against
/// the live Firestore registry, and committed to `vehicles/{plate}` — the same
/// records an officer's plate lookup in HPark Enforce reads.
///
/// CSV columns (a header row is detected + skipped):
///   plate, ownerName, ownerNationalId, make, color, permitStatus,
///   outstandingCount, outstandingTotal
/// permitStatus = valid | expired | none.
class VehicleImportPage extends StatefulWidget {
  const VehicleImportPage({super.key, required this.vehicles});

  final FirebaseVehicleRepository vehicles;

  @override
  State<VehicleImportPage> createState() => _VehicleImportPageState();
}

class _VehicleImportPageState extends State<VehicleImportPage> {
  String? _fileName;
  List<Vehicle> _parsed = [];
  Set<String> _existingPlates = {};
  bool _busy = false;
  String? _error;

  int get _newCount => _parsed.where((v) => !_existingPlates.contains(v.plate)).length;
  int get _updateCount => _parsed.where((v) => _existingPlates.contains(v.plate)).length;

  Future<void> _pickFile() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (result == null) {
        setState(() => _busy = false);
        return; // cancelled
      }
      final bytes = result.files.first.bytes;
      if (bytes == null) throw 'Could not read the file.';
      final parsed = _parseCsv(utf8.decode(bytes, allowMalformed: true));
      if (parsed.isEmpty) throw 'No vehicle rows found. Check the column order.';
      final existing = await widget.vehicles.all();
      if (!mounted) return;
      setState(() {
        _fileName = result.files.first.name;
        _parsed = parsed;
        _existingPlates = existing.map((v) => v.plate.toUpperCase()).toSet();
        _busy = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    var written = 0;
    for (final v in _parsed) {
      try {
        await widget.vehicles.upsert(v);
        written++;
      } catch (_) {/* skip a bad row, keep going */}
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _fileName = null;
      _parsed = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HpColors.elevated,
        content: Row(children: [
          const Icon(Icons.check_circle, color: HpColors.success, size: 18),
          const SizedBox(width: HpSpace.x3),
          Text('Imported $written vehicle${written == 1 ? '' : 's'} to the registry',
              style: TextStyle(color: HpColors.text)),
        ]),
      ),
    );
  }

  List<Vehicle> _parseCsv(String content) {
    final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return [];
    var start = 0;
    if (lines.first.toLowerCase().contains('plate')) start = 1; // skip header
    final out = <Vehicle>[];
    for (var i = start; i < lines.length; i++) {
      final cols = lines[i].split(',').map((s) => s.trim()).toList();
      if (cols.isEmpty || cols.first.isEmpty) continue;
      String at(int j) => j < cols.length ? cols[j] : '';
      final permit = at(5).toLowerCase();
      out.add(Vehicle(
        plate: at(0).toUpperCase(),
        ownerName: at(1),
        ownerNationalId: at(2),
        make: at(3),
        color: at(4),
        permitStatus: permit == 'valid'
            ? PermitStatus.valid
            : permit == 'expired'
                ? PermitStatus.expired
                : PermitStatus.none,
        outstandingCount: int.tryParse(at(6)) ?? 0,
        outstandingTotal: int.tryParse(at(7)) ?? 0,
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        Text('Vehicle data', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x2),
        Text('Upload the licence-plate registry as a CSV. New plates are added; '
            'existing plates are updated. Officers look these up in HPark Enforce.',
            style: HpType.body(size: 13.5)),
        const SizedBox(height: HpSpace.x6),
        if (_parsed.isEmpty) _uploadCard() else _previewSection(),
        const SizedBox(height: HpSpace.x8),
        const Divider(),
        const SizedBox(height: HpSpace.x6),
        VehicleGrid(vehicles: widget.vehicles),
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
          Text('CSV: plate, ownerName, ownerNationalId, make, color, permitStatus, outstandingCount, outstandingTotal',
              textAlign: TextAlign.center, style: HpType.body(size: 12.5, color: HpColors.textMuted)),
          const SizedBox(height: HpSpace.x5),
          HpButton(
            label: 'Choose CSV file',
            icon: Icons.folder_open_outlined,
            loading: _busy,
            onPressed: _busy ? null : _pickFile,
          ),
          if (_error != null) ...[
            const SizedBox(height: HpSpace.x4),
            Text(_error!, style: HpType.body(size: 13, color: HpColors.danger)),
          ],
        ],
      ),
    );
  }

  Widget _previewSection() {
    final preview = _parsed.take(8).toList();
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
                  Text(_fileName ?? 'data.csv', style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600)),
                  Text('${_parsed.length} rows parsed', style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                ],
              ),
            ),
            HpButton(label: 'Replace', variant: HpButtonVariant.ghost, size: HpButtonSize.sm, onPressed: () => setState(() => _parsed = [])),
          ]),
        ),
        const SizedBox(height: HpSpace.x5),
        Text('Preview', style: HpType.heading(size: 16)),
        const SizedBox(height: HpSpace.x3),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 720 ? 3 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: HpSpace.x4,
            mainAxisSpacing: HpSpace.x4,
            childAspectRatio: 2.4,
            children: [
              HpKpiCard(label: 'New', value: '$_newCount', icon: Icons.add_circle_outline, accent: HpColors.success),
              HpKpiCard(label: 'Updated', value: '$_updateCount', icon: Icons.sync, accent: HpColors.warning),
              HpKpiCard(label: 'Total rows', value: '${_parsed.length}', icon: Icons.directions_car_outlined),
            ],
          );
        }),
        const SizedBox(height: HpSpace.x5),
        HpCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < preview.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HpSpace.x5, vertical: HpSpace.x4),
                  child: Row(children: [
                    Text(preview[i].plate, style: HpType.mono(size: 14, weight: FontWeight.w700)),
                    const SizedBox(width: HpSpace.x4),
                    Expanded(child: Text('${preview[i].ownerName} · ${preview[i].make}', style: HpType.body(size: 13, color: HpColors.text2), overflow: TextOverflow.ellipsis)),
                    HpBadge(
                      label: _existingPlates.contains(preview[i].plate) ? 'Update' : 'New',
                      color: _existingPlates.contains(preview[i].plate) ? HpColors.warning : HpColors.success,
                      tint: _existingPlates.contains(preview[i].plate) ? HpColors.warningTint : HpColors.successTint,
                    ),
                  ]),
                ),
              ],
              if (_parsed.length > preview.length)
                Padding(
                  padding: const EdgeInsets.all(HpSpace.x4),
                  child: Text('+ ${_parsed.length - preview.length} more', style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                ),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x5),
        HpButton(
          label: 'Import ${_parsed.length} record${_parsed.length == 1 ? '' : 's'}',
          icon: Icons.check_rounded,
          size: HpButtonSize.lg,
          loading: _busy,
          onPressed: _busy ? null : _import,
        ),
      ],
    );
  }
}
