import 'package:attendance_system/services/assign_role_page/role_model.dart';
import 'package:attendance_system/services/assign_role_page/role_service.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<Response> mockData() async {
  await Future.delayed(const Duration(milliseconds: 500));

  return Response(
      requestOptions: RequestOptions(path: '/mock/user'),
      statusCode: 200,
      data: {
        'data': [
          {
            'id': '0000000001',
            'name': 'ผู้ดูแลระบบ',
            'type': 'main',
            'color': 'FF0000',
            'member': 1
          },
          {
            'id': '0000000002',
            'name': 'รองคณบดี',
            'type': 'special',
            'color': 'FFA51D',
            'member': 2
          },
          {
            'id': '0000000003',
            'name': 'ฝ่ายบุคคล',
            'type': 'main',
            'color': 'B71DFF',
            'member': 2
          },
          {
            'id': '0000000004',
            'name': 'หัวหน้าสำนักงานเลขานุการ',
            'type': 'main',
            'color': '1D83FF',
            'member': 9
          },
        ]
      }
  );
}

class AssignRole extends StatefulWidget {

  final String id;
  final List<Role> roles;
  final String title;
  
  const AssignRole({super.key, required this.id, required this.roles, this.title = 'เพิ่มตำแหน่ง'});

  @override
  State<StatefulWidget> createState() => _AssignRoleState();
  
}

class _AssignRoleState extends State<AssignRole> {

  late List<Role> roles;

  List<RoleModel> allRoles = [];

  @override
  void initState() {
    super.initState();
    roles = widget.roles;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: widget.title,
        onBack: () {
          Navigator.pop(context, roles);
        }
      ),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
            child: Column(
              children: [
                Expanded(

                  child: ServiceLoader(
                      request: () => mockData(), //RoleService().getData(),
                      onSuccess: (jsonData) {
                        final data = RoleModel.getList(jsonData);
                        setState(() {
                          allRoles = data;
                        });
                      },
                      builder: () => SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          spacing: 13,
                          children: [
                            Column(
                              spacing: 5,
                              children: [
                                Row(
                                  spacing: 6,
                                  children: [
                                    SvgPicture.asset('assets/images/added_role.svg'),
                                    Text('ตำแหน่งที่เพิ่มแล้ว')
                                  ],
                                ),
                                SeparatorCard(
                                  separatorPadding: EdgeInsetsGeometry.only(right: 10, left: 60),
                                  children: [

                                    if (allRoles.where((m) => roles.map((m) => m.id).toList().contains(m.id)).isEmpty)
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(25)
                                          ),
                                          height: 60,
                                          child: Center(
                                              child: Text(
                                                'ไม่พบตำแหน่ง',
                                                style: TextStyle(
                                                    color: Color(0xFF7E7E7E)
                                                ),
                                              )
                                          )
                                      ),

                                    ...allRoles.where((m) => roles.map((m) => m.id).toList().contains(m.id)).map((m) {
                                      return AppButton(
                                        icon: (m.type == RoleType.main) ? 'role_management.svg' : 'specialer.svg',
                                        iconColor: m.color,
                                        title: m.name,
                                        subTitle: 'ใต้สังกัด ${m.member} คน',
                                        weightTitle: FontWeight.normal,
                                        arrowWidget: Padding(
                                          padding: EdgeInsetsGeometry.only(right: 10),
                                          child: SvgPicture.asset(
                                            'assets/images/remove.svg',
                                            width: 15,
                                            height: 15,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            roles.removeWhere((r) => r.id == m.id);
                                          });
                                        },
                                      );
                                    })
                                  ],
                                )
                              ],
                            ),
                            Column(
                              spacing: 5,
                              children: [
                                Row(
                                  spacing: 6,
                                  children: [
                                    SvgPicture.asset('assets/images/icon_role.svg'),
                                    Text('ตำแหน่งทั้งหมด')
                                  ],
                                ),
                                SeparatorCard(
                                  separatorPadding: EdgeInsetsGeometry.only(right: 10, left: 60),
                                  children: [

                                    ...allRoles.where((m) => !roles.map((m) => m.id).toList().contains(m.id)).map((m) {
                                      return AppButton(
                                        icon: (m.type == RoleType.main) ? 'role_management.svg' : 'specialer.svg',
                                        iconColor: m.color,
                                        title: m.name,
                                        subTitle: 'ใต้สังกัด ${m.member} คน',
                                        weightTitle: FontWeight.normal,
                                        arrowWidget: Padding(
                                          padding: EdgeInsetsGeometry.only(right: 10),
                                          child: SvgPicture.asset(
                                            'assets/images/add.svg',
                                            width: 15,
                                            height: 15,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            roles.add(Role(id: m.id, name: m.name, color: m.color));
                                          });
                                        },
                                      );
                                    })
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                    )
                  )
                )
              ],
            ),
          )
        )
      )
    );
  }
}