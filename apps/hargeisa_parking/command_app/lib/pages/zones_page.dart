import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

/// The 8 Hargeisa districts with **live** stats: officers assigned (from the
/// officer roster) and violations / compliance (from the citations stream).
class ZonesPage extends StatelessWidget {
  const ZonesPage({super.key, required this.repo, required this.citations});

  final OfficerRepository repo;
  final List<Citation> citations;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HpSpace.x8),
      children: [
        Text('${kHargeisaDistricts.length} districts', style: HpType.heading(size: 18)),
        const SizedBox(height: HpSpace.x2),
        Text('Hargeisa zones officers patrol and citizens browse for deals.',
            style: HpType.body(size: 13.5)),
        const SizedBox(height: HpSpace.x5),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 1040 ? 4 : (c.maxWidth > 560 ? 2 : 1);
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: HpSpace.x4,
              mainAxisSpacing: HpSpace.x4,
              childAspectRatio: 1.5,
              children: [
                for (final d in kHargeisaDistricts) _ZoneCard(district: d, stats: _statsFor(d.id)),
              ],
            );
          },
        ),
      ],
    );
  }

  _ZoneStats _statsFor(String districtId) {
    final officers = repo.approved.where((o) => o.assignedDistrictId == districtId).length;
    final inDistrict = citations.where((c) => c.districtId == districtId).toList();
    final violations = inDistrict.where((c) => c.status == CitationStatus.outstanding).length;
    final resolved = inDistrict
        .where((c) => c.status == CitationStatus.paid || c.status == CitationStatus.dismissed)
        .length;
    final compliance = inDistrict.isEmpty ? 100 : ((resolved / inDistrict.length) * 100).round();
    return _ZoneStats(officers: officers, violations: violations, compliance: compliance);
  }
}

class _ZoneStats {
  const _ZoneStats({required this.officers, required this.violations, required this.compliance});
  final int officers;
  final int violations;
  final int compliance;
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({required this.district, required this.stats});
  final District district;
  final _ZoneStats stats;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: HpColors.purple300),
              const SizedBox(width: HpSpace.x2),
              Expanded(
                child: Text(district.name,
                    style: HpType.heading(size: 16), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(child: _Stat(value: '${stats.officers}', label: 'Officers')),
              Expanded(child: _Stat(value: '${stats.violations}', label: 'Violations')),
              Expanded(
                child: _Stat(
                  value: '${stats.compliance}%',
                  label: 'Compliance',
                  color: HpColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.color});
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: HpType.mono(size: 18, weight: FontWeight.w700, color: color ?? HpColors.text)),
        Text(label, style: HpType.eyebrow),
      ],
    );
  }
}
