import 'package:attendance_system/core/utils/menu_access.dart';
import 'package:flutter_test/flutter_test.dart';

/// 🚩 (2026-09-02) กันบั๊ก "พิมพ์ URL ตรงก็เข้าหน้าที่ไม่มีสิทธิ์ได้"
///
/// เมนูถูกซ่อนตาม role อยู่แล้ว แต่เป็นการซ่อนที่ปุ่ม — บนเว็บที่มีแถบที่อยู่
/// ใครก็พิมพ์ /settings/config-attendance เข้าไปได้ เทสนี้ล็อกกติกาไว้ว่า
/// หน้าไหนใครเปิดได้บ้าง
void main() {
  const admin = MenuAccess(['admin']);
  const hr = MenuAccess(['hr']);
  const main_ = MenuAccess(['main']);
  const none = MenuAccess([]);

  const configPages = [
    '/settings/budget-year',
    '/settings/config-attendance',
    '/settings/config-attendance-request',
    '/settings/config-leave-type',
  ];

  group('ตั้งค่าระบบ — admin เท่านั้น', () {
    for (final page in configPages) {
      test(page, () {
        expect(admin.canOpen(page), isTrue);
        expect(hr.canOpen(page), isFalse, reason: 'HR ต้อง config ระบบไม่ได้');
        expect(main_.canOpen(page), isFalse);
        expect(none.canOpen(page), isFalse);
      });
    }
  });

  test('จัดการผู้ใช้/ตำแหน่ง — admin กับ HR', () {
    for (final page in ['/settings/user-management', '/settings/role-management']) {
      expect(admin.canOpen(page), isTrue);
      expect(hr.canOpen(page), isTrue);
      expect(main_.canOpen(page), isFalse);
      expect(none.canOpen(page), isFalse);
    }
  });

  test('อนุมัติคำขอ — admin กับหัวหน้าสายตรง', () {
    expect(admin.canOpen('/approval'), isTrue);
    expect(main_.canOpen('/approval'), isTrue);
    expect(hr.canOpen('/approval'), isFalse);
    expect(none.canOpen('/approval'), isFalse);
  });

  test('ข้อมูลบุคลากร — ทุก role ที่ดูแลคนอื่น', () {
    for (final m in [admin, hr, main_, const MenuAccess(['special'])]) {
      expect(m.canOpen('/personnel-info'), isTrue);
    }
    expect(none.canOpen('/personnel-info'), isFalse);
  });

  test('route ลูกใช้กฎเดียวกับแม่', () {
    expect(hr.canOpen('/settings/config-attendance/anything'), isFalse);
    expect(admin.canOpen('/settings/config-attendance/anything'), isTrue);
    expect(none.canOpen('/approval/detail/123'), isFalse);
  });

  test('หน้าทั่วไปเปิดได้หมด ไม่ต้องมี role', () {
    for (final page in ['/check-in', '/profile', '/settings', '/leave-request',
                        '/attendance-request', '/statistic', '/attendance-history']) {
      expect(none.canOpen(page), isTrue, reason: '$page ไม่ควรถูกกัน');
    }
  });
}
