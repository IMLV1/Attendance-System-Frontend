import 'package:attendance_system/shared/widgets/utils/file_drop_target.dart';
import 'package:flutter_test/flutter_test.dart';

/// 🚩 (2026-08-27) การลากไฟล์มาวาง (Phase 5.2) เป็น "ทางเข้าที่สอง" ของไฟล์แนบ
/// ซึ่งเสี่ยงจะหลุดเงื่อนไขของทางเข้าแรก (ปุ่มอัพโหลด) เพราะคนละโค้ดพาธ
/// เทสนี้ล็อกไว้ว่าสองทางรับของชนิดเดียวกันเสมอ
void main() {
  group('FileDropTarget.accepts', () {
    test('รับชนิดที่ระบบอนุญาต ไม่สนตัวพิมพ์เล็กใหญ่', () {
      expect(FileDropTarget.accepts('ใบรับรองแพทย์.pdf'), isTrue);
      expect(FileDropTarget.accepts('IMG_12345.JPG'), isTrue);
      expect(FileDropTarget.accepts('scan.HEIC'), isTrue);
    });

    test('ปฏิเสธชนิดที่ปุ่มอัพโหลดก็ไม่ให้เลือก', () {
      expect(FileDropTarget.accepts('รายงาน.docx'), isFalse);
      expect(FileDropTarget.accepts('archive.zip'), isFalse);
      // ไฟล์ไม่มีนามสกุล — เดิม `p.extension` คืนค่าว่าง ต้องไม่หลุดเข้ามา
      expect(FileDropTarget.accepts('README'), isFalse);
    });

    test('ดูนามสกุลตัวสุดท้ายเท่านั้น กันชื่อหลอกอย่าง .pdf.exe', () {
      expect(FileDropTarget.accepts('payload.pdf.exe'), isFalse);
      expect(FileDropTarget.accepts('report.final.pdf'), isTrue);
    });
  });
}
