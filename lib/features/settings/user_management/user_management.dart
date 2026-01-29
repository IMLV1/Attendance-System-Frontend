import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserManagement extends StatelessWidget {
  const UserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(context, title: 'จัดการผู้ใช้งานระบบ'),
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
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: AppColors.shadowColor,
                  ),
                  padding: EdgeInsets.only(top: 12, left: 10, right: 10, bottom: 8),

                  width: double.infinity,
                  child: Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: AppColors.titleColor,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          height: 35,
                          width: 35,
                          padding: EdgeInsets.all(4),
                          child: SvgPicture.asset(
                            'assets/images/role_management.svg',
                          )
                      ),

                      Expanded(child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 5,
                            children: [
                              Text(
                                'จัดการตำแหน่งผู้ใช้งาน',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                              Divider(height: 0),
                              Text(
                                  'กำหนดและจัดการตำแหน่ง เพื่อควบคุมการเข้าถึง และกำหนดขอบเขตความรับผิดชอบของบทบาท',
                                  style: TextStyle(
                                      color: AppColors.lightTextColor,
                                      fontSize: 12,
                                      height: 1.3
                                  )
                              )
                            ],
                          ),
                          Container(
                              width: double.infinity,
                              alignment: Alignment.centerRight,
                              child: Text(
                                'ไปจัดการ',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 14
                                ),
                              )
                          )
                        ],
                      )),
                    ],
                  )
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    spacing: 6,
                    children: [
                      SvgPicture.asset(
                        'assets/images/users.svg',
                      ),
                      Text('ผู้ใช้งาน')
                    ],
                  )
                ),
                TextField(

                  onChanged: (input) {},
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),

                    ),
                    hintText: 'Enter a search term',
                  ),
                )
              ]
            )
          )
        )
      ),
    );
  }

}