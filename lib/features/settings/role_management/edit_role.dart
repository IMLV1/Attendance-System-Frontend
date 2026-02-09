import 'package:attendance_system/services/role_management/role_management_model.dart';
import 'package:attendance_system/shared/widgets/utils/user_cancel_checkbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../services/role_management/role_management_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/head_bar/header.dart';
import '../../../shared/widgets/utils/icon_text_button.dart';
import '../../../shared/widgets/utils/separator_card.dart';

class EditRole extends StatefulWidget {
  final RoleSystem roleInfo;

  const EditRole({
    super.key,
    required this.roleInfo,
  });

  @override
  State<EditRole> createState() => _EditRoleState();
}

class _EditRoleState extends State<EditRole> {
  late RoleSystem _role;

  late TextEditingController _nameController;
  late TextEditingController _searchController;

  late String _originalValue;
  late Color _roleColor;

  final FocusNode _focusNode = FocusNode();
  final RoleManagementService _service = RoleManagementService();

  List<Member> _filteredMembers = [];

  // ---------- utils ----------
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  // ---------- lifecycle ----------
  @override
  void initState() {
    super.initState();

    _role = widget.roleInfo.copyWith(
      members: List.from(widget.roleInfo.members),
    );

    _originalValue = _role.roleName;

    _nameController = TextEditingController(text: _originalValue);
    _searchController = TextEditingController();

    _roleColor = _role.roleColor != null
        ? _hexToColor(_role.roleColor!)
        : const Color(0xFFFFA726);

    _filteredMembers = _role.members;

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _validateName();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------- validate role name ----------
  void _validateName() {
    final value = _nameController.text.trim();

    if (value.isEmpty) {
      // ❌ ห้ามว่าง → คืนค่าเดิม
      _nameController.text = _originalValue;
    } else if (value != _originalValue) {
      _finishEdit(value);
    }
  }

  // ---------- update role ----------
  void _finishEdit(String value) {
    final newValue = value.trim();

    if (newValue.isEmpty || newValue == _originalValue) return;

    _save(newValue);
  }

  Future<void> _save(String value) async {
    try {
      final colorHex = _roleColor.toARGB32()
          .toRadixString(16)
          .substring(2)
          .toUpperCase();

      await _service.updateRole(
        roleId: _role.id,
        name: value,
        color: colorHex,
      );

      final updated = _role.copyWith(
        roleName: value,
        roleColor: colorHex,
      );

      setState(() {
        _role = updated;
        _originalValue = value;
      });

      Navigator.of(context).pop(updated);
    } catch (_) {
      // TODO: show error snackbar
    }
  }


  // ---------- search member ----------
  void _onSearchChanged(String value) {
    final key = value.trim().toLowerCase();

    setState(() {
      _filteredMembers = key.isEmpty
          ? _role.members
          : _role.members.where((m) =>
      m.thName.toLowerCase().contains(key) ||
          m.enName.toLowerCase().contains(key),
      ).toList();
    });
  }


  // ---------- delete member ----------
  Future<void> _removeMember(String memberId) async {
    await _service.deleteMember(
      roleId: _role.id,
      memberId: memberId,
    );

    setState(() {
      final updatedMembers =
      _role.members.where((m) => m.id != memberId).toList();

      _role = _role.copyWith(members: updatedMembers);
      _filteredMembers = updatedMembers;
    });
  }

  Future<void> _deleteRole() async {
    await _service.deleteRole(roleId: _role.id);

    if (mounted) {
      Navigator.of(context).pop(true); // กลับหน้าเดิม + บอกว่าลบแล้ว
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'แก้ไข: ${_role.roleName}',
      ),
      content: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            spacing: 20,
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
                              hintText: 'กรุณาระบุตำแหน่ง',
                              hintStyle: const TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
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
                            onSubmitted: _finishEdit,
                          ),
                        ),
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            /// TODO: Select Color
                          },
                          child: Container(
                            width: 28,
                            height: 28,
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
              SeparatorCard(
                separatorPadding:
                const EdgeInsets.only(left: 45, right: 15),
                children: [
                  IconTextButton(
                    arrow: false,
                    color: Colors.red,
                    icon: 'icon_delete.svg',
                    label: 'ลบตำแหน่ง',
                    onPressed: () {
                      /// TODO: Delete role
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
                  Row(
                    spacing: 13,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                            const EdgeInsets.symmetric(
                                vertical: 13, horizontal: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                color: Color(0xFF7D7D7D),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                color: Color(0xFF7D7D7D),
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
                                const Text(
                                  'ค้นหาตำแหน่ง...',
                                  style: TextStyle(
                                    color: Color(0xFF7D7D7D),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {},
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF7D7D7D),
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/images/icon_add_user.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /// ===== Member list =====
              if (_filteredMembers.isNotEmpty)
                SeparatorCard(
                  separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 70),
                  children: [
                    ..._filteredMembers.map((m) {
                      return UserCancelCheckbox(
                        icon: Image.network(m.avatarUrl, fit: BoxFit.cover,),
                        title: m.thName,
                        subTitle: m.enName,
                        checkBox: false,
                        onCancel: () => _removeMember(m.id),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
