import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentmate/app/demo_session.dart';
import 'package:rentmate/app/theme.dart';
import 'package:rentmate/features/room/presentation/room_screens.dart';

void main() {
  testWidgets('Pending room heading status and clock are yellow', (
    tester,
  ) async {
    final session = DemoSession();
    addTearDown(session.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: PendingRoomScreen(session: session),
      ),
    );
    const yellow = Color(0xFFFACC15);
    for (final label in ['กำลังรอการอนุมัติ', 'สถานะ: รออนุมัติ']) {
      expect(tester.widget<Text>(find.text(label)).style?.color, yellow);
    }
    for (final icon in tester.widgetList<Icon>(
      find.byIcon(Icons.schedule_outlined),
    )) {
      expect(icon.color, yellow);
    }
  });
}
