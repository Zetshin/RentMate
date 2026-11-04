import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentmate/app/app.dart';

void main() {
  testWidgets('Tenant completes room and payment preview', (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const RentMateApp());
    Future<void> tap(String label) async {
      final target = find.text(label);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.enterText(find.byKey(const Key('username')), 'art');
    await tester.enterText(find.byKey(const Key('password')), 'password');
    await tap('เข้าสู่ระบบ');
    await tap('เข้าร่วมห้องพัก');
    await tester.enterText(find.byKey(const Key('invite_code')), 'wrong');
    await tap('ตรวจสอบรหัส');
    expect(find.text('ไม่พบรหัสนี้ ลองใช้ AB12-CD34'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('invite_code')), 'AB12-CD34');
    await tap('ตรวจสอบรหัส');
    await tester.enterText(find.byKey(const Key('first_name')), 'สมชาย');
    await tester.enterText(find.byKey(const Key('last_name')), 'ใจดี');
    await tap('ส่งคำขอเข้าร่วม');
    await tap('เครื่องมือทดลอง: จำลองเจ้าของอนุมัติ');
    expect(find.text('สวัสดี คุณสมชาย'), findsOneWidget);
    await tap('ชำระเงิน');
    expect(find.text('QR ตัวอย่าง • ใช้โอนเงินจริงไม่ได้'), findsOneWidget);
    await tap('ชำระแล้ว แนบสลิป');
    final send = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'ส่งหลักฐาน'),
    );
    expect(send.onPressed, isNull);
    await tap('เลือกสลิปตัวอย่าง');
    await tap('ส่งหลักฐาน');
    await tap('ยืนยันการส่ง');
    expect(find.text('รอตรวจสอบ'), findsOneWidget);
    await tap('จำลองปฏิเสธหลักฐาน');
    expect(find.text('เหตุผลตัวอย่าง: ยอดเงินไม่ตรงกับยอดบิล'), findsOneWidget);
    await tap('แนบหลักฐานใหม่');
    await tap('เลือกสลิปตัวอย่าง');
    await tap('ส่งหลักฐาน');
    await tap('ยืนยันการส่ง');
    await tap('จำลองอนุมัติหลักฐาน');
    expect(find.text('ชำระแล้ว'), findsOneWidget);
    await tap('กลับหน้าหลัก');
    await tap('ประวัติ');
    expect(find.text('ประวัติบิล'), findsOneWidget);
    await tap('บัญชี');
    expect(find.text('สมชาย ใจดี'), findsOneWidget);
  });
}
