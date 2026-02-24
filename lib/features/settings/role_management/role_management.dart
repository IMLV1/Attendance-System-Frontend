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
import '../../../shared/widgets/utils/services/service_loader.dart';

Future<Response> mockGetRole() async {
  await Future.delayed(const Duration(milliseconds: 500));

  return Response(
    requestOptions: RequestOptions(path: '/system/role'),
    statusCode: 200,
    data: {
      "roles": [
        {
          "id": "1",
          "roleName": "Admin",
          "roleColor": "FF0000",
          "type": "admin",
          "members": [
            {
              "id": "u1",
              "thName": "สมชาย ใจดี",
              "enName": "Somchai Jaidee",
              "avatarUrl": "https://example.com/avatar.png"
            }
          ]
        },
        {
          "id": "2",
          "roleName": "HR",
          "roleColor": "00FF00",
          "type": "hr",
          "members": []
        },
        {
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },{
          "id": "3",
          "roleName": "Employee",
          "roleColor": "0000FF",
          "type": "main",
          "members": []
        },
        {
          "id": "4",
          "roleName": "Project Manager",
          "roleColor": "FFFF00",
          "type": "special",
          "members": []
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
      _filteredMainRoles = _allMainRoles.where((r) => r.roleName.toLowerCase().contains(key)).toList();
      _filteredSpecialRoles = _allSpecialRoles.where((r) => r.roleName.toLowerCase().contains(key)).toList();
    }
    if (rebuild) setState(() {});
  }


  void _updateRole(RoleSystem updatedRole) {
    setState(() {
      if (updatedRole.type == RoleType.specialRole) {
        final index = _allSpecialRoles
          .indexWhere((e) => e.id == updatedRole.id
        );

        if (index != -1) {
          _allSpecialRoles[index] = updatedRole;
        }
      } else if (updatedRole.type == RoleType.admin || updatedRole.type == RoleType.hr) {
        final index = _allMainRoles
          .indexWhere((e) => e.id == updatedRole.id
        );

        if (index != -1) {
          _allMainRoles[index] = updatedRole;
        }

      } else {
        final newId = updatedRole.members.map((e) => e.id).toSet();

        final index = _allMainRoles
          .indexWhere((e) => e.id == updatedRole.id);

        if (index == -1) return;

        _allMainRoles[index] = updatedRole;

        for (int i = 0; i < _allMainRoles.length; i++) {
          if (i == index) continue;

          if (_allMainRoles[i].type == RoleType.mainRole) {
            final role = _allMainRoles[i];
            _allMainRoles[i] = role.copyWith(
              members: role.members
                  .where((e) => !newId.contains(e.id))
                  .toList(),
            );
          }
        }
      }

      _applyFilter(_controller.text);
    });
  }


  void _removeRole(String roleId) {
    setState(() {

      _allMainRoles.removeWhere((role) => role.id == roleId);
      _allSpecialRoles.removeWhere((role) => role.id == roleId);

      _filteredMainRoles = List.from(_allMainRoles);
      _filteredSpecialRoles = List.from(_allSpecialRoles);

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
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      spacing: 13,
                      children: [
                        SeparatorCard(
                          children: [
                            IconTextButton(
                              // arrow: false,
                              icon: 'icon_create_role.svg',
                              label: 'สร้างตำแหน่งใหม่...',
                              color: AppColors.primaryColor,
                              onPressed: () async {

                                final RoleSystem? newRole = await Navigator.push<RoleSystem>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateRole(),
                                  ),
                                );

                                if (newRole == null) return;

                                setState(() {
                                  if (newRole.type == RoleType.specialRole) {
                                    _allSpecialRoles.add(newRole);
                                  } else {
                                    _allMainRoles.add(newRole);

                                    if (newRole.type == RoleType.mainRole) {
                                      final newId = newRole.members.map((e) => e.id).toSet();

                                      final index = _allMainRoles.length - 1;

                                      for (int i = 0; i < _allMainRoles.length; i++) {
                                        if (i == index) continue;

                                        final role = _allMainRoles[i];
                                        if (role.type == RoleType.mainRole) {
                                          _allMainRoles[i] = role.copyWith(
                                            members: role.members
                                                .where((e) => !newId.contains(e.id))
                                                .toList(),
                                          );
                                        }
                                      }
                                    }
                                  }

                                  _applyFilter(_controller.text, rebuild: false);
                                });
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
                          request: () => RoleManagementService().getRoleManagementModel(),
                          // request: () => mockGetRole(),
                          onSuccess: (jsonData) {
                            final data = RoleManagementModel.fromJson(jsonData);
                            setState(() {
                              response = data;
                              _allMainRoles = data.mainRole;
                              _allSpecialRoles = data.specialRole;
                              _applyFilter(_controller.text, rebuild: false);
                            });
                          },
                          builder: () => Container(
                              padding: EdgeInsetsGeometry.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  bottom: 10
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                color: Color(0xFFEAEAEA),
                              ),
                              child: Column(
                                children: [

                                    /// Main roles
                                    if (_filteredMainRoles.isNotEmpty)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/role_management.svg',
                                                width: 15,
                                                height: 15,
                                              ),
                                              const SizedBox(width: 6),
                                              Text('ตำแหน่งหลัก (${_filteredMainRoles
                                                  .length})'),
                                            ],
                                          ),

                                          const SizedBox(height: 5),

                                          SeparatorCard(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(22)),
                                            separatorPadding: const EdgeInsets.only(
                                                left: 60, right: 15),
                                            children: () {
                                              // ✅ ใส่ตรงนี้
                                              final sortedRoles = List<RoleSystem>.from(
                                                  _filteredMainRoles);

                                              sortedRoles.sort((a, b) {
                                                int order(RoleType type) {
                                                  switch (type) {
                                                    case RoleType.admin:
                                                      return 0;
                                                    case RoleType.hr:
                                                      return 1;
                                                    case RoleType.mainRole:
                                                      return 2;
                                                    case RoleType.specialRole:
                                                      return 3;
                                                  }
                                                }

                                                return order(a.type).compareTo(
                                                    order(b.type));
                                              });

                                              // ✅ แล้ว map จาก sortedRoles แทน
                                              return sortedRoles.map((m) {
                                                return AppButton(
                                                  icon: switch (m.type) {
                                                    RoleType.admin => 'icon_admin.svg',
                                                    RoleType.hr => 'icon_hr.svg',
                                                    RoleType
                                                        .mainRole => 'role_management.svg',
                                                    RoleType.specialRole => 'specialer.svg',
                                                  },
                                                  iconColor: m.roleColor != null
                                                      ? Color(
                                                      int.parse('0xFF${m.roleColor}'))
                                                      : null,
                                                  title: m.roleName,
                                                  weightTitle: FontWeight.normal,
                                                  subTitle: 'สมาชิกในสังกัด ${m.members
                                                      .length} คน',
                                                  arrow: true,
                                                  onPressed: () async {
                                                    final result = await Navigator.of(
                                                        context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            EditRole(roleInfo: m),
                                                      ),
                                                    );

                                                    if (result != null) {
                                                      if (result is Map &&
                                                          result['status'] == 1) {
                                                        _removeRole(m.id);
                                                      } else if (result is RoleSystem) {
                                                        _updateRole(result);
                                                      }
                                                    }
                                                  },
                                                );
                                              }).toList();
                                            }(),
                                          ),

                                        ],
                                      ),

                                    /// Special roles
                                    if (_filteredSpecialRoles.isNotEmpty)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          const SizedBox(height: 13),

                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/specialer.svg',
                                                width: 15,
                                                height: 15,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                  'ตำแหน่งเพิ่มเติม (${_filteredSpecialRoles
                                                      .length})'),
                                            ],
                                          ),

                                          const SizedBox(height: 5),

                                          SeparatorCard(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(22)),
                                            separatorPadding:
                                            const EdgeInsets.only(left: 60, right: 15),
                                            children: _filteredSpecialRoles.map((m) {
                                              return AppButton(
                                                icon: switch (m.type) {
                                                  RoleType.admin => 'icon_admin.svg',
                                                  RoleType.hr => 'icon_hr.svg',
                                                  RoleType
                                                      .mainRole => 'role_management.svg',
                                                  RoleType.specialRole => 'specialer.svg',
                                                },
                                                iconColor: m.roleColor != null
                                                    ? Color(int.parse('0xFF${m.roleColor}'))
                                                    : null,
                                                title: m.roleName,
                                                weightTitle: FontWeight.normal,
                                                subTitle: 'สมาชิกในสังกัด ${m.members
                                                    .length} คน',
                                                arrow: true,
                                                onPressed: () async {
                                                  final result = await Navigator
                                                      .of(context)
                                                      .push(
                                                    MaterialPageRoute(
                                                      builder: (_) => EditRole(roleInfo: m),
                                                    ),
                                                  );

                                                  if (result != null) {
                                                    if (result is Map &&
                                                        result['status'] == 1) {
                                                      _removeRole(m.id);
                                                    } else if (result is RoleSystem) {
                                                      _updateRole(result);
                                                    }
                                                  }
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                  ],
                              ),
                            )
                        )
                      ],
                    ),
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
