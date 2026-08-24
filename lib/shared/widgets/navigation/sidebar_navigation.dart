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

/// ความกว้าง sidebar ตอนกางและตอนหด
const double _sideBarWidth = 300;
const double _sideBarCollapsedWidth = 76;

/// สถานะ "หด/กาง" ของ sidebar — ประกาศเป็น InheritedWidget เพื่อให้ปุ่มเมนู
/// และแถบโปรไฟล์ที่อยู่ลึกลงไปอ่านได้เอง โดยไม่ต้องส่งผ่าน constructor ทุกชั้น
class _SideBarCollapsed extends InheritedWidget {
  final bool collapsed;

  const _SideBarCollapsed({required this.collapsed, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SideBarCollapsed>()?.collapsed ?? false;

  @override
  bool updateShouldNotify(_SideBarCollapsed oldWidget) => collapsed != oldWidget.collapsed;
}

class SideBarNavigation extends StatefulWidget {

  final String currentPath;

  const SideBarNavigation({super.key, required this.currentPath});

  @override
  State<SideBarNavigation> createState() => _SideBarNavigationState();
}

class _SideBarNavigationState extends State<SideBarNavigation> {

  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {

    final currentPath = widget.currentPath;

    // 🚩 (2026-08-24) เดิม hardcode `int permissionLevel = 3` = ทุกคนเห็นเมนู
    // admin ครบบน desktop ตอนนี้ดึงสิทธิ์จริงจาก AuthState ผ่าน MenuAccess
    // ซึ่งใช้กติกาชุดเดียวกับหน้า 'การตั้งค่าและการจัดการ' บนมือถือ
    final access = MenuAccess.of(context);

    // 🚩 (2026-08-24) เดิมโครงตรงนี้เป็น Scaffold ซ้อน โดยเอาแถบโปรไฟล์ไปใส่ช่อง
    // `bottomNavigationBar` ผลคือช่องนั้นกินความสูงทั้งคอลัมน์ (เห็นได้จากแถบ
    // โปรไฟล์ไปอยู่กึ่งกลางแนวตั้ง) แล้ว body ที่เป็นรายการเมนูเหลือความสูง 0
    // = sidebar โล่ง เห็นแต่โปรไฟล์
    //
    // ตอนนี้จัดเป็น Column ตรงๆ: โลโก้ / รายการเมนูที่ Expanded / แถบโปรไฟล์
    // ซึ่งกำหนดความสูงได้ชัดเจนโดยไม่ต้องพึ่งพฤติกรรมของช่องใน Scaffold
    final targetWidth = _collapsed ? _sideBarCollapsedWidth : _sideBarWidth;

    return _SideBarCollapsed(
      collapsed: _collapsed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: targetWidth,
        child: Material(
        color: AppColors.sideBarColor,
        clipBehavior: Clip.hardEdge,
        // 🚩 ระหว่างที่ความกว้างไล่จาก 300 ลง 76 ลูกๆ จะถูกบีบตามทุกเฟรม
        // ทำให้ Row ทั้งหัวโลโก้และปุ่มเมนู overflow รัวๆ (เจอบน iPad จริง)
        // OverflowBox บังคับให้เนื้อหาวางที่ "ความกว้างปลายทาง" เสมอ
        // แล้วปล่อยให้ clipBehavior ข้างบนตัดส่วนเกินระหว่างทางแทน
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: targetWidth,
          maxWidth: targetWidth,
          child: Column(
          children: [
            _SideBarLogo(
              collapsed: _collapsed,
              onToggle: () => setState(() => _collapsed = !_collapsed),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
            const SizedBox(height: 15),
            SideBarButton(currentPath: currentPath, path: '/check-in'),
            // 🚩 (2026-08-24) path พวกนี้เดิมชี้ไปหน้าที่ไม่มีจริงใน routes.dart
            // ('/time-request', '/leave') กดแล้วไม่ไปไหน — แก้ให้ตรงของจริงแล้ว
            SideBarButton(currentPath: currentPath, path: '/attendance-request'),
            SideBarButton(currentPath: currentPath, path: '/leave-request'),
            SideBarButton(currentPath: currentPath, path: '/statistic'),
            const SizedBox(height: 10),
            Divider(
              height: 1,        // space the divider takes vertically
              thickness: 1,     // actual line thickness
              color: AppColors.lightTextColor,
            ),
            const SizedBox(height: 10),
            SideBarButton(currentPath: currentPath, path: '/attendance-history'),
            // 🚩 ตัด 'บันทึกการลางาน' (/leave-history) และ 'บันทึกคำขออนุมัติเวลางาน'
            // (/time-request-history) ออก — ไม่มีหน้าพวกนี้ใน routes.dart และไม่จำเป็น
            // เพราะประวัติอยู่ในหน้า 'การลางาน' / 'ขออนุมัติเวลา' อยู่แล้ว (ส่วน "รายการล่าสุด")
            if (access.hasApprovalGroup) ..._group([
              if (access.canApprove)
                SideBarButton(currentPath: currentPath, path: '/approval'),
              // 🚩 ตัด 'บันทึกการอนุมัติคำขอ' (/approval-history) ออก — ไม่มีหน้านี้จริง
              // ประวัติการอนุมัติอยู่ในหน้า 'อนุมัติคำขอ' อยู่แล้ว (ส่วน "รายการล่าสุด")
              if (access.canViewPersonnel)
                SideBarButton(currentPath: currentPath, path: '/personnel-info'),
            ]),
            // 🚩 (2026-08-24) ตัด 6 รายการออกจาก sidebar: จัดการผู้ใช้งานระบบ,
            // จัดการตำแหน่ง และ config อีก 4 ตัว — ไปอยู่หลังไอคอนเฟือง (/settings)
            // แทน เพราะเป็นของที่ตั้งครั้งเดียวแล้วแทบไม่แตะอีก ไม่ใช่งานประจำวัน
            // เมนูข้างจึงเหลือแต่สิ่งที่ใช้จริงทุกวัน (จาก 13 เหลือ 7)
            //
            // สิทธิ์ไม่หายไปไหน — `setting_page.dart` กัน canManageUsers /
            // canConfigSystem ด้วย MenuAccess ชุดเดียวกันอยู่แล้ว
                ],
              ),
            ),
            const _SideBarProfile(),
          ],
        ),
        ),
      ),
    ),
    );
  }
}

