import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentmate/app/app.dart';

void main() {
  testWidgets('Owner creates property room and approves tenant', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const RentMateApp());
    Future<void> tap(String text) async {
      await tester.ensureVisible(find.text(text).last);
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.enterText(find.byKey(const Key('username')), 'owner');
    await tester.enterText(find.byKey(const Key('password')), 'password');
    await tap('เข้าสู่ระบบ');
    await tap('สร้างที่พักของฉัน');
    await tester.enterText(find.byKey(const Key('property_name')), 'สุขใจ');
    await tap('สร้างที่พัก');
    await tap('เพิ่มห้อง');
    await tester.enterText(find.byKey(const Key('room_number')), '101');
    await tester.tap(find.widgetWithText(FilledButton, 'เพิ่มห้อง'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('คัดลอกรหัสเชิญ'), findsOneWidget);
    await tap('ตั้งค่าค่าเช่าและเรท');
    await tap('บันทึกเรท');
    await tap('เครื่องมือทดลอง: จำลองคำขอเข้าห้อง');
    await tap('อนุมัติผู้เช่า');
    await tap('ยืนยัน');
    expect(find.byTooltip('คัดลอกรหัสเชิญ'), findsNothing);
    expect(find.text('สมชาย ใจดี'), findsOneWidget);
    await tap('กรอกมิเตอร์และออกบิล');
    expect(find.text('บิลพฤศจิกายน 2569'), findsOneWidget);
  });
}
