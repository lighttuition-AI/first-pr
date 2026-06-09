import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../flows/broadcast.dart';
import '../flows/challenge_flow.dart';
import '../flows/top3_popup.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'admin_screen.dart';
import 'arena_screen.dart';
import 'cards_screen.dart';
import 'home_screen.dart';
import 'league_screen.dart';
import 'roster_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();

    // Broadcast popup: once per launch, after persisted state has loaded, show
    // any announcement this device hasn't seen yet.
    void checkBroadcast() {
      if (!app.restored) return;
      app.removeListener(checkBroadcast);
      final msg = app.pendingBroadcast;
      if (msg == null) return;
      app.markBroadcastSeen();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showBroadcastPopup(context, msg);
      });
    }

    if (app.restored) {
      checkBroadcast();
    } else {
      app.addListener(checkBroadcast);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // QA hooks (compile-time, default off): jump to a tab / skip the overlay.
      const qaAdmin = bool.fromEnvironment('FC_QA_ADMIN');
      const qaTab = int.fromEnvironment('FC_QA_TAB', defaultValue: -1);
      if (qaAdmin || qaTab >= 4) app.setAdmin(true); // admin-only tabs need admin
      if (qaTab >= 0) app.setTab(qaTab);
      const qaComp = String.fromEnvironment('FC_QA_COMP');
      if (qaComp.isNotEmpty) app.setCompetition(qaComp);
      const qaSub = String.fromEnvironment('FC_QA_SUB');
      if (qaSub.isNotEmpty) app.setLeagueSubTab(qaSub);
      const qa2v2 = bool.fromEnvironment('FC_QA_2V2');
      if (qa2v2) showChallengeFlow(context);
      const skipTop3 = bool.fromEnvironment('FC_SKIP_TOP3');
      // Top-3 winners overlay — once per session on login.
      if (!skipTop3 && !app.top3Seen) {
        app.top3Seen = true;
        showTop3(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isAdmin = app.isAdmin;
    final bottomPad = MediaQuery.of(context).padding.bottom + 88;

    Widget page(Widget child) => SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad),
            child: child,
          ),
        );

    // Admin-only tabs (Roster + Admin) appear only for signed-in admins.
    final tabs = <(IconData, String)>[
      (LucideIcons.home, 'Home'),
      (LucideIcons.swords, 'Arena'),
      (LucideIcons.trophy, 'League'),
      (LucideIcons.layers, 'Cards'),
      if (isAdmin) (LucideIcons.clipboardList, 'Roster'),
      if (isAdmin) (LucideIcons.shield, 'Control'),
    ];
    final pages = <Widget>[
      page(const HomeScreen()),
      page(const ArenaScreen()),
      page(const LeagueScreen()),
      page(const CardsScreen()),
      if (isAdmin) page(const RosterScreen()),
      if (isAdmin) page(const AdminScreen()),
    ];
    final index = app.activeTab.clamp(0, tabs.length - 1);

    return Scaffold(
      extendBody: true,
      backgroundColor: FC.bg,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: _BlurNav(
        index: index,
        onTap: (i) => context.read<AppState>().setTab(i),
        tabs: tabs,
      ),
    );
  }
}

class _BlurNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<(IconData, String)> tabs;
  const _BlurNav({required this.index, required this.onTap, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 72 + bottomSafe,
          padding: EdgeInsets.only(bottom: bottomSafe),
          decoration: const BoxDecoration(
            color: Color(0xE60A0A0F),
            border: Border(top: BorderSide(color: FC.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < tabs.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: FC.durBase,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            color: index == i ? FC.purpleTint : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(tabs[i].$1, size: 20, color: index == i ? FC.purple300 : FC.text2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tabs[i].$2,
                          style: FCType.body(
                            size: 10.5,
                            weight: FontWeight.w600,
                            color: index == i ? FC.purple300 : FC.textMuted,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
