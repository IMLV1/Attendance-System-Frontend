import 'dart:typed_data';

import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/core/utils/menu_access.dart';
import 'package:attendance_system/services/signature/signature_service.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/floating_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/service_signature_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_state.dart';

class SettingPage extends StatelessWidget {

  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Uint8List? signature;

    AuthState authState = context.read<AuthState>();
    // 🚩 (2026-08-24) เดิมเช็ค role เป็น list inline ตรงนี้ทีละจุด ซึ่งเป็น
    // ที่เดียวในโปรเจกต์ที่มีกติกาถูกต้อง — sidebar ของ desktop ไม่ได้ใช้ตามนี้
    // ตอนนี้ย้ายไป MenuAccess เพื่อให้ทั้งสองเมนูอ้างของชุดเดียวกัน
    final access = MenuAccess.of(context);

    // 🚩 (Phase 3) บนจอที่มี sidebar รายการที่ซ้ำกับ sidebar ไม่ต้องโชว์ซ้ำ
    // อีกหน้าเต็มๆ เพราะไม่ได้ช่วยอะไร แถมทำให้ผู้ใช้สงสัยว่าสองเมนูนี้ต่างกัน
    // ตรงไหน (PHASE3_PAGE_DESIGN.md หัวข้อ /settings) จอที่ใช้ bottom nav
    // ยังต้องมีครบเหมือนเดิม เพราะที่นั่นหน้านี้คือทางเดียวที่จะเข้าถึงได้
    //
    // 🚩 (2026-08-25) รอบแรกเขียนเป็น `onlyUniqueItems = showSidebar(context)`
    // แล้วเอาไปซ่อน "ยกชุด" ทุกกลุ่ม โดยเข้าใจผิดว่าทุกรายการในหน้านี้อยู่ใน
    // sidebar หมด — ความจริง sidebar มีแค่ 9 ปลายทางและไม่มีหน้า admin เลย
    // ผลคือบน iPad แนวนอน/desktop แอดมินเข้า "จัดการผู้ใช้งานระบบ",
    // "จัดการตำแหน่ง" และหน้าตั้งค่าระบบทั้ง 4 หน้าไม่ได้เลยสักทาง
    // ต้องเทียบราย path กับ sidebar จริง ไม่ใช่เหมาว่ามี sidebar แล้วซ่อนหมด
    bool duplicatesSidebar(String path) =>
        Responsive.showSidebar(context) &&
        sidebarDestinationByPath.containsKey(path);

    // สองรายการนี้อยู่ใน sidebar ทั้งคู่ ต้องเช็คแยกทีละอัน แล้วค่อยตัดสินว่า
    // ทั้งการ์ดยังต้องมีอยู่ไหม ไม่งั้นเหลือการ์ดเปล่าคาหน้าจอ
    final showApproval = access.canApprove && !duplicatesSidebar('/approval');
    final showPersonnel =
        access.canViewPersonnel && !duplicatesSidebar('/personnel-info');

    return AppScaffold(
      header: Header.subHeader(context,
        title: 'การตั้งค่าและการจัดการ'
      ),
      content: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),

