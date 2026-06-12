import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';
import 'package:intl/intl.dart';

/// Browse + search the full vehicle registry. Every vehicle on file, sorted
/// alphabetically by plate, with a live search box for a quick plate lookup.
class VehiclesDatabasePage extends StatefulWidget {
  const VehiclesDatabasePage({super.key, required this.vehicles});

  final FirebaseVehicleRepository vehicles;

  @override
  State<VehiclesDatabasePage> createState() => _VehiclesDatabasePageState();
}

class _VehiclesDatabasePageState extends State<VehiclesDatabasePage> {
  final TextEditingController _search = TextEditingController();
  List<Vehicle> _all = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await widget.vehicles.all();
      all.sort((a, b) => a.plate.toUpperCase().compareTo(b.plate.toUpperCase()));
      if (!mounted) return;
      setState(() {
        _all = all;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Vehicle> get _filtered {
    final q = _search.text.trim().toUpperCase();
    if (q.isEmpty) return _all;
    return _all
        .where((v) =>
            v.plate.toUpperCase().contains(q) ||
            v.ownerName.toUpperCase().contains(q) ||
            v.ownerNationalId.toUpperCase().contains(q))
        .toList();
  }

  Future<void> _edit(Vehicle v) async {
    final owner = TextEditingController(text: v.ownerName);
    final nid = TextEditingController(text: v.ownerNationalId);
    final make = TextEditingController(text: v.make);
    final color = TextEditingController(text: v.color);
    final permit = TextEditingController(text: v.permitStatus.name);
    final outCount = TextEditingController(text: '${v.outstandingCount}');
    final outTotal = TextEditingController(text: '${v.outstandingTotal}');

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HpColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
        title: Text('Edit ${v.plate}', style: HpType.heading(size: 18)),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HpInput(controller: owner, label: 'Owner'),
                const SizedBox(height: HpSpace.x3),
                HpInput(controller: nid, label: 'National ID', mono: true),
                const SizedBox(height: HpSpace.x3),
                HpInput(controller: make, label: 'Make'),
                const SizedBox(height: HpSpace.x3),
                HpInput(controller: color, label: 'Color'),
                const SizedBox(height: HpSpace.x3),
                HpInput(controller: permit, label: 'Permit (valid · expired · none)'),
                const SizedBox(height: HpSpace.x3),
                Row(children: [
                  Expanded(child: HpInput(controller: outCount, label: 'Outstanding #', keyboardType: TextInputType.number)),
                  const SizedBox(width: HpSpace.x3),
                  Expanded(child: HpInput(controller: outTotal, label: 'Outstanding total', keyboardType: TextInputType.number)),
                ]),
              ],
            ),
          ),
        ),
        actions: [
          HpButton(label: 'Cancel', variant: HpButtonVariant.ghost, onPressed: () => Navigator.pop(ctx, false)),
          HpButton(label: 'Save', onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (save != true) return;
    final p = permit.text.trim().toLowerCase();
    final updated = Vehicle(
      plate: v.plate,
      ownerName: owner.text.trim(),
      ownerNationalId: nid.text.trim(),
      make: make.text.trim(),
      color: color.text.trim(),
      permitStatus: p == 'valid'
          ? PermitStatus.valid
          : p == 'expired'
              ? PermitStatus.expired
              : PermitStatus.none,
      outstandingCount: int.tryParse(outCount.text.trim()) ?? 0,
      outstandingTotal: int.tryParse(outTotal.text.trim()) ?? 0,
    );
    try {
      await widget.vehicles.upsert(updated);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: HpColors.elevated,
          content: Text('Updated ${v.plate}', style: TextStyle(color: HpColors.text)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: HpColors.elevated,
          content: Text('Could not save: $e', style: const TextStyle(color: HpColors.danger)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        Row(
          children: [
            Expanded(child: Text('Vehicle database', style: HpType.heading(size: 18))),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _loading ? null : _load,
              icon: Icon(Icons.refresh_rounded, color: HpColors.text2),
            ),
          ],
        ),
        const SizedBox(height: HpSpace.x2),
        Text('Every vehicle on file, ordered by plate. Search to look one up.',
            style: HpType.body(size: 13.5)),
        const SizedBox(height: HpSpace.x5),
        HpInput(
          controller: _search,
          label: 'Search',
          hint: 'Plate, owner or national ID',
          icon: Icons.search_rounded,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: HpSpace.x5),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: HpSpace.x12),
            child: Center(child: CircularProgressIndicator(color: HpColors.purple)),
          )
        else if (_error != null)
          HpCard(
            child: Row(children: [
              const Icon(Icons.error_outline, color: HpColors.danger),
              const SizedBox(width: HpSpace.x3),
              Expanded(child: Text('Could not load: $_error', style: HpType.body(size: 13))),
            ]),
          )
        else ...[
          Text(
            _search.text.trim().isEmpty
                ? '${_all.length} vehicle${_all.length == 1 ? '' : 's'}'
                : '${rows.length} of ${_all.length} match',
            style: HpType.eyebrow,
          ),
          const SizedBox(height: HpSpace.x3),
          if (rows.isEmpty)
            HpCard(
              padding: const EdgeInsets.symmetric(vertical: HpSpace.x10),
              child: Center(
                child: Text(
                  _all.isEmpty ? 'No vehicles in the registry yet.' : 'No plate matches "${_search.text.trim()}".',
                  style: HpType.body(size: 14),
                ),
              ),
            )
          else
            HpCard(
              padding: const EdgeInsets.all(HpSpace.x3),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerRow(),
                    for (final v in rows) _DataRow(vehicle: v, onEdit: () => _edit(v)),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

const _cols = <(String, double)>[
  ('PLATE', 120),
  ('OWNER', 170),
  ('NATIONAL ID', 130),
  ('MAKE', 130),
  ('COLOR', 96),
  ('PERMIT', 116),
  ('OUTSTANDING', 150),
];

Widget _headerRow() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        for (final c in _cols)
          SizedBox(
            width: c.$2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(c.$1, style: HpType.eyebrow),
            ),
          ),
      ],
    ),
  );
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.vehicle, required this.onEdit});
  final Vehicle vehicle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.compact();
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: HpColors.border))),
      padding: const EdgeInsets.symmetric(vertical: HpSpace.x3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cell(0, Text(vehicle.plate, style: HpType.mono(size: 13.5, weight: FontWeight.w700))),
          _cell(1, Text(vehicle.ownerName, style: HpType.body(size: 13, color: HpColors.text), overflow: TextOverflow.ellipsis)),
          _cell(2, Text(vehicle.ownerNationalId, style: HpType.mono(size: 12.5, color: HpColors.text2), overflow: TextOverflow.ellipsis)),
          _cell(3, Text(vehicle.make, style: HpType.body(size: 13, color: HpColors.text2), overflow: TextOverflow.ellipsis)),
          _cell(4, Text(vehicle.color, style: HpType.body(size: 13, color: HpColors.text2), overflow: TextOverflow.ellipsis)),
          _cell(5, HpBadge(
            label: vehicle.permitStatus.label,
            color: vehicle.permitStatus.color,
            tint: vehicle.permitStatus.tint,
            glyph: vehicle.permitStatus.glyph,
          )),
          _cell(
            6,
            vehicle.outstandingCount > 0
                ? Text('${vehicle.outstandingCount} · SLSH ${money.format(vehicle.outstandingTotal)}',
                    style: HpType.mono(size: 12.5, color: HpColors.danger))
                : Text('—', style: HpType.body(size: 13, color: HpColors.textMuted)),
          ),
          SizedBox(
            width: 44,
            child: IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 18, color: HpColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(int i, Widget child) => SizedBox(
        width: _cols[i].$2,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Align(alignment: Alignment.centerLeft, child: child)),
      );
}
