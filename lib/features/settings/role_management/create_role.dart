import 'dart:async';

import 'package:attendance_system/core/data/api/role_management_api.dart';
import 'package:attendance_system/core/data/entities/role_management_model.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/head_bar/header.dart';
import '../../../shared/widgets/helper/color_picker_popup/color_picker.dart';
import '../../../shared/widgets/utils/icon_text_button.dart';
import '../../../shared/widgets/utils/popup/option_popup.dart';
import '../../../shared/widgets/utils/popup/push_popup.dart';
import '../../../shared/widgets/utils/separator_card.dart';
import '../../../shared/widgets/utils/services/service_loader.dart';
import '../../../shared/widgets/utils/services/service_updater.dart';
import '../../../shared/widgets/utils/user_cancel_checkbox.dart';

class CreateRole extends StatefulWidget {
  const CreateRole({super.key});

  @override
  State<CreateRole> createState() => _CreateRoleState();
}

class _CreateRoleState extends State<CreateRole> {

  late RoleSystem newRole = RoleSystem(roleName: '', members: [], type: RoleType.specialRole, roleColor: '7E7E7E');
  
  Timer? _debounce;
  Timer? _popupDebounce;

  late TextEditingController _nameController;
  late TextEditingController _searchController;
  final TextEditingController _popupSearchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late Color _roleColor;

  List<Member> _filteredMembers = [];
  List<Member> allMembers = [];
  List<Member> addMembers = [];
  List<Member> popupFilteredMembers = [];

