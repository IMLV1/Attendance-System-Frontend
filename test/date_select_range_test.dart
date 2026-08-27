import 'package:attendance_system/features/main_feature/leave_request/date_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 🚩 (2026-08-27) กันบั๊ก "เลือกปีแล้วจอแดง"
///
/// TableCalendar assert ว่า focusedDay ต้องอยู่ใน [firstDay, lastDay] แต่รายการ
/// เดือน/ปีในเมนูเคยถูกเขียนตายไว้โดยไม่ดูขอบเขตนั้น พอปฏิทินถูกล็อกให้อยู่ใน
/// ปีงบประมาณ การเลือกปีที่เกินขอบเขตทำให้ทั้งหน้าพัง
///
/// เทสนี้เปิดเมนูปีจริงแล้วเช็คว่ามีแต่ปีที่เลือกได้ ไม่ใช่ปีที่จะทำให้ assert แตก
void main() {
  setUpAll(() => initializeDateFormatting('th_TH'));

  Future<void> pumpPicker(WidgetTester tester, {DateTime? start, DateTime? end}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DateSelect(
          allowRetroactive: true,
          budgetStart: start,
          budgetEnd: end,
          onChanged: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('เมนูปีเสนอเฉพาะปีที่อยู่ในช่วงปฏิทิน', (tester) async {
    // ปีงบประมาณ 1 ต.ค. 2025 – 30 ก.ย. 2026 (พ.ศ. 2568–2569)
    await pumpPicker(tester,
        start: DateTime(2025, 10, 1), end: DateTime(2026, 9, 30));

    // ปุ่มเปิดเมนูปีแสดงปี พ.ศ. ของเดือนที่โฟกัสอยู่
    await tester.tap(find.text('2569'));
    await tester.pumpAndSettle();

    expect(find.text('2568'), findsWidgets, reason: 'ปีเริ่มต้นต้องเลือกได้');
    expect(find.text('2569'), findsWidgets, reason: 'ปีสิ้นสุดต้องเลือกได้');
    expect(find.text('2570'), findsNothing,
        reason: 'ปีที่เกิน lastDay ไม่ควรถูกเสนอ — เลือกแล้วปฏิทิน assert แตก');
    expect(find.text('2579'), findsNothing);
  });

  testWidgets('เลือกปีสุดท้ายที่เสนอแล้วไม่พัง', (tester) async {
    await pumpPicker(tester,
        start: DateTime(2025, 10, 1), end: DateTime(2026, 9, 30));

    await tester.tap(find.text('2569'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2568').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
