import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

class LiveMapPage extends StatelessWidget {
  const LiveMapPage({super.key, required this.repo});

  final OfficerRepository repo;

  @override
  Widget build(BuildContext context) {
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
              child: const SizedBox(height: 520, child: _MapCanvas()),
            ),
          );
          final side = _SidePanel(repo: repo);
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

class _MapCanvas extends StatelessWidget {
  const _MapCanvas();

  // (alignment x, y in [-1,1], marker color, ring)
  static const _markers = <(double, double, Color)>[
    (-0.5, -0.4, HpColors.mapOfficer),
    (0.2, -0.6, HpColors.mapPaid),
    (0.6, -0.2, HpColors.mapViolation),
    (-0.2, 0.1, HpColors.mapOfficer),
    (0.4, 0.3, HpColors.mapExpiring),
    (-0.6, 0.4, HpColors.mapPaid),
    (0.1, 0.6, HpColors.mapOfficer),
    (0.7, 0.55, HpColors.mapPaid),
    (-0.35, 0.7, HpColors.mapViolation),
    (0.55, -0.5, HpColors.mapExpiring),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF0C0C14)),
      child: CustomPaint(
        painter: _GridPainter(),
        child: Stack(
          children: [
            for (final m in _markers)
              Align(
                alignment: Alignment(m.$1, m.$2),
                child: _Marker(color: m.$3, officer: m.$3 == HpColors.mapOfficer),
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
          ],
        ),
      ),
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

class _Marker extends StatelessWidget {
  const _Marker({required this.color, this.officer = false});
  final Color color;
  final bool officer;

  @override
  Widget build(BuildContext context) {
    final size = officer ? 16.0 : 12.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: officer ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 2)],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.repo});
  final OfficerRepository repo;

  static const _legend = <(Color, String)>[
    (HpColors.mapOfficer, 'Officer'),
    (HpColors.mapPaid, 'Paid parking'),
    (HpColors.mapExpiring, 'Expiring soon'),
    (HpColors.mapViolation, 'Violation'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HpCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LEGEND', style: HpType.eyebrow),
              const SizedBox(height: HpSpace.x3),
              for (final l in _legend)
                Padding(
                  padding: const EdgeInsets.only(bottom: HpSpace.x2),
                  child: Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: l.$1, shape: BoxShape.circle, boxShadow: [BoxShadow(color: l.$1.withValues(alpha: 0.6), blurRadius: 6)])),
                    const SizedBox(width: HpSpace.x3),
                    Text(l.$2, style: HpType.body(size: 13, color: HpColors.text2)),
                  ]),
                ),
            ],
          ),
        ),
        const SizedBox(height: HpSpace.x4),
        Text('Officers on duty', style: HpType.heading(size: 15)),
        const SizedBox(height: HpSpace.x3),
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
                        Text(o.fullName, style: const TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 13)),
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
