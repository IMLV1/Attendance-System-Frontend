import 'dart:typed_data';

import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/services/signature/signature_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/service_signature_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:dio/dio.dart';
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
                  SeparatorCard(
                    separatorPadding: EdgeInsets.only(left: 45, right: 15),
                    children: [
                      //(onPressed: () {
                      //                           context.push('/settings/user-management');
                      //                         }
                      IconTextButton(onPressed: () {
                        context.pushNamed(RouteNames.attendanceHistory);
                      }, icon: 'icon_attendance_history.svg', label: 'บันทึกการเข้างาน'),
                    ]
                  ),
                  SeparatorCard(
                      separatorPadding: EdgeInsets.only(left: 45, right: 15),
                      children: [
                        IconTextButton(icon: 'icon_approval.svg', label: 'อนุมัติคำขอ'),
                        IconTextButton(icon: 'icon_approval_history.svg', label: 'บันทึกการอนุมัติคำขอ'),
                        IconTextButton(icon: 'icon_personnel_info.svg', label: 'ข้อมูลบุคลากรในองค์กร'),
                        // ToggleSwitch(
                        //   icon: 'icon_role.svg',
                        //   label: 'แนบเอกสาร',
                        //   subSwitch: true,
                        //   subLabel: 'จำเป็นต้องแนบ',
                        //   onChanged: (val) {
                        //     debugPrint('main: $val');
                        //   },
                        //   onSubChanged: (val) {
                        //     debugPrint('sub: $val');
                        //   },
                        // ),
                        // ToggleSwitch(
                        //   icon: 'icon_role.svg',
                        //   label: 'แนบเอกสาร',
                        //   subSwitch: true,
                        //   subLabel: 'จำเป็นต้องแนบ',
                        //   onChanged: (val) {
                        //     debugPrint('main: $val');
                        //   },
                        //   onSubChanged: (val) {
                        //     debugPrint('sub: $val');
                        //   },
                        // ),
                        //IconTextButton(icon: 'icon_personnel_info.svg', label: 'ข้อมูลบุคลากรในองค์กร'),
                      ]
                  ),
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
                          await context.read<AuthState>().logout();
                        }, icon: 'icon_logout.svg', label: 'ออกจากระบบ', color: Colors.red),
                        // TODO: change Color red in label text and change Icon
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