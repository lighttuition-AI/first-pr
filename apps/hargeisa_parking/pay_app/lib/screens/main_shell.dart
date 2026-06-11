import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import '../data/citizen_store.dart';
import '../l10n/strings.dart';
import '../models/pay_models.dart';
import '../tabs/districts_tab.dart';
import '../tabs/home_tab.dart';
import '../tabs/profile_tab.dart';
import 'appeals_screen.dart';

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
    final plate = await _showTextDialog(
      context,
      title: tr('Your vehicle plate'),
      blurb: tr('Enter your number plate so we can show your citations.'),
      label: tr('Number plate'),
      hint: 'HG-0000',
      initial: _citizen.plate,
    );
    if (plate == null) return;
    final clean = plate.trim().toUpperCase();
    await widget.store.setPlate(widget.uid, clean);
    if (!mounted) return;
    setState(() => _citizen = _citizen.copyWith(plate: clean));
    _listen();
  }

  Future<void> _editNationalId() async {
    final value = await _showTextDialog(
      context,
      title: tr('National ID'),
      blurb: tr('Correct your Somaliland national ID if it was entered wrong.'),
      label: tr('Somaliland national ID'),
      hint: 'SL-0000-0000',
      initial: _citizen.nationalId,
    );
    if (value == null || value.trim().isEmpty) return;
    final clean = value.trim().toUpperCase();
    await widget.store.updateProfile(widget.uid, nationalId: clean);
    if (!mounted) return;
    setState(() => _citizen = _citizen.copyWith(nationalId: clean));
  }

  Future<void> _editDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _citizen.dateOfBirth,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(data: HParkTheme.dark, child: child!),
    );
    if (picked == null) return;
    await widget.store.updateProfile(widget.uid, dateOfBirth: picked);
    if (!mounted) return;
    setState(() => _citizen = _citizen.copyWith(dateOfBirth: picked));
  }

  void _openAppeals() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AppealsScreen(repo: _appeals, plate: _citizen.plate),
    ));
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
        onOpenProfile: () => setState(() => _index = 2),
      ),
      const DistrictsTab(),
      ProfileTab(
        citizen: _citizen,
        citations: _list,
        onSignOut: widget.onSignOut,
        onEditPlate: _editPlate,
        onEditNationalId: _editNationalId,
        onEditDob: _editDob,
        onOpenAppeals: _openAppeals,
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

/// Small reusable edit dialog (plate, national ID, …).
Future<String?> _showTextDialog(
  BuildContext context, {
  required String title,
  required String blurb,
  required String label,
  required String hint,
  required String initial,
}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: HpColors.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HpRadius.xl)),
      title: Text(title, style: HpType.heading(size: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(blurb, style: HpType.body(size: 13.5)),
          const SizedBox(height: HpSpace.x4),
          HpInput(
            controller: ctrl,
            label: label,
            hint: hint,
            icon: Icons.edit_outlined,
            mono: true,
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
      actions: [
        HpButton(label: tr('Cancel'), variant: HpButtonVariant.ghost, onPressed: () => Navigator.pop(context)),
        HpButton(
          label: tr('Save'),
          onPressed: () => Navigator.pop(context, ctrl.text),
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
      decoration: BoxDecoration(
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
                      tr(_items[i].$3),
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
