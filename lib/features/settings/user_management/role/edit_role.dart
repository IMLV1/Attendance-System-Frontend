import 'package:attendance_system/services/role_management/role_management_model.dart';
import 'package:attendance_system/shared/widgets/utils/user_cancel_checkbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/head_bar/header.dart';
import '../../../../shared/widgets/utils/icon_text_button.dart';
import '../../../../shared/widgets/utils/separator_card.dart';

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
  late final TextEditingController _controller;
  late final String _originalValue;
  final FocusNode _focusNode = FocusNode();
  late Color _roleColor;

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _originalValue = widget.roleInfo.roleName;
    _controller = TextEditingController(text: _originalValue);
    _roleColor = widget.roleInfo.roleColor != null ? _hexToColor(widget.roleInfo.roleColor!) : const Color(0xFFFFA726);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------- save ----------
  void _finishEdit(String value) {
    final newValue = value.trim();
    if (newValue.isEmpty || newValue == _originalValue.trim()) return;
    _save(newValue);
  }

  void _save(String value) {
    final colorHex = _roleColor.toARGB32().toRadixString(16).substring(2).toUpperCase();

    debugPrint('name: $value');
    debugPrint('color: $colorHex');

    // TODO: call API
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'แก้ไข: ${widget.roleInfo.roleName}',
      ),
      content: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 15,
          ),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            spacing: 20,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFE3E3E3),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  spacing: 13,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// title
                    Row(
                      spacing: 6,
                      children: [
                        SvgPicture.asset(
                          'assets/images/tag.svg',
                          height: 15,
                          width: 15,
                        ),
                        Text('ตำแหน่ง'),
                      ],
                    ),
                    /// input + color
                    Row(
                      spacing: 13,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'กรุณาระบุตำแหน่ง',
                              hintStyle: TextStyle(
                                color: Colors.black38,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  _focusNode.requestFocus();
                                },
                                child: InkWell(
                                  customBorder: CircleBorder(),
                                  onTap: () {
                                    // TODO: cancel select
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      CupertinoIcons.xmark_circle_fill,
                                      size: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onSubmitted: _finishEdit,
                          ),
                        ),
                        /// color dot
                        InkWell(
                          customBorder: CircleBorder(),
                          onTap: () {
                            /// TODO: Color Pickup
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _roleColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFF606060),
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
              /// delete
              SeparatorCard(
                separatorPadding: EdgeInsets.only(left: 45, right: 15),
                children: [
                  IconTextButton(
                    arrow: false,
                    color: Colors.red,
                    icon: 'icon_delete.svg',
                    label: 'ลบตำแหน่ง',
                  ),
                ],
              ),
              /// Search bar + Add user
              Column(
                spacing: 6,
                children: [
                  /// Text
                  Row(
                    spacing: 6,
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon_user.svg',
                        height: 15,
                        width: 15,
                      ),
                      Text('สมาชิกในสังกัด (${widget.roleInfo.members.length})'),
                    ],
                  ),
                  Row(
                    spacing: 13,
                    children: [
                      /// Search bar
                      Expanded(
                        child: TextField(
                          // controller: _controller,
                          // onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
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
                      ),
                      /// Add User
                      InkWell(
                        customBorder: CircleBorder(),
                        onTap: () {},
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF7D7D7D),
                              width: 1,
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
                  )
                ],
              ),
              SeparatorCard(
                separatorPadding: EdgeInsetsGeometry.only(right: 15, left: 70),
                children: [
                  ...widget.roleInfo.members.map((m) {
                    return UserCancelCheckbox(
                      icon: Image.network(m.avatarUrl, fit: BoxFit.cover,),
                      title: m.thName,
                      subTitle: m.enName,
                      checkBox: false,
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
