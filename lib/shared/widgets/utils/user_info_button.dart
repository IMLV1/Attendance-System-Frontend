import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/widgets/utils/role_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserInfoButton extends StatelessWidget {

  final Widget icon;
  final String title;
  final String? subTitle;
  final List<Role> roles;
  final bool arrow;
  final VoidCallback? onPressed;
  final Color titleColor;
  final Color subTitleColor;
  final double? fontTitle;
  final double? fontSub;
  final FontWeight? fontWeightTitle;

  const UserInfoButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.arrow = true,
    this.onPressed,
    required this.roles,
    this.titleColor = Colors.black,
    this.subTitleColor = const Color(0xFF7E7E7E),
    this.fontTitle = 14,
    this.fontSub = 10,
    this.fontWeightTitle = FontWeight.normal
  });

  @override
  Widget build(BuildContext context) {

    // 🚩 (2026-08-26) เดิมเป็น `onPressed ?? () {}` — ไม่ส่ง callback มาก็ยังเป็น
    // ปุ่มที่กดได้อยู่ดี แค่กดแล้วไม่เกิดอะไร ผู้ใช้เห็น ripple เห็นลูกศร แล้วคิดว่า
    // ตัวเองกดพลาด
    //
    // ตอนนี้ทุกที่ที่เรียกส่ง callback มาครบ (เช็คแล้ว 7 จุด) จึงให้ `null`
    // แปลว่า "แสดงผลอย่างเดียว" ได้ — ใช้ในโหมด master-detail ของ
    // /personnel-info ที่การ์ดคนเป็นแค่ป้ายบอกว่ากำลังดูใครอยู่ ไม่ใช่ตัวเลือกคน
    if (onPressed == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: _row(context),
      );
    }

    return ElevatedButton(

      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.all(0),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
      ),

      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: _row(context),
      ),
    );
  }

  /// เนื้อในของการ์ด — แยกออกมาเพื่อให้โหมดกดได้กับโหมดแสดงผลอย่างเดียว
  /// ใช้ layout ชุดเดียวกันเป๊ะ ไม่ต้องกลัวว่าสองทางจะหน้าตาเพี้ยนกัน
  Widget _row(BuildContext context) {
    return Row(
          spacing: 10,
          children: [
            Expanded(
              flex: 3,
              child: Row(
              spacing: 13,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: icon,
                ),

                Expanded( // 👈 gives bounded width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: fontTitle, color: titleColor, fontWeight: fontWeightTitle),
                        softWrap: true,
                      ),

                      if (subTitle != null)
                        Text(
                          subTitle!,
                          style: TextStyle(fontSize: fontSub, color: subTitleColor),
                          softWrap: true,
                        ),
                    ],
                  ),
                ),
              ],
            )
            ),
          if (roles.isNotEmpty)
            Expanded(
              flex: 2,
              // 🚩 (2026-08-27) เดิมเป็น IntrinsicHeight + Container(width: 1)
              // เพื่อให้เส้นคั่นสูงเท่าบล็อกป้ายตำแหน่ง แต่ IntrinsicHeight ถาม
              // ความสูง "โดยธรรมชาติ" ของลูก ซึ่ง LayoutBuilder (ที่ RoleChips
              // ใช้วัดความกว้างที่มี) ตอบไม่ได้ → ทั้งลิสต์พังทั้งแถบ
              //
              // ใช้ border ซ้ายแทน — เส้นสูงเท่ากล่องอยู่แล้วโดยไม่ต้องถาม
              // intrinsic และได้ผลเหมือนเดิมเป๊ะ เพราะใน Row เดิมมีลูกแค่
              // ป้ายตำแหน่งตัวเดียว ความสูง intrinsic จึงเท่ากับป้ายอยู่แล้ว
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey)),
                ),
                child: RoleChips(roles: roles),
              ),
            ),
            if (arrow) SizedBox(
              height: 10,
              width: 10,
              child: SvgPicture.asset(
                'assets/images/icon_next.svg',
              )
            ),
          ],
    );
  }

}