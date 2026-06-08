// Basic smoke test for FC150 — Challenge Arena.
import 'package:flutter_test/flutter_test.dart';

import 'package:fc150/main.dart';

void main() {
  testWidgets('App boots and shows the bottom navigation', (tester) async {
    await tester.pumpWidget(const FC150App());
    await tester.pump();

    // The five bottom-nav tabs should be present.
    expect(find.text('Arena'), findsOneWidget);
    expect(find.text('League'), findsOneWidget);
    expect(find.text('Cards'), findsOneWidget);
  });
}
