import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Bottom sheet matching the handoff: slides up from the bottom (260ms ease-out),
/// dim backdrop, drag handle, rounded top corners, tap-scrim to dismiss.
Future<T?> showFcSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x9E040409),
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: FC.durSlow,
    ),
    builder: (ctx) => _SheetShell(child: builder(ctx)),
  );
}

class _SheetShell extends StatelessWidget {
  final Widget child;
  const _SheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: const BoxDecoration(
          color: FC.elevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(FC.rSheet)),
          border: Border(
            top: BorderSide(color: FC.border),
            left: BorderSide(color: FC.border),
            right: BorderSide(color: FC.border),
          ),
          boxShadow: [
            BoxShadow(color: Color(0xB3000000), blurRadius: 40, spreadRadius: -12, offset: Offset(0, -12)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: FC.borderStrong,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
