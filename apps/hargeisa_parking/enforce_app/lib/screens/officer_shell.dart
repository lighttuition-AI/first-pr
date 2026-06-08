import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import '../state/shift_state.dart';
import '../tabs/activity_tab.dart';
import '../tabs/officer_profile_tab.dart';
import '../tabs/patrol_tab.dart';

/// The approved-officer experience: Patrol / Activity / Profile, over a shared
/// shift state (connectivity + issued citations).
class OfficerShell extends StatefulWidget {
  const OfficerShell({super.key, required this.officer, required this.onSignOut});

  final Officer officer;
  final VoidCallback onSignOut;

  @override
  State<OfficerShell> createState() => _OfficerShellState();
}

class _OfficerShellState extends State<OfficerShell> {
  final ShiftState shift = ShiftState();
  int _index = 0;

  @override
  void dispose() {
    shift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: shift,
      builder: (context, _) {
        final tabs = [
          PatrolTab(officer: widget.officer, shift: shift),
          ActivityTab(shift: shift),
          OfficerProfileTab(officer: widget.officer, shift: shift, onSignOut: widget.onSignOut),
        ];
        return Scaffold(
          body: DecoratedBox(
            decoration: HParkTheme.backgroundWash,
            child: SafeArea(bottom: false, child: tabs[_index]),
          ),
          bottomNavigationBar: _BottomNav(
            index: _index,
            queued: shift.queuedCount,
            onTap: (i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.queued, required this.onTap});

  final int index;
  final int queued;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.shield_outlined, Icons.shield, 'Patrol'),
    (Icons.receipt_long_outlined, Icons.receipt_long, 'Activity'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HpSize.bottomNav + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: HpColors.surface,
        border: Border(top: BorderSide(color: HpColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Badge(
                      isLabelVisible: i == 1 && queued > 0,
                      label: Text('$queued'),
                      backgroundColor: HpColors.warning,
                      textColor: HpColors.bg,
                      child: Icon(
                        i == index ? _items[i].$2 : _items[i].$1,
                        color: i == index ? HpColors.purple300 : HpColors.textMuted,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _items[i].$3,
                      style: TextStyle(
                        color: i == index ? HpColors.text : HpColors.textMuted,
                        fontSize: 11,
                        fontWeight: i == index ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