/// โลโก้หัว sidebar + ปุ่มพับ/กาง
/// เดิมเป็น AppBar ของ Scaffold ซ้อน (toolbarHeight 90 + เส้นคั่น)
class _SideBarLogo extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;

  const _SideBarLogo({required this.collapsed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 90,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.lightTextColor)),
        ),
        child: Row(
          children: [
            if (!collapsed)
              Expanded(
                child: SvgPicture.asset(
                  'assets/images/engineering_logo.svg',
                  height: 50,
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.contain,
                ),
              ),
            IconButton(
              tooltip: collapsed ? 'กางเมนู' : 'พับเมนู',
              onPressed: onToggle,
              icon: Icon(
                collapsed ? Icons.menu : Icons.menu_open,
                color: AppColors.subTitleColor,
              ),
            ),
          ],
        ),
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
    final collapsed = _SideBarCollapsed.of(context);

    final avatar = CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.barHighlightColor,
      backgroundImage: avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
      child: avatarUrl.isEmpty ? Icon(Icons.person, color: AppColors.subTitleColor) : null,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sideBarColor,
        border: Border(top: BorderSide(color: AppColors.lightTextColor)),
      ),
      child: SafeArea(
        top: false,
        // ตอนหดไม่มีที่พอให้เรียงแนวนอน จึงซ้อนแนวตั้งแทนและตัดชื่อ/ตำแหน่งออก
        child: collapsed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Tooltip(
                    message: name,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.go('/profile'),
                      child: avatar,
                    ),
                  ),
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
                ],
              )
            : Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => context.go('/profile'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: Row(
                    children: [
                      avatar,
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
  final String currentPath;

  const SideBarButton({super.key, required this.currentPath, required this.path});

  /// ชื่อกับไอคอนมาจากตารางกลางใน `menu_access.dart` — ไม่เก็บซ้ำในนี้
  /// เพื่อไม่ให้เกิดเคส "แก้ที่นึง อีกที่ไม่ตาม" แบบลิงก์ตาย 10 จุด (ข้อ 1.2)
  SidebarDestination get _dest => sidebarDestinationByPath[path]!;

  String get pageName => _dest.name;

  String get pageIcon => _dest.icon;

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

    final selected = currentPath == path;
    final collapsed = _SideBarCollapsed.of(context);
    final foreground = selected ? AppColors.titleColor : AppColors.subTitleColor;

    final icon = SizedBox(
      width: 20,
      height: 20,
      child: SvgPicture.asset(
        // 🚩 (2026-08-24) เดิมเป็น 'assets/images/' เฉยๆ ไม่ได้ต่อชื่อไฟล์
        // pageIcon ที่ส่งเข้ามาทุกปุ่มเลยไม่เคยถูกใช้ -> โหลด asset ไม่ได้
        // ยิง "Unable to load asset" รัวทุกเฟรมบน iPad/desktop
        'assets/images/$pageIcon',
        colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
      ),
    );

    final button = ElevatedButton(

        onPressed: () {
          _onNavigate(context, path);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? AppColors.barColor : AppColors.sideBarColor,
          foregroundColor: foreground,
          padding: collapsed
              ? const EdgeInsets.symmetric(vertical: 20)
              : const EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          elevation: 0,
        ),
        // ตอนหด เหลือแค่ไอคอนกลางปุ่ม ชื่อเมนูย้ายไปอยู่ใน tooltip แทน
        child: collapsed
            ? Center(child: icon)
            : Row(
          children: [
            SizedBox(width: 5),
            icon,
            SizedBox(width: 10),
            // กันชื่อเมนูยาวล้นตอนความกว้างกำลังไล่ย่อ
            Expanded(
              child: Text(
                  pageName,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  // 🚩 (2026-08-24) เดิม 20 ซึ่งใหญ่กว่าตัวหนังสือที่ใช้ทั้งแอป
                  // (หัวข้อ 17 / เนื้อหา 15) ทำให้เมนูดูโตผิดที่ผิดทาง
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  )
              ),
            )
          ],
        )
    );

    return collapsed ? Tooltip(message: pageName, child: button) : button;
  }

}