          child: Container(
            color: AppColors.backgroundColor,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 13,
                children: [
                  if (!duplicatesSidebar('/attendance-history'))
                    SeparatorCard(
                      separatorPadding: EdgeInsets.only(left: 45, right: 15),
                      children: [
                        IconTextButton(onPressed: () {
                          context.pushNamed(RouteNames.attendanceHistory);
                        }, icon: 'icon_attendance_history.svg', label: 'บันทึกการเข้างาน'),
                      ]
                    ),
                  if (showApproval || showPersonnel)
                    SeparatorCard(
                      separatorPadding: EdgeInsets.only(left: 45, right: 15),
                      children: [
                        if (showApproval)
                          IconTextButton(onPressed: () {
                            context.pushNamed(RouteNames.approval);
                          }, icon: 'icon_approval.svg', label: 'อนุมัติคำขอ'),
                        if (showPersonnel)
                          IconTextButton(onPressed: () {
                            context.pushNamed(RouteNames.personnelInfo);
                          }, icon: 'icon_personnel_info.svg', label: 'ข้อมูลบุคลากรในองค์กร'),
                      ]
                    ),
                  if (access.canManageUsers)
                    SeparatorCard(
                      separatorPadding: EdgeInsets.only(left: 45, right: 15),
                      children: [
                        IconTextButton(onPressed: () {
                          context.pushNamed(RouteNames.userManagement);
                        }, icon: 'icon_user_management.svg', label: 'จัดการผู้ใช้งานระบบ'),
                        IconTextButton(onPressed: () {
                          context.pushNamed(RouteNames.roleManagement);
                        },icon: 'icon_role_management.svg', label: 'จัดการตำแหน่ง'),
                      ]
                  ),
                  if (access.canConfigSystem)
                    SeparatorCard(
                      separatorPadding: EdgeInsets.only(left: 45, right: 15),
                      children: [
                        IconTextButton(onPressed: () {
                          context.pushNamed(RouteNames.settingBudgetYear);
                        }, icon: 'icon_setting.svg', label: 'ตั้งค่าปีงบประมาณ'),
                        IconTextButton(onPressed: () {
                          context.pushNamed(RouteNames.settingAttendanceTime);
                        }, icon: 'icon_setting.svg', label: 'การลงชื่อเข้า-ออกงาน'),
                        IconTextButton(onPressed: () {
                          context.pushNamed(RouteNames.settingAttendanceRequest);
                        }, icon: 'icon_setting.svg', label: 'คำขออนุมัติเวลางาน'),
                        IconTextButton(onPressed: () {
                          context.pushNamed(RouteNames.settingLeaveType);
                        }, icon: 'icon_setting.svg', label: 'ประเภทการลางาน'),
                      ]
                    ),

                  StatefulBuilder(
                    builder: (context, setState) {

                      return SeparatorCard(
                        separatorPadding: EdgeInsets.only(left: 45, right: 15),
                        children: [
                          ServiceUpdater(
                            request: () => SignatureService().get(),
                            onSuccessResponse: (pngBytes) {

                              setState(() {
                                signature = pngBytes;
                              });
                            },
                            fetchOnInit: true,
                            builder: (trigger, state, errorMessage) {

                              return IconTextButton(icon: 'icon_signature.svg', onPressed: () async {
                                ServiceSignaturePopup(
                                  request: (Uint8List? pngByte) async => (pngByte != null) ? SignatureService().update(pngByte!) : SignatureService().clear(),
                                  title: 'ลายเซ็น',
                                  buttonLabel: 'บันทึก',
                                  importSignature: false,
                                  onSuccess: (Uint8List? pngBytes) {
                                    setState(() {
                                      signature = pngBytes;
                                    });
                                  },
                                  current: signature,
                                  infoWidget: Row(
                                    spacing: 5,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/iicon.svg',
                                        width: 15,
                                        height: 15,
                                      ),
                                      Expanded(
                                        child: Text('โปรดทราบว่า ลายเซ็นดิจิทัลนี้จะถูกจัดเก็บไว้ในระบบ เพื่อให้ผู้ใช้สามารถเรียกใช้งานได้อย่างสะดวกในภายหลัง')
                                      )
                                    ],
                                  ),
                                ).showPopup(context);
                              }, label: signature == null ? 'เพิ่มลายเซ็น' : 'แก้ไขลายเซ็น', color: signature == null ? AppColors.primaryColor : Colors.black);
                            },
                          )
                        ]
                      );
                    }
                  ),
                  SeparatorCard(
                    separatorPadding: EdgeInsets.only(left: 45, right: 15),
                    children: [
                      IconTextButton(arrow: false, onPressed: () async {

                        FloatingPopup(

                          title: 'ออกจากระบบ',
                          description: 'คุณยืนยันที่จะออกจากระบบหรือไม่?',
                          buttons: (parent, context) => [
                            FloatingPopupButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              text: 'ยกเลิก'
                            ),
                            FloatingPopupButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await authState.logout();
                              },
                              foregroundColor: Colors.red,
                              text: 'ยืนยัน'
                            )
                          ]
                        ).showPopup(context);
                      }, icon: 'icon_logout.svg', label: 'ออกจากระบบ', color: Colors.red),
                    ]
                  ),
                ]
              )
            )
          )
        )
      )
    );
  }
}