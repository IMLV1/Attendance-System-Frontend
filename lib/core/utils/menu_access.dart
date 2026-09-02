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
/// ปลายทางของ sidebar — หน้าที่กดถึงได้ในคลิกเดียวจากเมนูข้าง
///
/// 🚩 (2026-08-24) นี่คือ **แหล่งความจริงเดียว** ของ path/ชื่อ/ไอคอน
/// เดิมข้อมูลชุดนี้กระจายอยู่ 2 ที่ (ปุ่มใน `sidebar_navigation.dart` กับเซ็ต path
/// ที่ header ใช้) ซึ่งเป็นรูปแบบเดียวกับที่เคยทำให้ลิงก์ตาย 10 จุด — พอแก้ที่นึง
/// อีกที่ไม่ตาม
///
/// ใช้ 3 ที่:
///   1. `sidebar_navigation.dart` สร้างปุ่มเมนู
///   2. `Header._showBackButton` ตัดสินว่าหน้านี้ควรมีปุ่ม back มั้ย
///      (หน้าใต้ `/settings` เป็น route ลูก พอ `context.go()` ไป go_router จะสร้าง
///      สแตกทั้งสายให้ `canPop()` เลยตอบ true ทั้งที่กดมาจาก sidebar ตรงๆ)
///   3. `Header.subHeader` หยิบชื่อ/ไอคอนมาโชว์เวลาหน้านั้นเป็นปลายทาง
class SidebarDestination {
  final String path;
  final String name;

  /// ชื่ออังกฤษใต้ชื่อไทยบนแถบหัว — หน้าหลักทุกหน้ามีอยู่แล้ว (Time Attendance,
  /// Statistic, ...) หน้าที่มาจาก sidebar เหมือนกันจึงต้องมีให้ครบ ไม่งั้นแถบหัว
  /// จะสูงไม่เท่ากันและดูเป็นคนละชุด
  final String nameEn;
  final String icon;

  const SidebarDestination(this.path, this.name, this.nameEn, this.icon);
}

const sidebarDestinationList = <SidebarDestination>[
  SidebarDestination('/check-in', 'ลงชื่อเข้า-ออกงาน', 'Time Attendance', 'icon_checkin.svg'),
  SidebarDestination('/attendance-request', 'ขออนุมัติเวลาเข้า-ออกงาน', 'Attendance Request', 'icon_time_request.svg'),
  SidebarDestination('/leave-request', 'การลางาน', 'Leave Request', 'icon_leave.svg'),
  SidebarDestination('/statistic', 'สถิติ', 'Statistic', 'icon_statistic.svg'),
  SidebarDestination('/attendance-history', 'บันทึกการเข้างาน', 'Attendance History', 'icon_attendance_history.svg'),
  SidebarDestination('/approval', 'อนุมัติคำขอ', 'Approval', 'icon_approval.svg'),
  SidebarDestination('/personnel-info', 'ข้อมูลบุคลากรในองค์กร', 'Personnel Info', 'icon_personnel_info.svg'),

  // สองตัวนี้ไม่ได้เป็นปุ่มในรายการเมนู แต่ก็ถึงได้ในคลิกเดียวจากแถบโปรไฟล์ด้านล่าง
  // จึงนับเป็นปลายทางเหมือนกัน (ไม่ควรมีปุ่ม back)
  SidebarDestination('/settings', 'ตั้งค่า', 'Settings', 'icon_setting.svg'),
  SidebarDestination('/profile', 'โปรไฟล์', 'User Profile', 'icon_personnel_info.svg'),
];

final Map<String, SidebarDestination> sidebarDestinationByPath = {
  for (final d in sidebarDestinationList) d.path: d,
};

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

  /// เส้นทางที่ต้องมีสิทธิ์ถึงจะเปิดได้ — คีย์เทียบแบบ prefix (route ลูกใช้กฎเดียวกับแม่)
  ///
  /// 🚩 (2026-09-02) `redirect` ของ go_router ตรวจแค่ "ล็อกอินรึยัง" ไม่เคยตรวจ
  /// สิทธิ์เลย เมนูถูกซ่อนก็จริงแต่เป็นการซ่อนที่ปุ่มเท่านั้น — บนเว็บพิมพ์
  /// `/settings/config-attendance` ลงแถบที่อยู่ตรงๆ ก็เข้าได้ทุก role
  /// (backend ยังกัน PUT ด้วย RequireAdmin อยู่ จึงบันทึกไม่ได้ แต่เห็นค่าทั้งหมด
  /// และกดบันทึกจนได้ 403 ซึ่งไม่ควรมาถึงตรงนั้นตั้งแต่แรก)
  static const _guarded = <String, String>{
    '/settings/budget-year': 'config',
    '/settings/config-attendance': 'config',
    '/settings/config-attendance-request': 'config',
    '/settings/config-leave-type': 'config',
    '/settings/user-management': 'users',
    '/settings/role-management': 'users',
    '/approval': 'approve',
    '/personnel-info': 'personnel',
  };

  bool canOpen(String location) {
    for (final entry in _guarded.entries) {
      if (location != entry.key && !location.startsWith('${entry.key}/')) continue;
      return switch (entry.value) {
        'config' => canConfigSystem,
        'users' => canManageUsers,
        'approve' => canApprove,
        'personnel' => canViewPersonnel,
        _ => true,
      };
    }
    return true;
  }

  /// มีอะไรให้กดในกลุ่ม "อนุมัติ / บุคลากร" อย่างน้อย 1 อย่างมั้ย
  bool get hasApprovalGroup => canApprove || canViewPersonnel;

  // --- กฎการมอบ/ถอดตำแหน่ง (2026-09-02) --------------------------------
  //
  // 🚩 กฎชุดนี้ backend บังคับอยู่แล้ว (user_handler.go) — ที่นี่มีไว้เพื่อไม่ให้
  // ผู้ใช้เห็นตัวเลือกที่กดไปก็โดนปฏิเสธ ไม่ใช่ด่านความปลอดภัย
  // **ห้ามแก้ที่นี่อย่างเดียวโดยไม่แก้ backend** ไม่งั้นจะกลายเป็นบังคับที่หน้าจอ
  // ที่เดียวเหมือนที่เคยเป็นมา

  /// แตะตำแหน่งระดับ "ผู้ดูแลระบบ" ได้มั้ย (สร้าง / แก้ / ลบ / มอบให้คนอื่น)
  /// HR ทำไม่ได้ — ทำได้เฉพาะ admin
  bool get canManageAdminRole => roles.contains('admin');

  /// แก้ตำแหน่งของผู้ใช้คนนี้ได้มั้ย
  ///
  /// ห้ามแก้ของตัวเองเสมอ ไม่ว่าจะเป็น admin หรือ HR — คนที่มีสิทธิ์แก้ตำแหน่ง
  /// ไม่ควรยกระดับตัวเองได้
  bool canEditRolesOf(String? targetUserId, String? myUserId) {
    if (!canManageUsers) return false;
    if (targetUserId == null || myUserId == null) return true;
    return targetUserId != myUserId;
  }
}
