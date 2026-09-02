import 'package:attendance_system/features/main_feature/leave_request/date_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 🚩 (2026-09-02) กันบั๊ก "เลือกทับครึ่งวันที่ลาไปแล้วได้"
///
/// เคสจริง: มีใบลาอนุมัติแล้ว 15 ก.ย. (บ่าย) – 22 ก.ย. (เช้า) พอสร้างคำขอใหม่
/// แล้วกด 15 ก.ย. ปฏิทินยอมให้เลือกเป็น "เต็มวัน" พรีวิวขึ้นว่าใช้สิทธิ์ 1 วัน
/// (ที่ถูกคือ 0.5 เพราะเหลือแค่ครึ่งเช้า) และกดส่งจริงจะโดน backend ตอบ 409
///
/// เกณฑ์ครึ่งวันต้องตรงกับ CheckOverlappingLeave ฝั่ง backend เป๊ะๆ
void main() {
  setUpAll(() => initializeDateFormatting('th_TH'));

  // ใบลาเดิม: 15 ก.ย. บ่าย ถึง 22 ก.ย. เช้า
  final occupied = OccupiedLeaveDates.fromJson([
    {
      'date-from': '2026-09-15T00:00:00Z',
      'date-to': '2026-09-22T00:00:00Z',
      'from-date-morning': false,
      'to-date-morning': true,
    }
  ]);

  group('OccupiedLeaveDates รู้ระดับครึ่งวัน', () {
    test('วันเริ่ม: บ่ายถูกจอง เช้ายังว่าง', () {
      final d = DateTime(2026, 9, 15);
      expect(occupied.isAfternoonTaken(d), isTrue);
      expect(occupied.isMorningTaken(d), isFalse);
      expect(occupied.isFull(d), isFalse, reason: 'ยังเหลือครึ่งเช้า ห้ามปิดทั้งวัน');
      expect(occupied.isPartlyTaken(d), isTrue);
    });

    test('วันสุดท้าย: เช้าถูกจอง บ่ายยังว่าง', () {
      final d = DateTime(2026, 9, 22);
      expect(occupied.isMorningTaken(d), isTrue);
      expect(occupied.isAfternoonTaken(d), isFalse);
      expect(occupied.isFull(d), isFalse);
    });

    test('วันตรงกลางเต็มทั้งวัน', () {
      for (final day in [16, 17, 18, 19, 20, 21]) {
        final d = DateTime(2026, 9, day);
        expect(occupied.isFull(d), isTrue, reason: '$day ก.ย. ต้องเต็มทั้งวัน');
      }
    });

    test('วันที่ไม่เกี่ยวข้องยังว่าง', () {
      expect(occupied.isPartlyTaken(DateTime(2026, 9, 14)), isFalse);
      expect(occupied.isPartlyTaken(DateTime(2026, 9, 23)), isFalse);
    });
  });

  group('ปฏิทินบังคับครึ่งวันให้ตรงกับที่ว่างจริง', () {
    late LeaveDate? emitted;

    Future<void> pump(WidgetTester tester) async {
      emitted = null;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DateSelect(
            allowRetroactive: true,
            budgetStart: DateTime(2025, 10, 1),
            budgetEnd: DateTime(2026, 9, 30),
            occupiedDates: occupied,
            onChanged: (d) => emitted = d,
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('เลือก 15 ก.ย. วันเดียว -> ได้ครึ่งเช้า ไม่ใช่เต็มวัน', (tester) async {
      await pump(tester);

      expect(find.text('15'), findsOneWidget);
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(emitted, isNotNull, reason: 'ครึ่งเช้ายังว่าง ต้องเลือกได้');
      expect(emitted!.fromDateMorning, isTrue);
      expect(emitted!.toDateMorning, isTrue,
          reason: 'เริ่มเช้า-จบเช้า = ครึ่งวันเช้า (0.5 วัน) ไม่ใช่ 1 วัน');
    });

    testWidgets('ลากคร่อมวันที่ลาเต็มไปแล้ว -> ไม่รับ (เงียบๆ)', (tester) async {
      await pump(tester);

      // 14 ก.ย. (ว่าง) ถึง 23 ก.ย. (ว่าง) แต่คร่อม 16–21 ที่ลาเต็มวันไปแล้ว
      await tester.tap(find.text('14'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('23'));
      await tester.pumpAndSettle();

      // แตะครั้งแรกเลือก 14 ก.ย. วันเดียวไปแล้ว การแตะ 23 ต้องถูกปฏิเสธ
      // ช่วงจึงต้องยังเป็น 14 ก.ย. วันเดียวเหมือนเดิม ไม่ยืดไปถึง 23
      expect(emitted!.toDate, DateTime.utc(2026, 9, 14),
          reason: 'ช่วงนี้ backend จะตอบ 409 จึงไม่ควรรับตั้งแต่แรก');
      // ไม่ขึ้นข้อความเตือนใน bottom sheet — วันที่ลาไปแล้วจางอยู่ในปฏิทินแล้ว
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
