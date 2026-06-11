import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';
import 'package:hpark_firebase/hpark_firebase.dart';

import '../pages/appeals_review_page.dart';
import '../pages/approvals_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/live_map_page.dart';
import '../pages/officers_page.dart';
import '../pages/reports_page.dart';
import '../pages/vehicle_import_page.dart';
import '../pages/zones_page.dart';

enum CommandPage {
  dashboard('Dashboard', Icons.grid_view_rounded),
  approvals('Officer approvals', Icons.verified_user_outlined),
  officers('Officers', Icons.badge_outlined),
  vehicles('Vehicles', Icons.directions_car_outlined),
  zones('Zones', Icons.map_outlined),
  liveMap('Live map', Icons.my_location_outlined),
  appeals('Appeals', Icons.gavel_outlined),
  reports('Reports', Icons.bar_chart_rounded);

  const CommandPage(this.title, this.icon);
  final String title;
  final IconData icon;
}

class CommandShell extends StatefulWidget {
  const CommandShell({
    super.key,
    required this.repo,
    required this.adminName,
    required this.onSignOut,
  });

  final OfficerRepository repo;
  final String adminName;
  final VoidCallback onSignOut;

  @override
  State<CommandShell> createState() => _CommandShellState();
}

class _CommandShellState extends State<CommandShell> {
  OfficerRepository get repo => widget.repo;

  final FirebaseAppealRepository _appealRepo = FirebaseAppealRepository();
  final FirebaseCitationRepository _citationRepo = FirebaseCitationRepository();
  final FirebaseVehicleRepository _vehicleRepo = FirebaseVehicleRepository();
  List<Appeal> appeals = [];
  List<Citation> citations = [];
  StreamSubscription<List<Appeal>>? _appealSub;
  StreamSubscription<List<Citation>>? _citationSub;

  CommandPage _page = CommandPage.dashboard;

  @override
  void initState() {
    super.initState();
    _appealSub = _appealRepo.watchAll().listen((list) {
      if (mounted) setState(() => appeals = list);
    }, onError: (_) {});
    _citationSub = _citationRepo.watchAll().listen((list) {
      if (mounted) setState(() => citations = list);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _appealSub?.cancel();
    _citationSub?.cancel();
    super.dispose();
  }

  /// Record an appeal decision and reflect it on the citation:
  ///  - dismiss the citation (appeal succeeds) → citation `dismissed`
  ///  - uphold the citation (appeal fails)     → citation back to `outstanding`
  Future<void> _decideAppeal(Appeal a, AppealStatus status) async {
    await _appealRepo.decide(a.id, status: status, by: widget.adminName);
    if (status == AppealStatus.dismissed) {
      await _citationRepo.setStatus(a.citationId, CitationStatus.dismissed);
    } else if (status == AppealStatus.upheld) {
      await _citationRepo.setStatus(a.citationId, CitationStatus.outstanding);
    }
  }

  void _go(CommandPage p) => setState(() => _page = p);

  Widget _buildPage() {
    switch (_page) {
      case CommandPage.dashboard:
        return DashboardPage(repo: repo, citations: citations, onSeeApprovals: () => _go(CommandPage.approvals));
      case CommandPage.approvals:
        return ApprovalsPage(repo: repo, adminName: widget.adminName);
      case CommandPage.officers:
        return OfficersPage(repo: repo);
      case CommandPage.vehicles:
        return VehicleImportPage(vehicles: _vehicleRepo);
      case CommandPage.zones:
        return ZonesPage(repo: repo, citations: citations);
      case CommandPage.liveMap:
        return LiveMapPage(repo: repo, citations: citations);
      case CommandPage.appeals:
        return AppealsReviewPage(
          appeals: appeals,
          adminName: widget.adminName,
          onDecide: _decideAppeal,
        );
      case CommandPage.reports:
        return ReportsPage(citations: citations);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([repo, hpTheme]),
        builder: (context, _) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Sidebar(
                current: _page,
                pendingCount: repo.pending.length,
                appealsCount: appeals.where((a) => a.status == AppealStatus.review).length,
                adminName: widget.adminName,
                onSignOut: widget.onSignOut,
                onSelect: _go,
              ),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(title: _page.title),
                    Expanded(
                      child: Container(
                        color: HpColors.bg,
                        child: _buildPage(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.current,
    required this.pendingCount,
    required this.appealsCount,
    required this.adminName,
    required this.onSignOut,
    required this.onSelect,
  });

  final CommandPage current;
  final int pendingCount;
  final int appealsCount;
  final String adminName;
  final VoidCallback onSignOut;
  final ValueChanged<CommandPage> onSelect;

  String get _initials {
    final parts = adminName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  int? _badgeFor(CommandPage p) {
    if (p == CommandPage.approvals && pendingCount > 0) return pendingCount;
    if (p == CommandPage.appeals && appealsCount > 0) return appealsCount;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: HpSize.sidebar,
      decoration: BoxDecoration(
        color: HpColors.surface,
        border: Border(right: BorderSide(color: HpColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(HpSpace.x5, HpSpace.x6, HpSpace.x5, HpSpace.x5),
            child: HpWordmark(markSize: 36),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3),
              children: [
                for (final p in CommandPage.values)
                  _NavItem(
                    page: p,
                    active: p == current,
                    badge: _badgeFor(p),
                    onTap: () => onSelect(p),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(HpSpace.x4),
            child: Row(
              children: [
                HpAvatar(initials: _initials, size: 38, statusColor: HpColors.success),
                const SizedBox(width: HpSpace.x3),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(adminName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('City operations',
                          style: TextStyle(color: HpColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: hpTheme.isDark ? 'Switch to light' : 'Switch to dark',
                  onPressed: () => hpTheme.toggle(),
                  icon: Icon(hpTheme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      color: HpColors.textMuted, size: 18),
                ),
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: onSignOut,
                  icon: Icon(Icons.logout_rounded, color: HpColors.textMuted, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.page,
    required this.active,
    required this.onTap,
    this.badge,
  });

  final CommandPage page;
  final bool active;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: active ? HpColors.purpleTint : Colors.transparent,
        borderRadius: BorderRadius.circular(HpRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HpRadius.md),
          hoverColor: HpColors.overlay,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3, vertical: 11),
            child: Row(
              children: [
                Icon(page.icon,
                    size: 20, color: active ? HpColors.purple300 : HpColors.text2),
                const SizedBox(width: HpSpace.x3),
                Expanded(
                  child: Text(
                    page.title,
                    style: TextStyle(
                      color: active ? HpColors.text : HpColors.text2,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: HpColors.warning,
                      borderRadius: BorderRadius.circular(HpRadius.pill),
                    ),
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        color: HpColors.bg,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HpSize.topbar,
      padding: const EdgeInsets.symmetric(horizontal: HpSpace.x8),
      decoration: BoxDecoration(
        color: HpColors.bg,
        border: Border(bottom: BorderSide(color: HpColors.border)),
      ),
      child: Row(
        children: [
          Text(title, style: HpType.heading(size: 20)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: HpSpace.x3, vertical: 6),
            decoration: BoxDecoration(
              color: HpColors.successTint,
              borderRadius: BorderRadius.circular(HpRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(color: HpColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text('System online',
                    style: HpType.body(size: 12, weight: FontWeight.w600, color: HpColors.success)),
              ],
            ),
          ),
          const SizedBox(width: HpSpace.x4),
          const HpAvatar(initials: 'HA', size: 36),
        ],
      ),
    );
  }
}
