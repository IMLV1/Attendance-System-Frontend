import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                        IconTextButton(icon: 'icon_personnel_info.svg', label: 'ข้อมูลบุคลากรในองค์กร')
                      ]
                  ),
                  SeparatorCard(
                      separatorPadding: EdgeInsets.only(left: 45, right: 15),
                      children: [
                        IconTextButton(icon: 'icon_user_management.svg', label: 'จัดการผู้ใช้งานระบบ'),
                        IconTextButton(icon: 'icon_role_management.svg', label: 'จัดการตำแหน่ง'),
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
                ]
              )
            )
          )
        )
      )
    );
  }
}