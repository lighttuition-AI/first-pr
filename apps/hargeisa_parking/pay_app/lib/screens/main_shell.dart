import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import '../data/pay_data.dart';
import '../models/pay_models.dart';
import '../tabs/districts_tab.dart';
import '../tabs/home_tab.dart';
import '../tabs/profile_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.citizen, required this.onSignOut});

  final Citizen citizen;
  final VoidCallback onSignOut;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final List<Citation> _citations = seedCitations();

  void _payAllOutstanding() {
    setState(() {
      for (final c in _citations) {
        if (c.status == CitationStatus.outstanding) {
          c.status = CitationStatus.paid;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(citizen: widget.citizen, citations: _citations, onPaidAll: _payAllOutstanding),
      const DistrictsTab(),
      ProfileTab(citizen: widget.citizen, onSignOut: widget.onSignOut),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: HParkTheme.backgroundWash,
        child: SafeArea(bottom: false, child: tabs[_index]),
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.map_outlined, Icons.map_rounded, 'Districts'),
    (Icons.person_outline, Icons.person_rounded, 'Profile'),
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
                    Icon(
                      i == index ? _items[i].$2 : _items[i].$1,
                      color: i == index ? HpColors.purple300 : HpColors.textMuted,
                      size: 24,
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
