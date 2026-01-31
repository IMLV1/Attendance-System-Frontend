import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserManagement extends StatelessWidget {
  const UserManagement({super.key});

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> users = [
      {'id': '1100000000000', 'name-th': 'ศ.ดร.บลาๆๆๆๆๆๆๆๆ นี่คือนามสกุล', 'name-en': 'Prof. Dr. ThisisSurName ThisIsLastName', 'profile': 'https://media.discordapp.net/attachments/1339973422494515212/1466642651330777222/61346471-07C0-4AED-AF16-B46C7876F3D4.jpg?ex=697d7ce8&is=697c2b68&hm=4687fb27b3ca45b7658b67c02eb42410cdc306c96f97887e0f9a66a22f56250e&=&format=webp&width=404&height=718', 'roles': [
        {'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
        {'role-name': 'รองคณบดี', 'role-color': 'FFA51D'},
        {'role-name': 'วิศวกรรมคอมพิวเตอร์', 'role-color': '535353'},
        {'role-name': 'abc', 'role-color': '123456'},
        {'role-name': 'def', 'role-color': '789abc'},
        {'role-name': 'ghi', 'role-color': '00fffd'},
        {'role-name': 'jkl', 'role-color': '00d91a'},

      ]},
      {'id': '1100000000000', 'name-th': 'ศ.ดร.บลาๆๆๆๆๆๆๆๆ นี่คือนามสกุล', 'name-en': 'Prof. Dr. ThisisSurName ThisIsLastName', 'profile': 'https://media.discordapp.net/attachments/1339973422494515212/1466642651330777222/61346471-07C0-4AED-AF16-B46C7876F3D4.jpg?ex=697d7ce8&is=697c2b68&hm=4687fb27b3ca45b7658b67c02eb42410cdc306c96f97887e0f9a66a22f56250e&=&format=webp&width=404&height=718', 'roles': [
        {'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
        {'role-name': 'รองคณบดี', 'role-color': 'FFA51D'},
        {'role-name': 'วิศวกรรมคอมพิวเตอร์', 'role-color': '535353'},
        {'role-name': 'abc', 'role-color': '123456'},
        {'role-name': 'def', 'role-color': '789abc'},
        {'role-name': 'ghi', 'role-color': '00fffd'},
        {'role-name': 'jkl', 'role-color': '00d91a'},

      ]},
      {'id': '1100000000000', 'name-th': 'ศ.ดร.บลาๆๆๆๆๆๆๆๆ นี่คือนามสกุล', 'name-en': 'Prof. Dr. ThisisSurName ThisIsLastName', 'profile': 'https://media.discordapp.net/attachments/1339973422494515212/1466642651330777222/61346471-07C0-4AED-AF16-B46C7876F3D4.jpg?ex=697d7ce8&is=697c2b68&hm=4687fb27b3ca45b7658b67c02eb42410cdc306c96f97887e0f9a66a22f56250e&=&format=webp&width=404&height=718', 'roles': [
        {'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
        {'role-name': 'รองคณบดี', 'role-color': 'FFA51D'},
        {'role-name': 'วิศวกรรมคอมพิวเตอร์', 'role-color': '535353'},
        {'role-name': 'abc', 'role-color': '123456'},
        {'role-name': 'def', 'role-color': '789abc'},
        {'role-name': 'ghi', 'role-color': '00fffd'},
        {'role-name': 'jkl', 'role-color': '00d91a'},

      ]},
      {'id': '1100000000000', 'name-th': 'ศ.ดร.บลาๆๆๆๆๆๆๆๆ นี่คือนามสกุล', 'name-en': 'Prof. Dr. ThisisSurName ThisIsLastName', 'profile': 'https://media.discordapp.net/attachments/1339973422494515212/1466642651330777222/61346471-07C0-4AED-AF16-B46C7876F3D4.jpg?ex=697d7ce8&is=697c2b68&hm=4687fb27b3ca45b7658b67c02eb42410cdc306c96f97887e0f9a66a22f56250e&=&format=webp&width=404&height=718', 'roles': [
        {'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
        {'role-name': 'รองคณบดี', 'role-color': 'FFA51D'},
        {'role-name': 'วิศวกรรมคอมพิวเตอร์', 'role-color': '535353'},
        {'role-name': 'abc', 'role-color': '123456'},
        {'role-name': 'def', 'role-color': '789abc'},
        {'role-name': 'ghi', 'role-color': '00fffd'},
        {'role-name': 'jkl', 'role-color': '00d91a'},

      ]},
      {'id': '1100000000000', 'name-th': 'ศ.ดร.บลาๆๆๆๆๆๆๆๆ นี่คือนามสกุล', 'name-en': 'Prof. Dr. ThisisSurName ThisIsLastName', 'profile': 'https://media.discordapp.net/attachments/1339973422494515212/1466642651330777222/61346471-07C0-4AED-AF16-B46C7876F3D4.jpg?ex=697d7ce8&is=697c2b68&hm=4687fb27b3ca45b7658b67c02eb42410cdc306c96f97887e0f9a66a22f56250e&=&format=webp&width=404&height=718', 'roles': [
        {'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
        {'role-name': 'รองคณบดี', 'role-color': 'FFA51D'},
        {'role-name': 'วิศวกรรมคอมพิวเตอร์', 'role-color': '535353'},
        {'role-name': 'abc', 'role-color': '123456'},
        {'role-name': 'def', 'role-color': '789abc'},
        {'role-name': 'ghi', 'role-color': '00fffd'},
        {'role-name': 'jkl', 'role-color': '00d91a'},

      ]},
      {'id': '1100000000000', 'name-th': 'ศ.ดร.ธีธัช ปิตานุพง', 'name-en': 'Prof. Dr. Teetat Pitanuphong', 'profile': 'https://media.discordapp.net/attachments/1339973422494515212/1466642651330777222/61346471-07C0-4AED-AF16-B46C7876F3D4.jpg?ex=697d7ce8&is=697c2b68&hm=4687fb27b3ca45b7658b67c02eb42410cdc306c96f97887e0f9a66a22f56250e&=&format=webp&width=404&height=718', 'roles': [
        {'role-name': 'วิศวกรรมคอมพิวเตอร์', 'role-color': '535353'}
      ]},
      {'id': '1100000000000', 'name-th': 'ศ.ดร.ด้วยดี ตามไท', 'name-en': 'Prof. Dr. Duaydee Tamtai', 'profile': 'https://media.discordapp.net/attachments/1339973422494515212/1466642651330777222/61346471-07C0-4AED-AF16-B46C7876F3D4.jpg?ex=697d7ce8&is=697c2b68&hm=4687fb27b3ca45b7658b67c02eb42410cdc306c96f97887e0f9a66a22f56250e&=&format=webp&width=404&height=718', 'roles': [
        {'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
        {'role-name': 'รองคณบดี', 'role-color': 'FFA51D'},
      ]}
    ];

    return AppScaffold(
      header: Header.subHeader(context, title: 'จัดการผู้ใช้งานระบบ'),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 20),
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
                Column(
                  spacing: 5,
                  children: [
                    Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 5),
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
                    SizedBox(
                        width: double.infinity,
                        child: Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (input) {},
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
                                      Text('ค้นหาผู้ใช้...',
                                          style: TextStyle(
                                              color: Color(0xFF7D7D7D),
                                              fontSize: 15
                                          )
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 55,
                              child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.all(0),
                                    side: const BorderSide(
                                      color: Color(0xFF7D7D7D),
                                      width: 1,
                                    ),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/images/create_user.svg',
                                    colorFilter: ColorFilter.mode(Color(0xFF7D7D7D), BlendMode.srcIn),
                                  )
                              ),
                            )
                          ],
                        )
                    )
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SeparatorCard(
                        separatorPadding: EdgeInsets.only(left: 70, right: 15),
                        children: [
                          ...users.map((m) {
                            return UserInfoButton(
                              onPressed: () {

                              },
                              icon: Image.network(
                                  m['profile'],
                                  fit: BoxFit.cover
                              ),
                              title: m['name-th'],
                              subTitle: m['name-en'],
                              roles: m['roles']
                            );
                          })
                        ]
                    ),
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