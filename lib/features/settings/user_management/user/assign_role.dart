import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/services/assign_role_page/role_model.dart';
import 'package:attendance_system/services/assign_role_page/role_service.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/services/user_management/user_management_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:collection/collection.dart';
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

  late List<Role> oldRoles;
  late List<Role> roles;

  List<RoleModel> allRoles = [];

  @override
  void initState() {
    super.initState();
    oldRoles = [...widget.roles];
    roles = widget.roles;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // 🚩 (2026-08-27) เดิมไม่ได้ระบุ maxWidth เลยตกไปใช้ค่า default
      // (dashboard = 1100) ทั้งที่หน้านี้เป็นฟอร์มคอลัมน์เดียว ผลคือบนจอกว้าง
      // ช่องกรอกช่องเดียวยืดยาวเป็นพันพิกเซล
      maxWidth: Responsive.widthFor(ContentShape.form),
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
            padding: EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(

                        child: ServiceLoader(
                            request: () => RoleService().getData(),
                            onSuccess: (jsonData) {

                              print(jsonData);

                              final data = RoleModel.getList(jsonData);
                              setState(() {
                                allRoles = data;
                              });
                            },
                            builder: () => SingleChildScrollView(
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                              icon: switch (m.type) {
                                                RoleType.admin => 'icon_admin.svg',
                                                RoleType.hr => 'icon_hr.svg',
                                                RoleType.main => 'role_management.svg',
                                                RoleType.special => 'specialer.svg',
                                              },
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
                                              icon: switch (m.type) {
                                                RoleType.admin => 'icon_admin.svg',
                                                RoleType.hr => 'icon_hr.svg',
                                                RoleType.main => 'role_management.svg',
                                                RoleType.special => 'specialer.svg',
                                              },
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ServiceUpdater(
                        request: () => UserManagementService().updateRole(widget.id, roles),
                        onSuccess: () {
                          setState(() {
                            oldRoles = [...roles];
                          });
                        },
                        builder: (trigger, state, errorMessage) {

                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton.icon(
                                  onPressed: (state != .loading && !UnorderedIterableEquality().equals(oldRoles, roles)) ? () => trigger() : null,
                                  icon: SvgPicture.asset(
                                    'assets/images/save.svg',
                                    height: 18,
                                    width: 18,
                                    colorFilter: ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 10,
                                    children: [
                                      Text(
                                        'บันทึก',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (state == .loading) CupertinoActivityIndicator(color: Colors.white),
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor: Colors.grey,
                                    backgroundColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 25,
                                child: (state == ServiceUpdatorState.error) ?
                                Text(
                                    'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
                                    style: TextStyle(
                                        color: Colors.red
                                    )
                                ) : SizedBox()
                              )
                            ],
                          );
                        }
                    )
                  ],
                ),
              ],
            )
          )
        )
      )
    );
  }
}