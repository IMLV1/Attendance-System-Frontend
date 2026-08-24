import 'dart:async';

import 'package:attendance_system/features/settings/role_management/role_management.dart';
import 'package:attendance_system/features/settings/user_management/user/create_user.dart';
import 'package:attendance_system/features/settings/user_management/user/user_info.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/services/user_management/user_management_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<Response> mockGetUser() async {
  await Future.delayed(const Duration(milliseconds: 500));

  return Response(
    requestOptions: RequestOptions(path: '/mock/user'),
    statusCode: 200,
    data: {
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
          'initial-role': 'วิศวกรรมคอมพิวเตอร์',
          'roles': [
            {'role-id': '0000000001', 'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
            {'role-id': '0000000002', 'role-name': 'รองคณบดี', 'role-color': 'FFA51D'}
          ]
        },
        {
          'id': '1100000000001',
          'name-th': 'ศ.ดร.บลาๆๆๆๆๆๆๆๆ นี่คือนามสกุล',
          'name-en': 'Prof. Dr. ThisisSurName ThisIsLastName',
          'avatar-url': 'https://i.pinimg.com/736x/c0/05/11/c005114aae03691b32012e18c7ef3a6e.jpg',
          'employee-id': '6630300327',
          'gender': 'ชาย',
          'nationality': 'ไทย',
          'phone': '012-345-6789',
          'email': 'duaydee.t@eng.src.ku.ac.th',
          'initial-role': 'วิศวกรรมคอมพิวเตอร์',
          'roles': [
            {'role-id': '0000000001', 'role-name': 'ผู้ดูแลระบบ', 'role-color': 'FF0000'},
            {'role-id': '0000000002', 'role-name': 'รองคณบดี', 'role-color': 'FFA51D'}
          ]
        },
      ]
    }
  );
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

            final initRole = user.initRole.toLowerCase();

            return nameTh.contains(input) ||
                nameEn.contains(input) ||
                roleMatch ||
                initRole.contains(input);
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
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => RoleManagement(),
                                            ),
                                          );
                                        },
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
                                    textInputAction: TextInputAction.done,
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
                                      onPressed: () async {
                                        UserManagementModel? updatedUser = await Navigator.of(context).push(
                                          MaterialPageRoute<UserManagementModel>(
                                            builder: (context) => CreateUser(),
                                          ),
                                        );

                                        if (updatedUser != null) {
                                          setState(() {
                                            users.add(updatedUser);
                                            _onSearchChanged(_controller.text);
                                          });
                                        }
                                      },
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
                      child: ServiceLoader(
                        request: () => UserManagementService().getData(),
                        onSuccess: (jsonData) {
                          final List<UserManagementModel> data = UserManagementModel.getList(jsonData);

                          setState(() {
                            users = data;
                            _onSearchChanged(_controller.text);
                          });
                        },
                        // 🚩 (2026-08-22) ListView.builder — เดิมสร้างปุ่มผู้ใช้ทุกคนพร้อมกัน
                        // (แต่ละปุ่มมี Image.network) หน่วยงานที่มีคนเป็นร้อยจะกระตุกตอนเปิดหน้า
                        // SeparatorCard ใช้กับ builder ไม่ได้ เลยจัดเส้นคั่น/มุมโค้งเองรายตัว
                        builder: () => ListView.builder(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                              final m = filteredUsers[index];
                              final isFirst = index == 0;
                              final isLast = index == filteredUsers.length - 1;
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(isFirst ? 25 : 0),
                                    bottom: Radius.circular(isLast ? 25 : 0),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                UserInfoButton(
                                  onPressed: () async {
                                    final ({int status, UserManagementModel? updatedUser})? res = await Navigator.of(context).push<({int status, UserManagementModel? updatedUser})>(
                                      MaterialPageRoute(
                                        builder: (context) => UserInfo(userInfo: m),
                                      ),
                                    );

                                    if (res != null) {

                                      if (res.status == 0) {
                                        final index = users.indexWhere((
                                            u) =>
                                        u.id == res.updatedUser!.id);
                                        setState(() {
                                          users[index] = res.updatedUser!;
                                        });
                                      } else if (res.status == 1) {
                                        setState(() {
                                          users.remove(m);
                                        });
                                      }
                                    }
                                  },
                                  icon: Image.network(
                                    m.avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/profile.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                  title: m.nameTH,
                                  subTitle: m.nameEN,
                                  roles: [...m.roles, Role(id: '0000000000', name: m.initRole, color: Color(0xFF535353))],
                                ),
                                    if (!isLast)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 70, right: 15),
                                        child: Divider(height: 0),
                                      ),
                                  ],
                                ),
                              );
                          },
                        ),
                      )

                      // child: users.isEmpty
                      //     ? const Center(child: CupertinoActivityIndicator())
                      //     : SingleChildScrollView(
                      //   physics: const AlwaysScrollableScrollPhysics(),
                      //   child: SeparatorCard(
                      //     separatorPadding: const EdgeInsets.only(left: 70, right: 15),
                      //     children: [
                      //       ...filteredUsers.map((m) {
                      //         return UserInfoButton(
                      //           onPressed: () async {
                      //             final updatedUser = await Navigator.of(context).push<UserManagementModel>(
                      //               MaterialPageRoute(
                      //                 builder: (context) => UserInfo(userInfo: m),
                      //               ),
                      //             );
                      //
                      //             if (updatedUser != null) {
                      //               final index = users.indexWhere((u) => u.id == updatedUser.id);
                      //
                      //               setState(() {
                      //                 users[index] = updatedUser;
                      //               });
                      //             }
                      //
                      //           },
                      //           icon: Image.network(
                      //             m.avatarUrl,
                      //             fit: BoxFit.cover,
                      //           ),
                      //           title: m.nameTH,
                      //           subTitle: m.nameEN,
                      //           roles: [...m.roles, Role(id: '0000000000', name: m.initRole, color: Color(0xFF535353))],
                      //         );
                      //       }),
                      //     ],
                      //   ),
                      // ),
                    )
                  ]
              )
          )
        )
      ),
    );
  }
}