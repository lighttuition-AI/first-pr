import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

class ZonesPage extends StatelessWidget {
  const ZonesPage({super.key});

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
                for (final d in kHargeisaDistricts) _ZoneCard(district: d),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({required this.district});
  final District district;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      onTap: () {},
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
              Expanded(child: _Stat(value: '${district.officersAssigned}', label: 'Officers')),
              Expanded(child: _Stat(value: '${district.activeViolations}', label: 'Violations')),
              Expanded(
                child: _Stat(
                  value: '${district.compliancePct}%',
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
