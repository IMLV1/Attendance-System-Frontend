import 'package:attendance_system/core/auth/auth_state.dart';
import 'package:attendance_system/core/utils/menu_access.dart';
import 'package:attendance_system/core/utils/navigation_guard.dart';
import 'package:attendance_system/features/settings/admin_config/admin_config_utils.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/popup/floating_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SideBarNavigation extends StatelessWidget {

  final String currentPath;

  const SideBarNavigation({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {

    // 🚩 (2026-08-24) เดิม hardcode `int permissionLevel = 3` = ทุกคนเห็นเมนู
    // admin ครบบน desktop ตอนนี้ดึงสิทธิ์จริงจาก AuthState ผ่าน MenuAccess
    // ซึ่งใช้กติกาชุดเดียวกับหน้า 'การตั้งค่าและการจัดการ' บนมือถือ
    final access = MenuAccess.of(context);

    return SizedBox(

      width: 300,
      child: Scaffold(
        backgroundColor: AppColors.sideBarColor,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.sideBarColor,


          // 🔹 HEADER LOGO
          title: Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              'assets/images/engineering_logo.svg',
              height: 50,
            ),
          ),

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.lightTextColor,
            ),
          ),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,

          children: [
            const SizedBox(height: 15),
            SideBarButton(currentPath: currentPath, path: '/check-in', pageName: 'ลงชื่อเข้า-ออกงาน', pageIcon: 'icon_checkin.svg'),
            // 🚩 (2026-08-24) path พวกนี้เดิมชี้ไปหน้าที่ไม่มีจริงใน routes.dart
            // ('/time-request', '/leave') กดแล้วไม่ไปไหน — แก้ให้ตรงของจริงแล้ว
            SideBarButton(currentPath: currentPath, path: '/attendance-request', pageName: 'ขออนุมัติเวลาเข้า-ออกงาน', pageIcon: 'icon_time_request.svg'),
            SideBarButton(currentPath: currentPath, path: '/leave-request', pageName: 'การลางาน', pageIcon: 'icon_leave.svg'),
            SideBarButton(currentPath: currentPath, path: '/statistic', pageName: 'สถิติ', pageIcon: 'icon_statistic.svg'),
            const SizedBox(height: 10),
            Divider(
              height: 1,        // space the divider takes vertically
              thickness: 1,     // actual line thickness
              color: AppColors.lightTextColor,
            ),
            const SizedBox(height: 10),
            SideBarButton(currentPath: currentPath, path: '/settings/attendance-history', pageName: 'บันทึกการเข้างาน', pageIcon: 'icon_attendance_history.svg'),
            // 🚩 ตัด 'บันทึกการลางาน' (/leave-history) และ 'บันทึกคำขออนุมัติเวลางาน'
            // (/time-request-history) ออก — ไม่มีหน้าพวกนี้ใน routes.dart และไม่จำเป็น
            // เพราะประวัติอยู่ในหน้า 'การลางาน' / 'ขออนุมัติเวลา' อยู่แล้ว (ส่วน "รายการล่าสุด")
            if (access.hasApprovalGroup) ..._group([
              if (access.canApprove)
                SideBarButton(currentPath: currentPath, path: '/settings/approval', pageName: 'อนุมัติคำขอ', pageIcon: 'icon_approval.svg'),
              // 🚩 ตัด 'บันทึกการอนุมัติคำขอ' (/approval-history) ออก — ไม่มีหน้านี้จริง
              // ประวัติการอนุมัติอยู่ในหน้า 'อนุมัติคำขอ' อยู่แล้ว (ส่วน "รายการล่าสุด")
              if (access.canViewPersonnel)
                SideBarButton(currentPath: currentPath, path: '/settings/personnel-info', pageName: 'ข้อมูลบุคลากรในองค์กร', pageIcon: 'icon_personnel_info.svg'),
            ]),
            if (access.canManageUsers) ..._group([
              SideBarButton(currentPath: currentPath, path: '/settings/user-management', pageName: 'จัดการผู้ใช้งานระบบ', pageIcon: 'icon_user_management.svg'),
              SideBarButton(currentPath: currentPath, path: '/settings/role-management', pageName: 'จัดการตำแหน่ง', pageIcon: 'icon_role_management.svg'),
            ]),
            if (access.canConfigSystem) ..._group([
              SideBarButton(currentPath: currentPath, path: '/settings/budget-year', pageName: 'ตั้งค่าปีงบประมาณ', pageIcon: 'icon_setting.svg'),
              SideBarButton(currentPath: currentPath, path: '/settings/config-attendance', pageName: 'การลงชื่อเข้า-ออกงาน', pageIcon: 'icon_setting.svg'),
              SideBarButton(currentPath: currentPath, path: '/settings/config-attendance-request', pageName: 'คำขออนุมัติเวลางาน', pageIcon: 'icon_setting.svg'),
              SideBarButton(currentPath: currentPath, path: '/settings/config-leave-type', pageName: 'ประเภทการลางาน', pageIcon: 'icon_setting.svg'),
            ]),
          ],
        ),
        bottomNavigationBar: const _SideBarProfile(),
      ),
    );
  }
}

