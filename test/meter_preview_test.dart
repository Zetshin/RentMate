import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentmate/app/theme.dart';
import 'package:rentmate/features/owner/owner_demo.dart';
import 'package:rentmate/features/owner/presentation/owner_screens.dart';

void main() {
  testWidgets('Meter preview recalculates and rejects a decreasing reading', (
    tester,
  ) async {
    final owner = OwnerDemo();
    addTearDown(owner.dispose);
    final room = owner.addRoom('101')..previousElectricity = 1200;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: OwnerBillScreen(owner: owner, room: room),
      ),
    );
    final field = find.byType(TextFormField).last;
    await tester.enterText(field, '1275');
    await tester.pump();
    expect(find.text('ใช้ 75.00 หน่วย × 8.0 บาท = ฿600.00'), findsOneWidget);
    await tester.enterText(field, '1100');
    await tester.pump();
    expect(
      find.text('มิเตอร์ใหม่ต้องเป็นตัวเลขและไม่น้อยกว่ามิเตอร์เดิม'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
