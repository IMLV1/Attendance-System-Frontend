import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// สิทธิ์การเห็นเมนู — แหล่งความจริงเดียวของทั้ง bottom nav, sidebar และหน้า
/// "การตั้งค่าและการจัดการ"
///
/// 🚩 (2026-08-24) เดิมกติกาพวกนี้เขียนไว้ในหน้า `setting_page.dart` อย่างเดียว
/// (เช็ค `userType.contains('admin')` inline เป็นจุดๆ) ส่วน `SideBarNavigation`
/// ของ desktop hardcode `permissionLevel = 3` = โชว์ทุกเมนูให้ทุกคน
/// ผลคือคนที่ไม่มีสิทธิ์เห็นเมนู admin ครบบน iPad/desktop (กดเข้าไปแล้ว API
/// ตอบ 403 แต่ก็ไม่ควรเห็นตั้งแต่แรก)
class MenuAccess {
  final List<String> roles;

  const MenuAccess(this.roles);

  /// อ่านจาก `AuthState` ที่อยู่ใน provider tree
  factory MenuAccess.of(BuildContext context) =>
      MenuAccess(context.watch<AuthState>().user?.roleType ?? const []);

  bool _any(List<String> allowed) => allowed.any(roles.contains);

  /// ข้อมูลบุคลากรในองค์กร
  bool get canViewPersonnel => _any(const ['admin', 'hr', 'main', 'special']);

  /// อนุมัติคำขอ (ลา / เวลาเข้า-ออกงาน)
  bool get canApprove => _any(const ['admin', 'main']);

  /// จัดการผู้ใช้งานระบบ + จัดการตำแหน่ง
  bool get canManageUsers => _any(const ['admin', 'hr']);

  /// ตั้งค่าระบบ (ปีงบประมาณ, เวลางาน, คำขอ, ประเภทการลา)
  bool get canConfigSystem => roles.contains('admin');

  /// มีอะไรให้กดในกลุ่ม "อนุมัติ / บุคลากร" อย่างน้อย 1 อย่างมั้ย
  bool get hasApprovalGroup => canApprove || canViewPersonnel;
}
