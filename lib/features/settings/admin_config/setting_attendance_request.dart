import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/toggle_switch.dart';
import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

class SettingAttendanceRequest extends StatelessWidget {
  const SettingAttendanceRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(context, title: 'ตั้งค่าการขออนุมัติเวลา'),
      content: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
                    children: [
                      IconTextValueButton(
                        icon: 'icon_approval_step.svg',
                        label: 'จำนวนขั้นการอนุมัติ',
                        value: '2 ขั้น',
                        onPressed: () {
                          /// TODO: implement somethings
                        },
                      )
                    ],
                  ),
                  SeparatorCard(
                    separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                    children: [
                      ToggleSwitch(
                        icon: 'icon_request_signature.svg',
                        label: 'ส่งคำขอต้องการลายเซ็น',
                        onChanged: (value) {
                          /// TODO: implement somethings
                        },
                      ),
                      ToggleSwitch(
                        icon: 'icon_request_signature.svg',
                        label: 'อนุมัติต้องการลายเซ็น',
                        onChanged: (value) {
                          /// TODO: implement somethings
                        },
                      ),
                      ToggleSwitch(
                        icon: 'icon_specify_approval.svg',
                        label: 'ระบุเหตุผลการอนุมัติ',
                        onChanged: (value) {
                          /// TODO: implement somethings
                        },
                      )
                    ],
                  ),
                  SeparatorCard(
                    separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                    children: [
                      ToggleSwitch(
                        icon: 'icon_specify_approval.svg',
                        label: 'การระบุหมายเหตุ',
                        subSwitch: true,
                        onChanged: (value) {
                          /// TODO: implement somethings
                        },
                        subLabel: 'จำเป็นต้องระบุ',
                        onSubChanged: (value) {

                        },
                      ),
                    ],
                  ),
                  SeparatorCard(
                    children: [
                      ToggleSwitch(
                        icon: 'icon_attach_evidence.svg',
                        label: 'แนบไฟล์หลักฐาน',
                        subSwitch: true,
                        onChanged: (value) {
                          /// TODO: implement somethings
                        },
                        subLabel: 'จำเป็นต้องแนบ',
                        onSubChanged: (value) {
                          /// TODO: implement somethings
                        },
                      ),
                    ],
                  )
                ]
              )
            )
          )
        )
      )
    );
  }
}