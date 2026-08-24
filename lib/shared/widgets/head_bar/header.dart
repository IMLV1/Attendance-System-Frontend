import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/core/utils/menu_access.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/services/notification/notification_provider.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Header {

  /// ควรมีปุ่ม back มั้ย
  ///
  /// ถ้าจอนี้มี sidebar และหน้าปัจจุบันเป็นปลายทางของ sidebar แปลว่าผู้ใช้กดมา
  /// ในคลิกเดียว ไม่ได้ถูก push มาจากไหน จึงไม่ควรมีปุ่ม back
  /// (บนมือถือหน้าเดียวกันนี้ถูก push มาจากหน้าตั้งค่าจริงๆ จึงยังต้องมี)
  static bool _showBackButton(BuildContext context) {
    if (!context.canPop()) return false;
    if (!Responsive.showSidebar(context)) return true;
    return !sidebarDestinationByPath.containsKey(GoRouterState.of(context).matchedLocation);
  }

  // 🚩 (2026-08-24) เดิมทั้งสอง header คูณ scaleFactor (1.0 / 1.2 / 1.4) กับความสูง
  // แถบและขนาดไอคอนตามความกว้างจอ ทำให้แถบบน iPad/desktop ใหญ่เกินจริงและไม่ตรงกับ
  // ขนาดตัวหนังสือที่ไม่ได้ถูกคูณตาม — ตกลงกันแล้วว่าใช้ขนาดเดียวทุกจอ

  /// `bottom` — แถบที่ต่อท้ายหัวข้อ เช่นแท็บของหน้าอนุมัติคำขอ
  ///
  /// 🚩 (2026-08-24) ต้องอยู่ใน AppBar ไม่ใช่ในเนื้อหา เพราะ `AppScaffold` จำกัด
  /// ความกว้างเนื้อหาไว้ 1100 แถบที่มีพื้นหลังสีเดียวกับหัวจึงถูกบีบให้แคบกว่าหัว
  /// เกิดเป็นรอยขั้นบันไดบนจอกว้าง (เห็นชัดที่หน้าอนุมัติคำขอ)
  static AppBar subHeader(BuildContext context, {title = 'Default Title', VoidCallback? onBack, PreferredSizeWidget? bottom}) {

    // 🚩 (2026-08-24) บนจอที่มี sidebar หน้าใต้ `/settings` ไม่ใช่ "หน้าลูก" อีกต่อไป
    // มันคือปลายทางที่กดถึงในคลิกเดียว แต่ยังใช้ subHeader ซึ่งมีแค่ชื่อไทยจัดกลาง
    // ไม่มีไอคอน ไม่มีกระดิ่ง — วางข้างหน้าหลักแล้วเหมือนคนละแอป (เจอตอนไล่ดู 0.4)
    //
    // ชื่อ/ไอคอนหยิบจากตารางกลางเดียวกับที่ sidebar ใช้ จึงไม่ต้องแก้ call site
    // ทั้ง 28 จุด และไม่มีข้อมูลซ้ำให้หลุดกัน
    final dest = sidebarDestinationByPath[GoRouterState.of(context).matchedLocation];
    if (dest != null && Responsive.showSidebar(context)) {
      return mainHeader(context, title: dest.name, subTitle: dest.nameEn, iconPath: dest.icon, bottom: bottom);
    }

    return AppBar(
      backgroundColor: AppColors.barColor,
      elevation: 0,
      bottom: bottom,

      leadingWidth: 56,

      toolbarHeight: 48,

      centerTitle: true,

      automaticallyImplyLeading: false,

      // 🚩 (2026-08-24) เดิมถาม Navigator.of(context).canPop() ก่อน แล้วค่อย
      // fallback ไป context.canPop() ของ go_router — ถามคนละระบบกัน
      //
      // ปัญหา: หน้าอย่าง /settings/config-attendance บนมือถือถูก "push" มาจาก
      // หน้าตั้งค่า (มี back ถูกต้อง) แต่บน iPad/desktop กดจาก sidebar ซึ่งใช้
      // context.go() = แทนที่สแตกทั้งหมด -> หน้านั้นกลายเป็น "ปลายทาง" ไม่ใช่
      // sub-page แต่ Navigator ยังตอบว่า canPop ได้ ปุ่ม back เลยโผล่มาทั้งที่
      // ไม่ควรมี และกดแล้วพัง (assert currentConfiguration.isNotEmpty)
      //
      // ตอนนี้ยึด go_router เป็นแหล่งความจริงเดียว:
      //   ถอยได้  -> โชว์ปุ่ม back (เคส push จริง)
      //   ถอยไม่ได้ -> ไม่โชว์ (เคสมาจาก sidebar)
      //
      // 🚩 เพิ่มเงื่อนไขที่สอง (24 ส.ค. หลังเห็นภาพหน้าจอ iPad):
      // หน้าใต้ `/settings` เป็น route ลูก พอ context.go() ไปหา go_router จะสร้าง
      // สแตกทั้งสายให้ (มีหน้าแม่คาอยู่) canPop() เลยตอบ true ทั้งที่กดมาจาก
      // sidebar ตรงๆ — จึงต้องเช็คด้วยว่า path ปัจจุบันเป็น "ปลายทาง" รึเปล่า
      leading: _showBackButton(context)
          ? IconButton(
              // onBack ของหน้าที่ส่งมาเองส่วนใหญ่เรียก maybePop() เพื่อให้
              // PopScope (เตือน "ยังไม่ได้บันทึก") ทำงาน — ต้องคงไว้
              onPressed: onBack ?? () => context.pop(),
              icon: SvgPicture.asset(
                'assets/images/back_button.svg',
                width: 24,
                height: 24,
              ),
            )
          : null,

      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.titleColor,
        ),
      ),
    );
  }

  static AppBar mainHeader(BuildContext context, {title = 'Default Title', String? subTitle, iconPath = 'google_logo.svg', iconColor = Colors.white, PreferredSizeWidget? bottom}) {

    return AppBar(
      backgroundColor: AppColors.barColor,
      elevation: 0,
      bottom: bottom,

      /// ความสูง header
      toolbarHeight: 72,

      automaticallyImplyLeading: false,

      leadingWidth: double.infinity,
      leading: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.barHighlightColor,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/$iconPath',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.titleColor,
                  ),
                ),
                // หน้าใต้ `/settings` ไม่มีชื่ออังกฤษกำกับ — เว้นไว้ ไม่ต้องแต่งขึ้นมาเอง
                if (subTitle != null)
                  Text(
                    subTitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subTitleColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),

      /// RIGHT SIDE (actions)
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final unreadCount = notificationProvider.unreadCount;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.push('/notification');
                        },
                        icon: SvgPicture.asset(
                          'assets/images/notification.svg',
                          width: 26,
                          height: 26,
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 16,
                          child: InkWell(
                            onTap: () {
                              context.push('/notification');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ),
                    ],
                  );
                },
              ),
              // 🚩 (2026-08-24) เดิมเช็ค isMobile (<600) -> iPad แนวตั้ง (834) ไม่ได้
              // ทั้งปุ่มนี้และ sidebar = เข้าหน้า 'การตั้งค่าและการจัดการ' ไม่ได้เลย
              // ตอนนี้ผูกกับ showSidebar: ถ้าไม่มี sidebar ต้องมีปุ่มนี้เสมอ
              // (sidebar มีทางเข้าหน้าตั้งค่าอยู่ที่แถบโปรไฟล์ด้านล่างแล้ว)
              if (!Responsive.showSidebar(context)) IconButton(
                onPressed: () {
                  context.pushNamed(RouteNames.setting);
                },
                icon: SvgPicture.asset(
                  'assets/images/hamburger_menu.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
