import 'dart:async';

import 'package:attendance_system/features/settings/user_management/user/user_info.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MockData {
  Future<List<UserManagementModel>> getData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final data = {
      'data': [
        {
          'id': '1100000000000',
          'name-th': 'ศ.ดร.บลาๆๆๆๆๆๆๆๆ นี่คือนามสกุล',
          'name-en': 'Prof. Dr. ThisisSurName ThisIsLastName',
          'avatar-url': 'https://i.pinimg.com/736x/c0/05/11/c005114aae03691b32012e18c7ef3a6e.jpg',
          'employee-id': '6630300327',
          'gender': 'ชาย',
          'nationality': 'ไทย',
          'phone': '012-345-6789',
          'email': 'duaydee.t@eng.src.ku.ac.th',
          'roles': [
            {'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
            {'role-name': 'รองคณบดี', 'role-color': 'FFA51D'},
            {'role-name': 'วิศวกรรมคอมพิวเตอร์', 'role-color': '535353'}
          ]
        }
      ]
    };

    return UserManagementModel.getList(data);
  }
}

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<StatefulWidget> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {

  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<UserManagementModel> users = [];
  List<UserManagementModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await MockData().getData();

    setState(() {
      users = data;
      filteredUsers = data;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final input = query.toLowerCase();

      setState(() {
        if (input.isEmpty) {
          filteredUsers = users;
        } else {
          filteredUsers = users.where((user) {
            final nameTh = user.nameTH.toLowerCase();
            final nameEn = user.nameEN.toLowerCase();

            final roleMatch = user.roles.any((role) =>
                role.name.toLowerCase().contains(input));

            return nameTh.contains(input) ||
                nameEn.contains(input) ||
                roleMatch;
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

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
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(horizontal: 5),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              overlayColor: Colors.transparent,
                                            ),
                                            onPressed: () {},
                                            child: Text(
                                              'ไปจัดการ',
                                              style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: 14
                                              ),
                                            )
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
                                        controller: _controller,
                                        onChanged: _onSearchChanged,
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
                          child: users.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SeparatorCard(
                              separatorPadding: const EdgeInsets.only(left: 70, right: 15),
                              children: [
                                ...filteredUsers.map((m) {
                                  return UserInfoButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (context) => UserInfo(userInfo: m),
                                        ),
                                      );
                                    },
                                    icon: Image.network(
                                      m.avatarUrl,
                                      fit: BoxFit.cover,
                                    ),
                                    title: m.nameTH,
                                    subTitle: m.nameEN,
                                    roles: m.roles,
                                  );
                                }).toList(),
                              ],
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