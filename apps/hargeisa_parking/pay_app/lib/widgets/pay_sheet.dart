import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import '../l10n/strings.dart';
import '../util/format.dart';

/// Opens the ZAAD / eDahab payment sheet. Calls [onPaid] with the chosen
/// provider name after the sheet is dismissed.
void showPaySheet(
  BuildContext context, {
  required int amount,
  required void Function(String method) onPaid,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: HpColors.elevated,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(HpRadius.xl)),
    ),
    builder: (sheetCtx) => _PaySheet(
      amount: amount,
      onPaid: (method) {
        Navigator.pop(sheetCtx);
        onPaid(method);
      },
    ),
  );
}

class _PaySheet extends StatelessWidget {
  const _PaySheet({required this.amount, required this.onPaid});
  final int amount;
  final ValueChanged<String> onPaid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: HpSpace.x5,
        right: HpSpace.x5,
        top: HpSpace.x5,
        bottom: HpSpace.x6 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: HpColors.borderStrong, borderRadius: BorderRadius.circular(HpRadius.pill)),
            ),
          ),
          const SizedBox(height: HpSpace.x5),
          Text(trf('Pay {amount}', {'amount': slsh(amount)}), style: HpType.heading(size: 22)),
          const SizedBox(height: HpSpace.x2),
          Text(tr('Choose a mobile money provider.'), style: HpType.body(size: 14)),
          const SizedBox(height: HpSpace.x5),
          _ProviderTile(name: 'ZAAD', provider: 'Telesom', color: HpColors.teal, onTap: () => onPaid('ZAAD')),
          const SizedBox(height: HpSpace.x3),
          _ProviderTile(name: 'eDahab', provider: 'Dahabshiil', color: HpColors.purple300, onTap: () => onPaid('eDahab')),
        ],
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({required this.name, required this.provider, required this.color, required this.onTap});
  final String name;
  final String provider;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HpCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(HpRadius.md)),
            child: Icon(Icons.smartphone_rounded, color: color),
          ),
          const SizedBox(width: HpSpace.x4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w700, fontSize: 16)),
                Text(provider, style: HpType.body(size: 12.5, color: HpColors.textMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: HpColors.textMuted),
        ],
      ),
    );
  }
}
