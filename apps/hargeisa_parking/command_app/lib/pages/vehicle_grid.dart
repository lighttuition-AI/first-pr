import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

/// A spreadsheet-style editor for the vehicle registry: labelled columns (A–H,
/// mapped to the registry fields), numbered rows, inline editing, add/remove
/// rows and clear. A duplicate check runs against the sheet **and** the live
/// database; the big push button stays disabled until every duplicate is cleared.
class VehicleGrid extends StatefulWidget {
  const VehicleGrid({super.key, required this.vehicles});

  final FirebaseVehicleRepository vehicles;

  @override
  State<VehicleGrid> createState() => _VehicleGridState();
}

/// (column letter, header label, width, numeric-only).
const _cols = <(String, String, double, bool)>[
  ('A', 'Plate', 116, false),
  ('B', 'Owner', 150, false),
  ('C', 'National ID', 124, false),
  ('D', 'Make', 116, false),
  ('E', 'Color', 96, false),
  ('F', 'Permit', 96, false),
  ('G', 'Out #', 70, true),
  ('H', 'Out total', 100, true),
];

class _VehicleGridState extends State<VehicleGrid> {
  final List<List<TextEditingController>> _rows = [];
  Set<String> _dbPlates = {};
  bool _loadedDb = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 3; i++) {
      _rows.add(_newRow());
    }
    _loadDb();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      for (final c in r) {
        c.dispose();
      }
    }
    super.dispose();
  }

  List<TextEditingController> _newRow() =>
      List.generate(_cols.length, (_) => TextEditingController());

  Future<void> _loadDb() async {
    try {
      final all = await widget.vehicles.all();
      if (!mounted) return;
      setState(() {
        _dbPlates = all.map((v) => v.plate.toUpperCase()).toSet();
        _loadedDb = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loadedDb = true);
    }
  }

  // ---- row ops ----
  void _addRow() => setState(() => _rows.add(_newRow()));
  void _removeRow(int i) => setState(() {
        for (final c in _rows[i]) {
          c.dispose();
        }
        _rows.removeAt(i);
        if (_rows.isEmpty) _rows.add(_newRow());
      });
  void _clearAll() => setState(() {
        for (final r in _rows) {
          for (final c in r) {
        c.dispose();
      }
        }
        _rows
          ..clear()
          ..add(_newRow());
      });

  // ---- derived ----
  String _plate(int i) => _rows[i][0].text.trim().toUpperCase();
  List<int> get _filled => [for (var i = 0; i < _rows.length; i++) if (_plate(i).isNotEmpty) i];

  Map<String, int> get _plateCounts {
    final m = <String, int>{};
    for (final i in _filled) {
      m[_plate(i)] = (m[_plate(i)] ?? 0) + 1;
    }
    return m;
  }

  String? _dupReason(int i) {
    final p = _plate(i);
    if (p.isEmpty) return null;
    if ((_plateCounts[p] ?? 0) > 1) return 'Duplicate in sheet';
    if (_dbPlates.contains(p)) return 'Already in registry';
    return null;
  }

  int get _dupCount => _filled.where((i) => _dupReason(i) != null).length;
  bool get _canPush => !_busy && _loadedDb && _filled.isNotEmpty && _dupCount == 0;

  Vehicle _vehicleAt(int i) {
    String at(int j) => _rows[i][j].text.trim();
    final permit = at(5).toLowerCase();
    return Vehicle(
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
    );
  }

  Future<void> _push() async {
    if (!_canPush) return;
    setState(() => _busy = true);
    var n = 0;
    for (final i in _filled) {
      try {
        await widget.vehicles.upsert(_vehicleAt(i));
        n++;
      } catch (_) {/* skip a bad row */}
    }
    await _loadDb();
    if (!mounted) return;
    setState(() {
      _busy = false;
      for (final r in _rows) {
        for (final c in r) {
        c.dispose();
      }
      }
      _rows
        ..clear()
        ..add(_newRow());
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HpColors.elevated,
        content: Row(children: [
          const Icon(Icons.check_circle, color: HpColors.success, size: 18),
          const SizedBox(width: HpSpace.x3),
          Text('Pushed $n vehicle${n == 1 ? '' : 's'} to the live registry', style: TextStyle(color: HpColors.text)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dups = _dupCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Or enter data directly', style: HpType.heading(size: 16))),
            HpButton(label: 'Add row', variant: HpButtonVariant.secondary, size: HpButtonSize.sm, icon: Icons.add_rounded, onPressed: _addRow),
            const SizedBox(width: HpSpace.x2),
            HpButton(label: 'Clear', variant: HpButtonVariant.ghost, size: HpButtonSize.sm, icon: Icons.backspace_outlined, onPressed: _clearAll),
          ],
        ),
        const SizedBox(height: HpSpace.x2),
        Text('Columns map to the registry fields (Permit = valid · expired · none). '
            'Plates must be unique — in this sheet and against the live database.',
            style: HpType.body(size: 12.5, color: HpColors.textMuted)),
        const SizedBox(height: HpSpace.x4),
        if (dups > 0) _dupBanner(dups),
        HpCard(
          padding: const EdgeInsets.all(HpSpace.x3),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerRow(),
                for (var i = 0; i < _rows.length; i++) _dataRow(i),
              ],
            ),
          ),
        ),
        const SizedBox(height: HpSpace.x5),
        HpButton(
          label: dups > 0
              ? 'Clear $dups duplicate${dups == 1 ? '' : 's'} to push'
              : 'Push ${_filled.length} vehicle${_filled.length == 1 ? '' : 's'} to the live system',
          icon: dups > 0 ? Icons.error_outline_rounded : Icons.cloud_upload_outlined,
          size: HpButtonSize.lg,
          expand: true,
          loading: _busy,
          onPressed: _canPush ? _push : null,
        ),
      ],
    );
  }

  Widget _dupBanner(int dups) {
    final plates = <String>{
      for (final i in _filled) if (_dupReason(i) != null) _plate(i),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: HpSpace.x4),
      child: HpCard(
        borderColor: HpColors.danger.withValues(alpha: 0.4),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: HpColors.danger),
          const SizedBox(width: HpSpace.x3),
          Expanded(
            child: Text(
              '$dups duplicate row${dups == 1 ? '' : 's'} (${plates.join(', ')}) — fix or remove '
              'before pushing. No duplicates can enter the registry.',
              style: HpType.body(size: 13, color: HpColors.text),
            ),
          ),
        ]),
      ),
    );
  }

  static const double _numW = 34;
  static const double _delW = 40;

  Widget _headerRow() {
    return Row(
      children: [
        SizedBox(width: _numW, child: Text('#', textAlign: TextAlign.center, style: HpType.eyebrow)),
        for (final c in _cols)
          SizedBox(
            width: c.$3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(text: '${c.$1}  ', style: HpType.eyebrow.copyWith(color: HpColors.purple300)),
                  TextSpan(text: c.$2.toUpperCase(), style: HpType.eyebrow),
                ]),
              ),
            ),
          ),
        const SizedBox(width: _delW),
      ],
    );
  }

  Widget _dataRow(int i) {
    final reason = _dupReason(i);
    final bad = reason != null;
    return Container(
      decoration: BoxDecoration(
        color: bad ? HpColors.dangerTint : null,
        border: Border(top: BorderSide(color: HpColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _numW,
            child: Text('${i + 1}', textAlign: TextAlign.center, style: HpType.mono(size: 12, color: HpColors.textMuted)),
          ),
          for (var j = 0; j < _cols.length; j++) _cell(i, j),
          SizedBox(
            width: _delW,
            child: IconButton(
              tooltip: 'Delete row',
              padding: EdgeInsets.zero,
              onPressed: () => _removeRow(i),
              icon: Icon(Icons.close_rounded, size: 16, color: HpColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(int i, int j) {
    final col = _cols[j];
    return Container(
      width: col.$3,
      padding: const EdgeInsets.all(3),
      child: TextField(
        controller: _rows[i][j],
        onChanged: (_) => setState(() {}),
        keyboardType: col.$4 ? TextInputType.number : TextInputType.text,
        inputFormatters: col.$4 ? [FilteringTextInputFormatter.digitsOnly] : null,
        textCapitalization: j == 0 ? TextCapitalization.characters : TextCapitalization.none,
        style: HpType.mono(size: 12.5, color: HpColors.text),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          filled: true,
          fillColor: HpColors.overlay,
          hintText: j == 5 ? 'none' : null,
          hintStyle: HpType.body(size: 12, color: HpColors.textMuted),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(HpRadius.sm),
            borderSide: BorderSide(color: HpColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(HpRadius.sm),
            borderSide: const BorderSide(color: HpColors.purple),
          ),
        ),
      ),
    );
  }
}
