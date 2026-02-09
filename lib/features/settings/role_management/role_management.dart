
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../services/role_management/role_management_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/utils/app_button.dart';
import '../../../../shared/widgets/utils/icon_text_button.dart';
import '../../../../shared/widgets/utils/separator_card.dart';
import 'create_role.dart';
import 'edit_role.dart';


class RoleManagement extends StatefulWidget {
  const RoleManagement({super.key});

  @override
  State<RoleManagement> createState() => _RoleManagementState();
}

class _RoleManagementState extends State<RoleManagement> {

  final roleManagement = RoleManagementModel(
    mainRole: [
      RoleSystem(
        id: '1',
        roleName: "ผู้ดูแลระบบ",
        // roleColor: "FF3B30",
        members: [
          Member(
            id: '1000',
            thName: "สมชาย ใจดี",
            enName: "SomChai Jaimee",
            avatarUrl: "https://example.com/avatar1.png",
          ),
        ],
      ),
      RoleSystem(
        id: '2',
        roleName: "อาจารย์",
        roleColor: "007AFF",
        members: [
          Member(
            id: '1001',
            thName: "ดร.กิตติพงศ์ ศรีสุข",
            enName: "Dr. KittiPong Sunrise",
            avatarUrl: "https://example.com/avatar3.png",
          ),
          Member(
            id: '1002',
            thName: "วิภา แสนสวย",
            enName: "Wipe Sensuality",
            avatarUrl: "https://example.com/avatar2.png",
          ),
          Member(
            id: '1003',
            thName: "วิภา แสนสวย",
            enName: "Wipe Sensuality",
            avatarUrl: "https://example.com/avatar2.png",
          ),
          Member(
            id: '1004',
            thName: "วิภา แสนสวย",
            enName: "Wipe Sensuality",
            avatarUrl: "https://example.com/avatar2.png",
          ),
          Member(
            id: '1005',
            thName: "วิภา แสนสวย",
            enName: "Wipe Sensuality",
            avatarUrl: "https://example.com/avatar2.png",
          ),
          Member(
            id: '1006',
            thName: "วิภา แสนสวย",
            enName: "Wipe Sensuality",
            avatarUrl: "https://example.com/avatar2.png",
          ),
          Member(
            id: '1007',
            thName: "วิภา แสนสวย",
            enName: "Wipe Sensuality",
            avatarUrl: "https://example.com/avatar2.png",
          ),
        ],
      ),
    ],
    specialRole: [
      RoleSystem(
        id: '3',
        roleName: "หัวหน้าทีม",
        roleColor: "34C759",
        members: [
          Member(
            id: '1008',
            thName: "นฤมล รัตนชัย",
            enName: "Naruto Attractant",
            avatarUrl: "https://example.com/avatar4.png",
          ),
        ],
      ),
    ],
  );

  late TextEditingController _controller;

  late List<RoleSystem> _allMainRoles;
  late List<RoleSystem> _allSpecialRoles;

  List<RoleSystem> _filteredMainRoles = [];
  List<RoleSystem> _filteredSpecialRoles = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // clone list ป้องกัน side-effect
    _allMainRoles = List.from(roleManagement.mainRole);
    _allSpecialRoles = List.from(roleManagement.specialRole);

    _applyFilter('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- filter ----------
  void _applyFilter(String keyword) {
    final key = keyword.trim().toLowerCase();

    setState(() {
      if (key.isEmpty) {
        _filteredMainRoles = _allMainRoles;
        _filteredSpecialRoles = _allSpecialRoles;
      } else {
        _filteredMainRoles = _allMainRoles
            .where((r) => r.roleName.toLowerCase().contains(key))
            .toList();

        _filteredSpecialRoles = _allSpecialRoles
            .where((r) => r.roleName.toLowerCase().contains(key))
            .toList();
      }
    });
  }

  // ---------- update / delete ----------
  void _updateRole(RoleSystem updated) {
    setState(() {
      _allMainRoles =
          _allMainRoles.map((r) => r.id == updated.id ? updated : r).toList();

      _allSpecialRoles = _allSpecialRoles
          .map((r) => r.id == updated.id ? updated : r)
          .toList();

      _applyFilter(_controller.text);
    });
  }

  void _removeRole(String id) {
    setState(() {
      _allMainRoles.removeWhere((r) => r.id == id);
      _allSpecialRoles.removeWhere((r) => r.id == id);
      _applyFilter(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'จัดการตำแหน่ง'
      ),
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
                      IconTextButton(
                        // arrow: false,
                        icon: 'icon_create_role.svg',
                        label: 'สร้างตำแหน่งใหม่...',
                        color: AppColors.primaryColor,
                        onPressed: () {
                          /// ไปหน้าอื่น
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRole(),
                            )
                          );
                        },
                      )
                    ],
                  ),
                  TextField(
                    controller: _controller,
                    onChanged: _applyFilter,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
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
                  if (_filteredMainRoles.isNotEmpty || _filteredSpecialRoles.isNotEmpty)
                    SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFE3E3E3),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: EdgeInsetsGeometry.symmetric(vertical: 12, horizontal: 15),
                        width: double.infinity,
                        child: Column(
                          spacing: 13,
                          children: [
                            /// ตำแหน่งหลัก
                            if (_filteredMainRoles.isNotEmpty)
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
                                      /// TODO: มาทำด้วย
                                      Text('ตำแหน่งหนัก (${_filteredMainRoles.length})')
                                    ],
                                  ),
                                  // AppButtonListCard(
                                  //     items: dataTest,
                                  // ),
                                  SeparatorCard(
                                    separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 60),
                                    children: [
                                      ..._filteredMainRoles.map((m) {
                                        return AppButton(
                                          icon: (m.roleName == 'ผู้ดูแลระบบ' || m.roleName.toLowerCase() == 'admin') ? 'icon_admin.svg' : 'role_management.svg',
                                          iconColor: m.roleColor != null ? Color(int.parse('0xFF${m.roleColor}')) : null,
                                          title: m.roleName,
                                          subTitle: 'สมาชิก ${m.members.length} คน',
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    EditRole(roleInfo: m),
                                              ),
                                            );

                                            if (result is RoleSystem) {
                                              _updateRole(result);
                                            } else if (result == true) {
                                              _removeRole(m.id);
                                            }
                                          },
                                        );
                                      })
                                    ],
                                  )
                                ],
                              ),
                            /// ตำแหน่งเสริม
                            if (_filteredSpecialRoles.isNotEmpty)
                              Column(
                                spacing: 5,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 6,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/specialer.svg',
                                        height: 15,
                                        width: 15,
                                      ),
                                      Text('ตำแหน่งเพิ่มเติม (${_filteredSpecialRoles.length})')
                                    ],
                                  ),
                                  // AppButtonListCard(
                                  //     items: dataTest,
                                  // ),
                                  SeparatorCard(
                                    separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 60),
                                    children: [
                                      ..._filteredSpecialRoles.map((m) {
                                        return AppButton(
                                          icon: 'specialer.svg',
                                          iconColor: m.roleColor != null ? Color(int.parse('0xFF${m.roleColor}')) : null,
                                          title: m.roleName,
                                          subTitle: 'สมาชิก ${m.members.length} คน',
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    EditRole(roleInfo: m),
                                              ),
                                            );

                                            if (result is RoleSystem) {
                                              _updateRole(result);
                                            } else if (result == true) {
                                              _removeRole(m.id);
                                            }
                                          },
                                        );
                                      })
                                    ],
                                  )
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
      ),
    );
  }
}