/// ท้าย sidebar — โปรไฟล์ + ทางเข้าหน้าตั้งค่า + ออกจากระบบ
///
/// 🚩 (2026-08-24) เดิมตรงนี้เป็น placeholder `Text('PROFILE HERE')` สีเหลือง
/// ผลคือบน desktop เข้าโปรไฟล์ / ลายเซ็น / ออกจากระบบไม่ได้เลย เพราะของพวกนี้
/// อยู่ในหน้า '/settings' ซึ่งมือถือเข้าผ่านปุ่ม hamburger บน mainHeader
/// แต่ปุ่มนั้นขึ้นเฉพาะ `Responsive.isMobile` -> desktop ไม่มีทางเข้าถึงเลย
class _SideBarProfile extends StatelessWidget {
  const _SideBarProfile();

  void _confirmLogout(BuildContext context) {
    final authState = context.read<AuthState>();

    FloatingPopup(
      title: 'ออกจากระบบ',
      description: 'คุณยืนยันที่จะออกจากระบบหรือไม่?',
      buttons: (parent, context) => [
        FloatingPopupButton(
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          text: 'ยกเลิก',
        ),
        FloatingPopupButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await authState.logout();
          },
          foregroundColor: Colors.red,
          text: 'ยืนยัน',
        ),
      ],
    ).showPopup(context);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final profile = authState.profile;

    final name = profile?.thName.trim().isNotEmpty == true
        ? profile!.thName
        : (authState.user?.name ?? '');
    final avatarUrl = profile?.avatarUrl.isNotEmpty == true
        ? profile!.avatarUrl
        : (authState.user?.avatarUrl ?? '');
    final role = profile?.roles.isNotEmpty == true ? profile!.roles.first : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sideBarColor,
        border: Border(top: BorderSide(color: AppColors.lightTextColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => context.go('/profile'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.barHighlightColor,
                        backgroundImage: avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
                        child: avatarUrl.isEmpty
                            ? Icon(Icons.person, color: AppColors.subTitleColor)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.titleColor,
                              ),
                            ),
                            if (role != null)
                              Text(
                                role.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.subTitleColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ทางเข้าหน้า 'การตั้งค่าและการจัดการ' — ลายเซ็นกับเมนูอื่นอยู่ในนั้น
            IconButton(
              tooltip: 'การตั้งค่าและการจัดการ',
              onPressed: () => context.go('/settings'),
              icon: Icon(Icons.settings_outlined, color: AppColors.subTitleColor),
            ),
            IconButton(
              tooltip: 'ออกจากระบบ',
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout, color: Colors.red),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

/// เส้นคั่น + ระยะห่างหน้ากลุ่มเมนู — ถ้ากลุ่มไหนไม่มีปุ่มเหลือเลย (สิทธิ์ไม่ถึง)
/// จะไม่คืนอะไรออกมา กันเส้นคั่นซ้อนกันลอยๆ
List<Widget> _group(List<Widget> items) {
  if (items.isEmpty) return const [];
  return [
    const SizedBox(height: 10),
    Divider(
      height: 1,
      thickness: 1,
      color: AppColors.lightTextColor,
    ),
    const SizedBox(height: 10),
    ...items,
  ];
}

class SideBarButton extends StatelessWidget {

  final String path;
  final String pageName;
  final String pageIcon;
  final String currentPath;

  const SideBarButton({super.key, required this.currentPath, required this.path, required this.pageName, required this.pageIcon});

  void _onNavigate(BuildContext context, String path) {
    final guard = context.read<NavigationGuard>();
    if (guard.isDirty) {
      AdminConfigUtils.showSaveConfirmation(
        context: context,
        onSave: () async {
          final res = await guard.onSave!();
          guard.reset();
          return res;
        },
        onDiscard: () {
          guard.reset();
          context.go(path);
        },
        onNavigateBack: () {
          context.go(path);
        },
      );
    } else {
      context.go(path);
    }
  }

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(

        onPressed: () {
          _onNavigate(context, path);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: currentPath == path ? AppColors.barColor : AppColors.sideBarColor,
          foregroundColor: currentPath == path ? AppColors.titleColor : AppColors.subTitleColor,
          padding: EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          elevation: 0,
        ),
        // width: double.infinity,
        // height: 60,
        child: Row(
          children: [
            SizedBox(width: 5),
            SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                // 🚩 (2026-08-24) เดิมเป็น 'assets/images/' เฉยๆ ไม่ได้ต่อชื่อไฟล์
                // pageIcon ที่ส่งเข้ามาทุกปุ่มเลยไม่เคยถูกใช้ -> โหลด asset ไม่ได้
                // ยิง "Unable to load asset" รัวทุกเฟรมบน iPad/desktop
                'assets/images/$pageIcon',
                colorFilter: ColorFilter.mode(currentPath == path ? AppColors.titleColor : AppColors.subTitleColor, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: 10),
            Text(
                pageName,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal
                )
            )
          ],
        )
    );
  }

}