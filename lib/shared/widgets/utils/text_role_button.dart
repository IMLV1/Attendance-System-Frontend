import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/widgets/utils/role_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextRoleButton extends StatelessWidget {

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final List<Role> roles;
  final bool disable;
  final Widget icon;

  const TextRoleButton({
    super.key,
    required this.label,
    required this.roles,
    this.disable = false,
    this.onPressed,
    this.color = Colors.black,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: disable ? null : onPressed ?? () {},

        style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.all(0),
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
        ),

        child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    spacing: 10,
                    children: [
                      SizedBox(
                          height: 20,
                          width: 20,
                          child: icon
                      ),
                      // 🚩 (2026-08-27) เดิมไม่ได้ห่อ Flexible — `overflow: ellipsis`
                      // ไม่ทำงานถ้า Text ยังได้ความกว้างเท่าที่ตัวเองอยาก
                      // ป้ายยาวๆ จึงดัน Row จนล้นออกนอก Expanded
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            color: color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                ),
                Flexible(
                  flex: 3,
                  child: Row(
                    spacing: 3,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: RoleChips(
                          roles: roles,
                          alignment: WrapAlignment.end,
                        ),
                      ),
                      if (!disable) const SizedBox(width: 4),
                      if (!disable)
                        SizedBox(
                          height: 10,
                          width: 10,
                          child: SvgPicture.asset(
                            'assets/images/icon_next.svg',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
        )
    );
  }
}