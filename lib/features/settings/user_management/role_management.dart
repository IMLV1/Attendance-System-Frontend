import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../services/role_management/role_management_model.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/utils/app_button.dart';
import '../../../shared/widgets/utils/icon_text_button.dart';
import '../../../shared/widgets/utils/separator_card.dart';

class RoleManagement extends StatefulWidget {
  const RoleManagement({super.key});

  @override
  State<RoleManagement> createState() => _RoleManagementState();
}

class _RoleManagementState extends State<RoleManagement> {

  final roleManagement = RoleManagementModel(
    mainRole: [
      RoleSystem(
        roleName: "ผู้ดูแลระบบ",
        // roleColor: "FF3B30",
        members: [
          Member(
            thName: "สมชาย ใจดี",
            enName: "Somchai Jaidee",
            avatarUrl: "https://example.com/avatar1.png",
          ),
          Member(
            thName: "วิภา แสนสวย",
            enName: "Wipa Saensuay",
            avatarUrl: "https://example.com/avatar2.png",
          ),
        ],
      ),
      RoleSystem(
        roleName: "อาจารย์",
        roleColor: "007AFF",
        members: [
          Member(
            thName: "ดร.กิตติพงศ์ ศรีสุข",
            enName: "Dr. Kittipong Srisuk",
            avatarUrl: "https://example.com/avatar3.png",
          ),
        ],
      ),
    ],
    specialRole: [
      RoleSystem(
        roleName: "หัวหน้าทีม",
        roleColor: "34C759",
        members: [
          Member(
            thName: "นฤมล รัตนชัย",
            enName: "Narumon Rattanachai",
            avatarUrl: "https://example.com/avatar4.png",
          ),
        ],
      ),
    ],
  );

  late TextEditingController _controller;
  late List<RoleSystem> _filteredMainRole;
  late List<RoleSystem> _filteredSpecialRole;


  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    _filteredMainRole = roleManagement.mainRole;
    _filteredSpecialRole = roleManagement.specialRole;
  }

  void _onSearchChanged(String value) {
    final keyword = value.toLowerCase();

    setState(() {
      if (keyword.isEmpty) {
        _filteredMainRole = roleManagement.mainRole;
        _filteredSpecialRole = roleManagement.specialRole;
      } else {
        _filteredMainRole = roleManagement.mainRole.where((role) {
          final matchRole =
          role.roleName.toLowerCase().contains(keyword);

          final matchMember = role.members.any((member) =>
          member.thName.toLowerCase().contains(keyword) ||
              member.enName.toLowerCase().contains(keyword));

          return matchRole || matchMember;
        }).toList();

        _filteredSpecialRole = roleManagement.specialRole.where((role) {
          final matchRole =
          role.roleName.toLowerCase().contains(keyword);

          final matchMember = role.members.any((member) =>
          member.thName.toLowerCase().contains(keyword) ||
              member.enName.toLowerCase().contains(keyword));

          return matchRole || matchMember;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                /// TODO: มาทำด้วย
                                Text('ตำแหน่งหนัก (${roleManagement.mainRole.length})')
                              ],
                            ),
                            // AppButtonListCard(
                            //     items: dataTest,
                            // ),
                            SeparatorCard(
                              separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 70),
                              children: [
                                ...roleManagement.mainRole.map((m) {
                                  return AppButton(
                                      icon: 'icon_admin.svg',
                                      iconColor: m.roleColor != null ? Color(int.parse('0xFF${m.roleColor}')) : null,
                                      title: m.roleName,
                                      subTitle: 'สมาชิก ${m.members.length} คน',
                                      arrow: true
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 6,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/role_management.svg',
                                  height: 15,
                                  width: 15,
                                ),
                                Text('ตำแหน่งเสริม (${roleManagement.specialRole.length})')
                              ],
                            ),
                            // AppButtonListCard(
                            //     items: dataTest,
                            // ),
                            SeparatorCard(
                              separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 70),
                              children: [
                              ...roleManagement.specialRole.map((m) {
                                return AppButton(
                                  icon: 'icon_admin.svg',
                                  iconColor: m.roleColor != null ? Color(int.parse('0xFF${m.roleColor}')) : null,,
                                  title: m.roleName,
                                  subTitle: 'สมาชิก ${m.members.length} คน',
                                  arrow: true
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
    );
  }
}