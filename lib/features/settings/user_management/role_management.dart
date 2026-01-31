import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/utils/app_button.dart';
import '../../../shared/widgets/utils/app_button_list_card.dart';
import '../../../shared/widgets/utils/icon_text_button.dart';
import '../../../shared/widgets/utils/separator_card.dart';

class RoleManagement extends StatelessWidget {
  const RoleManagement({super.key});

  get countMainRole => null;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dataTest = [
      {
        'icon': 'icon_admin.svg',
        'title': 'ผู้ดูแล',
        'subTitle': 'สมาชิก 1 คน',
        'iconColor': null,
        'arrow': true,
        'timeStamp': null,
        'notation': null,
      },
      {
        'icon': 'icon_sick_cancel.svg',
        'title': 'คำขอลางานถูกปฏิเสธ',
        'subTitle':
        'คำขอลาป่วยวันที่ 24 ก.ย. 2568 ถึงวันที่ 30 ก.ย. 2568 ถูกปฎิเสธโดย ผศ.ดร.สมชาย ใจดี',
        'iconColor': null,
        'arrow': true,
        'timeStamp': 'มกราคม 13',
        'notation': 'หมายเลขคำขอ: LEV000000065013',
      },{
        'icon': 'role_management.svg',
        'title': 'ผู้ดูแล',
        'subTitle': 'สมาชิก 1 คน',
        'iconColor': Colors.blue,
        'arrow': true,
        'timeStamp': null,
        'notation': null,
      },
      {
        'icon': 'icon_cancel.svg',
        'title': '17/09/2020 - 18/03/2021',
        'subTitle': 'หมายเลขคำขอ: LEV000000065012',
        'iconColor': Color(0xFFE7000B),
        'arrow': true,
        'timeStamp': null,
        'notation': null,
      }
    ];

    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'จัดการตำแหน่ง'
      ),
      content: SafeArea(
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
                    IconTextButton(
                      icon: 'icon_create_role.svg',
                      label: 'สร้างตำแหน่งใหม่...',
                      color: AppColors.primaryColor,
                      onPressed: () {
                        /// ไปหน้าอื่น
                      },
                    )
                  ],
                ),
                TextField(
                  // controller: _controller,
                  // onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(
                        color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(
                        color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                        width: 1,
                      ),
                    ),
                    hint: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        SvgPicture.asset(
                          'assets/images/search.svg',
                          width: 15,
                          height: 15,
                        ),
                        Text('ค้นหาตำแหน่ง...',
                          style: TextStyle(
                              color: Color(0xFF7D7D7D),
                              fontSize: 15
                          )
                        )
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE3E3E3),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 15),
                    width: double.infinity,
                    child: Column(
                      spacing: 13,
                      children: [
                        /// ตำแหน่งหลัก
                        Column(
                          spacing: 5,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 6,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/role_management.svg',
                                  height: 15,
                                  width: 15,
                                ),
                                Text('ตำแหน่งหนัก ($countMainRole)')
                              ],
                            ),
                            AppButtonListCard(
                                items: dataTest,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}