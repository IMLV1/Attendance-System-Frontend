import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// บั๊ก (2026-08-25): `AppScaffold` เดิมห่อเนื้อหาด้วย `Align` เฉยๆ ซึ่งส่ง
/// constraint แบบหลวมให้ลูก ทำให้ `SingleChildScrollView` ที่เป็นชั้นนอกสุด
/// หดตามเนื้อหาแทนที่จะเต็ม viewport — หน้าที่วาดพื้นหลังไว้ในนั้น (เช่น
/// /settings) เลยมีพื้นหลังแค่แถบบน
void main() {
  Future<void> pumpWith(WidgetTester tester, Widget content) async {
    await tester.pumpWidget(
      MaterialApp(home: AppScaffold(content: content)),
    );
  }

  testWidgets('เนื้อหาที่สั้นกว่าจอต้องถูกยืดจนเต็มความสูง viewport',
      (tester) async {
    await pumpWith(
      tester,
      SingleChildScrollView(
        child: Container(
          key: const Key('bg'),
          color: const Color(0xFFEAEAEA),
          child: const SizedBox(height: 80, width: 100),
        ),
      ),
    );

    final scaffoldBody = tester.getSize(find.byType(SingleChildScrollView));
    final screen = tester.getSize(find.byType(AppScaffold));

    expect(scaffoldBody.height, screen.height,
        reason: 'scroll view ต้องสูงเต็มจอ ไม่ใช่ 80');
  });

  testWidgets('เนื้อหาที่ยาวกว่าจอต้องยัง scroll ได้ตามปกติ', (tester) async {
    await pumpWith(
      tester,
      SingleChildScrollView(
        child: Column(
          children: List.generate(
            60,
            (i) => SizedBox(height: 50, child: Text('row $i')),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final before = tester.getTopLeft(find.text('row 0')).dy;
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pump();
    expect(tester.getTopLeft(find.text('row 0')).dy, lessThan(before));
  });
}
