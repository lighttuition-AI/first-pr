import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

/// City activity map. The per-district **violation counts are live** (from the
/// citations stream); the layout is stylised because officer/citation GPS isn't
/// captured yet (a device-location follow-up). Officers on duty are live too.
class LiveMapPage extends StatelessWidget {
  const LiveMapPage({super.key, required this.repo, required this.citations});

  final OfficerRepository repo;
  final List<Citation> citations;

  Map<String, int> get _violationsByDistrict {
    final m = <String, int>{};
    for (final c in citations) {
      if (c.status == CitationStatus.outstanding && c.districtId.isNotEmpty) {
        m[c.districtId] = (m[c.districtId] ?? 0) + 1;
      }
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final violations = _violationsByDistrict;
    return Padding(
      padding: const EdgeInsets.all(HpSpace.x8),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 920;
          final map = HpCard(
            padding: EdgeInsets.zero,
            radius: HpRadius.xl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HpRadius.xl),
              child: SizedBox(height: 520, child: _MapCanvas(violations: violations)),
            ),
          );
          final side = _SidePanel(repo: repo, totalViolations: violations.values.fold(0, (s, v) => s + v));
          if (!wide) {
            return ListView(children: [map, const SizedBox(height: HpSpace.x4), side]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: map),
              const SizedBox(width: HpSpace.x4),
              SizedBox(width: 300, child: side),
            ],
          );
        },
      ),
    );
  }
}

/// Fixed stylised positions for the 8 districts (real GPS is a follow-up).
const _districtPositions = <String, Alignment>{
  'ahmed-dhagah': Alignment(-0.5, -0.4),
  '26-june': Alignment(0.2, -0.6),
  '31-may': Alignment(0.6, -0.2),
  'mohamed-mooge': Alignment(-0.2, 0.1),
  'maxamuud-haybe': Alignment(0.45, 0.3),
  'gacan-libaax': Alignment(-0.6, 0.45),
  'ibrahim-koodbuur': Alignment(0.1, 0.6),
  'macalin-haroon': Alignment(0.7, 0.55),
};

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({required this.violations});
  final Map<String, int> violations;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF0C0C14)),
      child: CustomPaint(
        painter: _GridPainter(),
        child: Stack(
          children: [
            for (final d in kHargeisaDistricts)
              if (_districtPositions[d.id] != null)
                Align(
                  alignment: _districtPositions[d.id]!,
                  child: _DistrictMarker(name: d.name, count: violations[d.id] ?? 0),
                ),
            Positioned(
              left: HpSpace.x4,
              top: HpSpace.x4,
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: HpColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Live · Hargeisa', style: HpType.body(size: 12.5, weight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
            Positioned(
              left: HpSpace.x4,
              bottom: HpSpace.x4,
              child: Text('Active violations by district · stylised layout (GPS pending)',
                  style: HpType.body(size: 11.5, color: Colors.white60)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistrictMarker extends StatelessWidget {
  const _DistrictMarker({required this.name, required this.count});
  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    final color = active ? HpColors.mapViolation : HpColors.mapPaid;
    final size = 14.0 + (count.clamp(0, 12)) * 2.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 2)],
          ),
          child: active
              ? Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))
              : null,
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.repo, required this.totalViolations});
  final OfficerRepository repo;
  final int totalViolations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HpCard(
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: HpColors.dangerTint, borderRadius: BorderRadius.circular(HpRadius.md)),
                child: const Icon(Icons.report_gmailerrorred_outlined, color: HpColors.danger),
              ),
              const SizedBox(width: HpSpace.x4),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$totalViolations active', style: HpType.heading(size: 18)),
                    Text('open violations city-wide', style: HpType.body(size: 12.5, color: HpColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x4),
        Text('Officers on duty', style: HpType.heading(size: 15)),
        const SizedBox(height: HpSpace.x3),
        if (repo.approved.isEmpty)
          Text('None on duty.', style: HpType.body(size: 13, color: HpColors.textMuted))
        else
          for (final o in repo.approved)
            Padding(
              padding: const EdgeInsets.only(bottom: HpSpace.x2),
              child: HpCard(
                padding: const EdgeInsets.all(HpSpace.x3),
                child: Row(
                  children: [
                    HpAvatar(initials: o.initials, size: 32, statusColor: HpColors.mapOfficer),
                    const SizedBox(width: HpSpace.x3),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.fullName, style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(districtById(o.assignedDistrictId)?.name ?? '—', style: HpType.body(size: 11.5, color: HpColors.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.my_location, size: 14, color: HpColors.mapOfficer),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
