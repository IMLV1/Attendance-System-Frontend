import 'dart:async';

import 'package:attendance_system/features/settings/role_management/create_role.dart';
import 'package:attendance_system/features/settings/role_management/edit_role.dart';
import 'package:attendance_system/services/role_management/role_management_service.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../services/role_management/role_management_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/utils/app_button.dart';
import '../../../../shared/widgets/utils/icon_text_button.dart';
import '../../../../shared/widgets/utils/separator_card.dart';
import '../../../services/profile_page/profile_service.dart';
import '../../../shared/widgets/utils/services/service_loader.dart';

Future<Response> mockGetRole() async {
  await Future.delayed(const Duration(milliseconds: 500));

  return Response(
    requestOptions: RequestOptions(path: '/system/role'),
    statusCode: 200,
    data: {
      "mainRole": [
        {
          "id": "0",
          "roleName": "ผู้ดูแลระบบ",
          "type": "admin",
          "members": [
            {
              "id": "1000",
              "thName": "ผศ.ดร.ธีรพงศ์ พัฒนกุล",
              "enName": "Asst. Prof. Dr. Teerapong Pattanakul",
              "avatarUrl": "https://i.pravatar.cc/150?img=1"
            },
            {
              "id": "1001",
              "thName": "กิตติชัย ใจกล้า",
              "enName": "Kittichai Jaikla",
              "avatarUrl": "https://i.pravatar.cc/150?img=2"
            }
          ]
        },
        {
          "id": "1",
          "roleName": "ฝ่ายบุคคล",
          "roleColor": "FF9500",
          "type": "hr",
          "members": [
            {
              "id": "1002",
              "thName": "วรรณภา ศรีสวัสดิ์",
              "enName": "Wannapa Srisawat",
              "avatarUrl": "https://i.pravatar.cc/150?img=3"
            }
          ]
        }
      ],
      "specialRole": [
        {
          "id": "3",
          "roleName": "หัวหน้าทีมพัฒนาแอป",
          "roleColor": "34C759",
          "type": "specialRole",
          "members": [
            {
              "id": "1003",
              "thName": "นฤมล รัตนชัย",
              "enName": "Narumon Rattanachai",
              "avatarUrl": "https://i.pravatar.cc/150?img=4"
            }
          ]
        }
      ]
    }
  );
}


class RoleManagement extends StatefulWidget {
  const RoleManagement({super.key});

  @override
  State<RoleManagement> createState() => _RoleManagementState();
}

class _RoleManagementState extends State<RoleManagement> {

  late final TextEditingController _controller;

  RoleManagementModel? response;
  Timer? _debounce;

  List<RoleSystem> _allMainRoles = [];
  List<RoleSystem> _allSpecialRoles = [];

  List<RoleSystem> _filteredMainRoles = [];
  List<RoleSystem> _filteredSpecialRoles = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _applyFilter(keyword);
    });
  }

  void _applyFilter(String keyword, {bool rebuild = true}) {
    final key = keyword.trim().toLowerCase();

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

    if (rebuild) setState(() {});
  }

  void _updateRole(RoleSystem updated) {
    setState(() {
      _allMainRoles =
          _allMainRoles.map((r) => r.id == updated.id ? updated : r).toList();

      _allSpecialRoles =
          _allSpecialRoles.map((r) => r.id == updated.id ? updated : r).toList();

      _applyFilter(_controller.text, rebuild: false);
    });
  }

  void _removeRole(String id) {
    setState(() {
      _allMainRoles.removeWhere((r) => r.id == id);
      _allSpecialRoles.removeWhere((r) => r.id == id);

      _applyFilter(_controller.text, rebuild: false);
    });
  }


  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'จัดการตำแหน่ง'
      ),
      content:  SafeArea(
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
                      ),
                    ],
                  )
                ),
                ServiceLoader(
                  // request: () => RoleManagementService().getRoleManagementModel(),
                  request: () => mockGetRole(),
                  onSuccess: (jsonData) {
                    final data = RoleManagementModel.fromJson(jsonData);
                    setState(() {
                      response = data;
                      _allMainRoles = List.from(data.mainRole);
                      _allSpecialRoles = List.from(data.specialRole);
                      _applyFilter(_controller.text, rebuild: false);
                    });
                  },
                  builder: () => SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: (_filteredMainRoles.isNotEmpty || _filteredSpecialRoles.isNotEmpty)
                      ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3E3E3),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          spacing: 13,
                          children: [
                            /// Main roles
                            if (_filteredMainRoles.isNotEmpty)
                              Column(
                                spacing: 5,
                                children: [
                                  Row(
                                    spacing: 6,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/role_management.svg',
                                        width: 15,
                                        height: 15,
                                      ),
                                      Text('ตำแหน่งหลัก (${_filteredMainRoles.length})'),
                                    ],
                                  ),
                                  SeparatorCard(
                                    borderRadius: BorderRadius.all(Radius.circular(22)),
                                    separatorPadding: const EdgeInsets.only(left: 60, right: 15),
                                    children: [
                                      ..._filteredMainRoles.map((m) {
                                        ///icon_personnel_info.svg
                                        return AppButton(
                                          icon: (m.roleName == 'ผู้ดูแลระบบ' || m.roleName.toLowerCase() == 'admin') ? 'icon_admin.svg' : 'role_management.svg',
                                          iconColor: m.roleColor != null ? Color(int.parse('0xFF${m.roleColor}')) : null,
                                          title: m.roleName,
                                          weightTitle: FontWeight.normal,
                                          subTitle: 'สมาชิก ${m.members.length} คน',
                                          arrow: true,
                                          onPressed: () async {
                                            final result =
                                            await Navigator.of(context).push(
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
                                      }),
                                    ],
                                  ),
                                ],
                              ),

                            /// Special roles
                            if (_filteredSpecialRoles.isNotEmpty)
                              Column(
                                spacing: 5,
                                children: [
                                  Row(
                                    spacing: 6,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/specialer.svg',
                                        width: 15,
                                        height: 15,
                                      ),
                                      Text('ตำแหน่งเพิ่มเติม (${_filteredSpecialRoles.length})'),
                                    ],
                                  ),
                                  SeparatorCard(
                                    borderRadius: BorderRadius.all(Radius.circular(22)),
                                    separatorPadding: const EdgeInsets.only(left: 60, right: 15),
                                    children: [
                                      ..._filteredSpecialRoles.map((m) {
                                        return AppButton(
                                          icon: 'specialer.svg',
                                          iconColor: m.roleColor != null ? Color(int.parse('0xFF${m.roleColor}')) : null,
                                          title: m.roleName,
                                          weightTitle: FontWeight.normal,
                                          subTitle: 'สมาชิก ${m.members.length} คน',
                                          arrow: true,
                                          onPressed: () async {
                                            final result =
                                            await Navigator.of(context).push(
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
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                    ) : SizedBox()
                  )
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
