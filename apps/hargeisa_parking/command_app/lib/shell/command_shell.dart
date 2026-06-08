import 'package:flutter/material.dart';
import 'package:hpark_core/hpark_core.dart';

import '../pages/appeals_review_page.dart';
import '../pages/approvals_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/live_map_page.dart';
import '../pages/officers_page.dart';
import '../pages/reports_page.dart';
import '../pages/vehicle_import_page.dart';
import '../pages/zones_page.dart';

/// The signed-in admin (mock). Used as the actor on approval decisions.
const String kAdminName = 'Hodan Ali';

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
  const CommandShell({super.key});

  @override
  State<CommandShell> createState() => _CommandShellState();
}

class _CommandShellState extends State<CommandShell> {
  final OfficerRepository repo = OfficerRepository.demo();
  late final List<Appeal> appeals = seedAppeals();
  CommandPage _page = CommandPage.dashboard;

  @override
  void dispose() {
    repo.dispose();
    super.dispose();
  }

  void _go(CommandPage p) => setState(() => _page = p);

  Widget _buildPage() {
    switch (_page) {
      case CommandPage.dashboard:
        return DashboardPage(repo: repo, onSeeApprovals: () => _go(CommandPage.approvals));
      case CommandPage.approvals:
        return ApprovalsPage(repo: repo, adminName: kAdminName);
      case CommandPage.officers:
        return OfficersPage(repo: repo);
      case CommandPage.vehicles:
        return const VehicleImportPage();
      case CommandPage.zones:
        return const ZonesPage();
      case CommandPage.liveMap:
        return LiveMapPage(repo: repo);
      case CommandPage.appeals:
        return AppealsReviewPage(
          appeals: appeals,
          adminName: kAdminName,
          onChanged: () => setState(() {}),
        );
      case CommandPage.reports:
        return const ReportsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Sidebar(
                current: _page,
                pendingCount: repo.pending.length,
                appealsCount: appeals.where((a) => a.status == AppealStatus.review).length,
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
    required this.onSelect,
  });

  final CommandPage current;
  final int pendingCount;
  final int appealsCount;
  final ValueChanged<CommandPage> onSelect;

  int? _badgeFor(CommandPage p) {
    if (p == CommandPage.approvals && pendingCount > 0) return pendingCount;
    if (p == CommandPage.appeals && appealsCount > 0) return appealsCount;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: HpSize.sidebar,
      decoration: const BoxDecoration(
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
          const Padding(
            padding: EdgeInsets.all(HpSpace.x4),
            child: Row(
              children: [
                HpAvatar(initials: 'HA', size: 38, statusColor: HpColors.success),
                SizedBox(width: HpSpace.x3),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kAdminName,
                          style: TextStyle(color: HpColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('City operations',
                          style: TextStyle(color: HpColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: HpColors.textMuted, size: 18),
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
                      style: const TextStyle(
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
      decoration: const BoxDecoration(
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
