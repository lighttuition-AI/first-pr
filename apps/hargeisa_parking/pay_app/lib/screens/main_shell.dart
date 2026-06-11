import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import '../data/citizen_store.dart';
import '../models/pay_models.dart';
import '../tabs/districts_tab.dart';
import '../tabs/home_tab.dart';
import '../tabs/profile_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.uid,
    required this.citizen,
    required this.store,
    required this.onSignOut,
  });

  final String uid;
  final Citizen citizen;
  final CitizenStore store;
  final VoidCallback onSignOut;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final FirebaseCitationRepository _citations = FirebaseCitationRepository();
  final FirebaseAppealRepository _appeals = FirebaseAppealRepository();

  late Citizen _citizen = widget.citizen;
  List<Citation> _list = [];
  StreamSubscription<List<Citation>>? _sub;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  /// (Re)subscribe to the live citations for this citizen's plate.
  void _listen() {
    _sub?.cancel();
    if (_citizen.plate.isEmpty) {
      setState(() => _list = []);
      return;
    }
    _sub = _citations.watchByPlate(_citizen.plate).listen((list) {
      if (mounted) setState(() => _list = list);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _editPlate() async {
    final plate = await _showPlateDialog(context, initial: _citizen.plate);
    if (plate == null) return;
    final clean = plate.trim().toUpperCase();
    await widget.store.setPlate(widget.uid, clean);
    if (!mounted) return;
    setState(() => _citizen = _citizen.copyWith(plate: clean));
    _listen();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(
        citizen: _citizen,
        citations: _list,
        repo: _citations,
        appeals: _appeals,
        onAddPlate: _editPlate,
      ),
      const DistrictsTab(),
      ProfileTab(
        citizen: _citizen,
        citations: _list,
        onSignOut: widget.onSignOut,
        onEditPlate: _editPlate,
      ),
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

/// Small dialog to set / change the citizen's vehicle plate.
Future<String?> _showPlateDialog(BuildContext context, {required String initial}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: HpColors.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
      title: Text('Your vehicle plate', style: HpType.heading(size: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter your number plate so we can show your citations.',
              style: HpType.body(size: 13.5)),
          const SizedBox(height: HpSpace.x4),
          HpInput(
            controller: ctrl,
            label: 'Number plate',
            hint: 'HG-0000',
            icon: Icons.pin_outlined,
            mono: true,
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
      actions: [
        HpButton(label: 'Cancel', variant: HpButtonVariant.ghost, onPressed: () => Navigator.pop(context)),
        HpButton(
          label: 'Save',
          onPressed: () => Navigator.pop(context, ctrl.text.trim().toUpperCase()),
        ),
      ],
    ),
  );
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