  // ---------- lifecycle ----------
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: newRole.roleName);
    _nameController.addListener(() {
      setState(() {});
    });
    _searchController = TextEditingController();
    _roleColor = newRole.roleColor != null ? _hexToColor(newRole.roleColor!) : const Color(0xFFFFA726);
    _filteredMembers = newRole.members;
  }


  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _popupSearchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _popupDebounce?.cancel();
    super.dispose();
  }

  // ---------- utils ----------
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  String _colorToHex(Color color) {
    return color.toARGB32().toRadixString(16).substring(2).toUpperCase();
  }

  // ---------- search member ----------
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final key = value.trim().toLowerCase();

      setState(() {
        _filteredMembers = key.isEmpty ? newRole.members : newRole.members
            .where((m) => m.thName
            .toLowerCase()
            .contains(key) || m.enName
            .toLowerCase()
            .contains(key))
            .toList();
      });
    });
  }

  void _filterPopupMembers(String key, void Function(void Function()) setStatePopup) {
    if (!mounted) return;

    final searchKey = key.trim().toLowerCase();

    setStatePopup(() {
      popupFilteredMembers = allMembers.where((m) {

        final th = m.thName.trim().toLowerCase();
        final en = m.enName.trim().toLowerCase();

        final matchSearch = searchKey.isEmpty || th.contains(searchKey) || en.contains(searchKey);

        final notInRole = !newRole.members.any((e) => e.id.trim() == m.id.trim());

        return matchSearch && notInRole;

      }).toList();
    });
  }

  String getPermission(RoleSystem element) {
    switch (element.type) {
      case RoleType.admin:
        return 'ผู้ดูแลระบบ';
      case RoleType.hr:
        return 'ฝ่ายบุคคล';
      case RoleType.mainRole:
        return 'ตำแหน่งหลัก';
      case RoleType.specialRole:
        return 'ตำแหน่งเพิ่มเติม';
    }
  }

  RoleType permissionToRoleType(String val) {
    switch (val) {
      case 'ผู้ดูแลระบบ':
        return RoleType.admin;
      case 'ฝ่ายบุคคล':
        return RoleType.hr;
      case 'ตำแหน่งหลัก':
        return RoleType.mainRole;
      case 'ตำแหน่งเพิ่มเติม':
      default:
        return RoleType.specialRole;
    }
  }


  String roleTypeToApi(RoleType type) {
    switch (type) {
      case RoleType.admin:
        return 'admin';
      case RoleType.hr:
        return 'hr';
      case RoleType.mainRole:
        return 'main';
      case RoleType.specialRole:
        return 'special';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
          context,
          title: 'สร้างตำแหน่งใหม่'
      ),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 10, right: 10, top: 20, bottom: 10),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          spacing: 17,
                          children: [
                            /// ===== Role name =====
                            Container(
                              width: double.infinity,
                              padding:
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3E3E3),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                spacing: 13,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 6,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/tag.svg',
                                        height: 15,
                                        width: 15,
                                      ),
                                      const Text('ตำแหน่ง'),
                                    ],
                                  ),
                                  Row(
                                    spacing: 13,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _nameController,
                                          focusNode: _focusNode,
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                            hintText: 'กรุณาระบุชื่อตำแหน่ง',
                                            hintStyle: const TextStyle(
                                              color: Colors.black38,
                                              fontSize: 14,
                                            ),
                                            isDense: true,
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(25),
                                              borderSide: BorderSide.none,
                                            ),
                                            suffixIcon: InkWell(
                                              customBorder: const CircleBorder(),
                                              onTap: () {
                                                _nameController.clear();
                                                FocusScope.of(context).unfocus();
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Icon(
                                                  CupertinoIcons.xmark_circle_fill,
                                                  size: 17,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            newRole = newRole.copyWith(roleName: val.trim());
                                          },
                                          onSubmitted: (val) {
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                      InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () {
                                          ColorPickerPopup(
                                            selected: _roleColor,
                                            onSubmit: (color) {
                                              setState(() {
                                                _roleColor = color;

                                                newRole = newRole.copyWith(
                                                  roleColor: _colorToHex(color),
                                                );
                                              });
                                            },
                                          ).showPopup(context);
                                        },
                                        child: Container(
                                          width: 33,
                                          height: 33,
                                          decoration: BoxDecoration(
                                            color: _roleColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF606060),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            /// ===== Delete role =====
                            // SeparatorCard(
                            //     separatorPadding: EdgeInsets.only(left: 45, right: 15),
                            //     children: [
                            //       IconTextButton(onPressed: () {
                            //         FloatingPopup(
                            //             title: 'ลบตำแหน่ง',
                            //             description: 'คุณยืนยันที่จะลบตำแหน่ง ${_role.roleName} หรือไม่ การดำเนินการนี้จะไม่สามารถย้อนกลับมาได้อีก',
                            //             buttons: (parent, context1) => [
                            //               FloatingPopupButton(
                            //                 text: 'ยกเลิก',
                            //                 foregroundColor: Colors.white,
                            //                 backgroundColor: AppColors.primaryColor,
                            //                 onPressed: () {
                            //                   Navigator.of(context1).pop();
                            //                 },
                            //               ),
                            //               FloatingServicePopupButton(
                            //                 text: 'ยันยัน',
                            //                 foregroundColor: Colors.red,
                            //                 request: () => RoleManagementService().deleteRole(_role),
                            //                 setError: parent,
                            //                 onSuccess: () {
                            //                   Navigator.of(context1).pop();
                            //
                            //                   Navigator.pop(context, {
                            //                     'status': 1,
                            //                   });
                            //                 },
                            //               )
                            //             ]
                            //         ).showPopup(context);
                            //       }, arrow: false, color: Colors.red, icon: 'icon_delete.svg', label: 'ลบตำแหน่ง')
                            //     ]
                            // ),
                            /// กำหนดสิทธิ์การเข้าถึง
                            SeparatorCard(
                              separatorPadding:
                              const EdgeInsets.only(left: 45, right: 15),
                              children: [
                                IconTextButton(
                                  arrow: false,
                                  icon: 'icon_key.svg',
                                  label: 'ระดับสิทธิ์การเข้าถึง',
                                  onPressed: ()  {
                                    OptionPopup(
                                      title: 'ระดับสิทธิ์การเข้าถึง',
                                      options: ['ตำแหน่งหลัก', 'ตำแหน่งเพิ่มเติม', 'ผู้ดูแลระบบ','ฝ่ายบุคคล'],
                                      buttonLabel: 'บันทึก',
                                      maxHeight: 700,
                                      fit: FlexFit.tight,
                                      selected: getPermission(newRole),
                                      onSubmit: (val) {

                                        setState(() {
                                          newRole = newRole.copyWith(type: permissionToRoleType(val));
                                        });
                                      },

                                    ).showPopup(context);
                                  },
                                ),
                              ],
                            ),

                            /// ===== Search & Add =====
                            Column(
                              spacing: 6,
                              children: [
                                Row(
                                  spacing: 6,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/icon_user.svg',
                                      height: 15,
                                      width: 15,
                                    ),
                                    Text('สมาชิกในสังกัด (${_filteredMembers.length})'),
                                  ],
                                ),
                                /// ==== Searchbar ====
                                SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
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
                                          ),

                                          onPressed: () async {
                                            _popupSearchController.clear();

                                            addMembers = [];
                                            popupFilteredMembers = [];

                                            PushPopup(
                                              title: 'เพิ่มสมาชิก',
                                              buttonLabel: 'เพิ่ม',
                                              fit: FlexFit.tight,
                                              scroll: false,
                                              buttonAction: (context) {
                                                setState(() {
                                                  final newMembers = List<Member>.from(newRole.members);

                                                  for (var m in addMembers) {
                                                    if (!newMembers.any((e) => e.id == m.id)) {
                                                      newMembers.add(m);
                                                    }
                                                  }

                                                  newRole = newRole.copyWith(members: newMembers);

                                                  _filteredMembers = newRole.members;
                                                });


                                                Navigator.pop(context);
                                              },
                                              builder: (_) => StatefulBuilder(
                                                builder: (context, setStatePopup) {

                                                  return Column(
                                                    spacing: 16,
                                                    children: [
                                                      TextField(
                                                        controller: _popupSearchController,
                                                        onChanged: (val) {

                                                          if (_popupDebounce?.isActive ?? false) {
                                                            _popupDebounce!.cancel();
                                                          }

                                                          _popupDebounce = Timer(
                                                            const Duration(milliseconds: 400),
                                                                () => _filterPopupMembers(val, setStatePopup),
                                                          );

                                                        },
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
                                                      ServiceLoader(
                                                        request: () => RoleManagementApi().getAllUser(),
                                                        onSuccess: (res) {
                                                          final map = res as Map<String, dynamic>;
                                                          final list = map['members'] as List;

                                                          final loaded =
                                                          list.map((e) => Member.fromJson(e)).toList();

                                                          allMembers = loaded;

                                                          _filterPopupMembers(
                                                            _popupSearchController.text,
                                                            setStatePopup,
                                                          );
                                                        },
                                                        builder: () => Expanded(
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(20),
                                                            child: SingleChildScrollView(
                                                              child: SeparatorCard(
                                                              separatorPadding: EdgeInsetsGeometry.only(left: 68, right: 15),
                                                                children: [
                                                                  ...popupFilteredMembers.map((m) {
                                                                    return UserCancelCheckbox(
                                                                      icon: Image.network(m.avatarUrl),
                                                                      title: m.thName,
                                                                      subTitle: m.enName,
                                                                      checkBox: true,
                                                                      value: addMembers.any((e) => e.id == m.id),
                                                                      onChanged: (val) {
                                                                        setStatePopup(() {
                                                                          if (val) {
                                                                            if (!addMembers.any((e) => e.id == m.id)) {
                                                                              addMembers.add(m);
                                                                            }
                                                                          } else {
                                                                            addMembers.removeWhere((e) => e.id == m.id);
                                                                          }
                                                                        });
                                                                      },
                                                                    );
                                                                  })
                                                                ],
                                                              ),
                                                            )
                                                          ),
                                                        )
                                                      )
                                                    ],
                                                  );
                                                }
                                              )
                                            ).showPopup(context);
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                )
                              ],
                            ),

                            /// ===== Member list =====
                            if (_filteredMembers.isNotEmpty)
                              SeparatorCard(
                                separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 68),
                                children: [
                                  ..._filteredMembers.map((m) {
                                    return UserCancelCheckbox(
                                      icon: Image.network(m.avatarUrl, fit: BoxFit.cover,),
                                      title: m.thName,
                                      subTitle: m.enName,
                                      checkBox: false,
                                      onCancel: () {
                                        setState(() {
                                          final newMembers = List<Member>.from(newRole.members)
                                            ..removeWhere((e) => e.id == m.id);

                                          newRole = newRole.copyWith(members: newMembers);

                                          _filteredMembers = newRole.members;
                                        });
                                      }
                                    );
                                  }),
                                ],
                              ),
                          ],
                        ),
                      )
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ServiceUpdater(
                      request: () => RoleManagementApi().createRole(newRole),
                      onSuccess: () {
                        Navigator.pop(context, newRole);
                      },
                      builder: (trigger, state, errorMessage) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton.icon(
                                onPressed: (state != ServiceUpdatorState.loading &&
                                  _nameController.text.trim().isNotEmpty)
                                  ? () => trigger()
                                  : null,
                                icon: SvgPicture.asset(
                                  'assets/images/create.svg',
                                  height: 18,
                                  width: 18,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: Row(
                                  spacing: 10,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'สร้าง',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (state == ServiceUpdatorState.loading)
                                      CupertinoActivityIndicator(color: Colors.white)
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
                              Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
                                style: TextStyle(
                                    color: Colors.red
                                )
                              ) : SizedBox()
                            )
                          ],
                        );
                      },
                    )
                  ],
                ),
              ],
            )
          ),
        )
      ),
    );
  }
}
