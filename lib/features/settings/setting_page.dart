import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_state.dart';
import '../../shared/widgets/utils/toggle_switch.dart';

class SettingPage extends StatelessWidget {

  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return AppScaffold(
      header: Header.subHeader(context,
        title: 'การตั้งค่าและการจัดการ'
      ),
      content: SafeArea(
        child: SingleChildScrollView(
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
                      IconTextButton(icon: 'icon_attendance_history.svg', label: 'บันทึกการเข้างาน'),
                      IconTextButton(icon: 'icon_leave_history.svg', label: 'บันทึกการลางาน'),
                      IconTextButton(icon: 'icon_attendance_request_history.svg', label: 'บันทึกคำขออนุมัติเวลางาน')
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
                        // IconTextButton(icon: 'icon_personnel_info.svg', label: 'ข้อมูลบุคลากรในองค์กร'),
                      ]
                  ),
                  SeparatorCard(
                      separatorPadding: EdgeInsets.only(left: 45, right: 15),
                      children: [
                        IconTextButton(onPressed: () {
                          context.push('/settings/user-management');
                        }, icon: 'icon_user_management.svg', label: 'จัดการผู้ใช้งานระบบ'),
                        IconTextButton(onPressed: () {
                          context.push('/settings/role-management');
                        },icon: 'icon_role_management.svg', label: 'จัดการตำแหน่ง'),
                      ]
                  ),
                  SeparatorCard(
                      separatorPadding: EdgeInsets.only(left: 45, right: 15),
                      children: [
                        IconTextButton(onPressed: () {
                          context.push('/settings/budget-year');
                        }, icon: 'icon_setting.svg', label: 'ตั้งค่าปีงบประมาณ'),
                        IconTextButton(onPressed: () {
                          context.push('/settings/config-attendance');
                        }, icon: 'icon_setting.svg', label: 'การลงชื่อเข้า-ออกงาน'),
                        IconTextButton(onPressed: () {
                          context.push('/settings/config-attendance-request');
                        }, icon: 'icon_setting.svg', label: 'คำขออนุมัติเวลางาน'),
                        IconTextButton(onPressed: () {
                          context.push('/settings/config-leave-type');
                        }, icon: 'icon_setting.svg', label: 'ประเภทการลางาน'),
                      ]
                  ),
                  SeparatorCard(
                      separatorPadding: EdgeInsets.only(left: 45, right: 15),
                      children: [
                        IconTextButton(arrow: false, onPressed: () async {
                          await context.read<AuthState>().logout();
                        }, icon: 'icon_signature.svg', label: 'แก้ไขลายเซ็น', color: Colors.black),
                        // TODO: change Color red in label text and change Icon
                      ]
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