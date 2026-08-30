import 'package:attendance_system/services/assign_role_page/role_model.dart';
import 'package:attendance_system/services/assign_role_page/role_service.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/services/user_management/user_management_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// เนื้อหาของ popup "ตำแหน่งของผู้ใช้" — เลือกตำแหน่งให้คนหนึ่งคน แล้วกดบันทึกทีเดียว
///
/// 🚩 (2026-08-27) เดิมเป็นหน้าเต็มที่ `user_info` push ไปอีกชั้น ทั้งที่ช่องอื่น
/// ในหน้าเดียวกันทั้ง 7 ช่องเปิดเป็น popup กันหมด และบนจอกว้างการ push ยังทับ
/// master-detail จนรายการผู้ใช้ทางซ้ายหายไปทั้งอัน
///
/// ยังไม่ยุบเข้าไปในหน้า `user_info` ตรงๆ (ต่างจาก `MaxLeaveSection`) เพราะ
/// สองข้อ: ยาวไม่จำกัดตามจำนวนตำแหน่ง และเป็น batch-save — เอาไปวางกลางหน้าที่
/// ทุกช่องเซฟทันที ผู้ใช้จะติ๊กเสร็จแล้วเลื่อนไปทำอย่างอื่นต่อโดยไม่กดบันทึก
/// แล้วของหายเงียบ ปุ่มบันทึกจึงต้องอยู่ในกรอบของตัวเอง
class AssignRole extends StatefulWidget {

  final String id;
  final List<Role> roles;

  /// รายงานผลหลัง **บันทึกสำเร็จ** เท่านั้น
  ///
  /// 🚩 เดิมหน้านี้ pop คืน `roles` ตอนกดย้อนกลับด้วย และตัวแปร `roles` ก็เป็น
  /// ลิสต์ตัวเดียวกับของผู้เรียก (ไม่ได้ก๊อป) — ติ๊กแล้วกดย้อนกลับโดยไม่บันทึก
  /// หน้าก่อนจึงแสดงตำแหน่งใหม่ทั้งที่เซิร์ฟเวอร์ไม่เคยรู้เรื่อง
  final ValueChanged<List<Role>> onSaved;

  const AssignRole({
    super.key,
    required this.id,
    required this.roles,
    required this.onSaved,
  });

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
    // ก๊อปจริงๆ ไม่ใช่อ้างลิสต์เดิมของผู้เรียก (ดูหมายเหตุที่ onSaved)
    roles = [...widget.roles];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
                        child: ServiceLoader(
                            request: () => RoleService().getData(),
                            onSuccess: (jsonData) {
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
                        ),
        ),
        const SizedBox(height: 12),
                    ServiceUpdater(
                        request: () => UserManagementService().updateRole(widget.id, roles),
                        onSuccess: () {
                          setState(() {
                            oldRoles = [...roles];
                          });
                          widget.onSaved([...roles]);
                          Navigator.of(context).pop();
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
                    ),
      ],
    );
  }
}