import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentmate/app/app.dart';
import 'package:rentmate/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('Register checks confirmation and returns to Login', (
    tester,
  ) async {
    await tester.pumpWidget(const RentMateApp());
    await tester.tap(find.text('สมัครสมาชิก'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('register_username')), 'art');
    await tester.enterText(
      find.byKey(const Key('register_password')),
      'password',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirmation')),
      'different',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'สร้างบัญชี'));
    await tester.tap(find.widgetWithText(FilledButton, 'สร้างบัญชี'));
    await tester.pumpAndSettle();
    expect(find.text('รหัสผ่านไม่ตรงกัน'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('register_confirmation')),
      'password',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'สร้างบัญชี'));
    await tester.tap(find.widgetWithText(FilledButton, 'สร้างบัญชี'));
    await tester.pumpAndSettle();
    expect(
      find.text('ข้อมูลผ่านการตรวจสอบแล้ว ยังไม่ได้สร้างบัญชีจริง'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);
  });

  testWidgets('Login validates fields and toggles password', (tester) async {
    await tester.pumpWidget(const RentMateApp());
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pumpAndSettle();
    expect(find.text('กรุณากรอกชื่อผู้ใช้'), findsOneWidget);
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('username')), 'art');
    await tester.enterText(find.byKey(const Key('password')), 'password');
    await tester.tap(find.byTooltip('แสดงรหัสผ่าน'));
    await tester.pump();
    expect(find.byTooltip('ซ่อนรหัสผ่าน'), findsOneWidget);
    await tester.ensureVisible(find.text('เข้าสู่ระบบ'));
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pumpAndSettle();
    expect(
      find.text('หน้าตัวอย่าง: ยังไม่ได้เชื่อมระบบเข้าสู่ระบบ'),
      findsOneWidget,
    );
  });

  testWidgets('Small phone supports large text and keyboard', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(375, 667),
            textScaler: TextScaler.linear(2),
            viewInsets: EdgeInsets.only(bottom: 280),
          ),
          child: LoginScreen(),
        ),
      ),
    );
    await tester.ensureVisible(find.text('เข้าสู่ระบบ'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
