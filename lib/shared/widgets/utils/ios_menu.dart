import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// การ์ดเมนูทรง iOS ที่ใช้ร่วมกันทั้งแอป
///
/// 🚩 (2026-08-27) อ้างอิงจากเมนูจริงที่ Safari เด้งให้ตอนแตะ `<input type="file">`
/// (จับภาพเทียบบน iPhone/iPad simulator แล้วไล่ปรับทีละจุด)
///
/// แยกออกมาเป็นตัวกลางเพราะแอปมีเมนูแบบ `MenuAnchor` อยู่ 7 จุด (แนบไฟล์ 1 +
/// เลือกเดือน/ปี 6) ซึ่งเดิมหน้าตาไม่เหมือนกันสักที่ ถ้าปล่อยให้แต่ละที่แต่งเอง
/// จะเพี้ยนกันอีกรอบทันทีที่มีคนแก้ที่เดียว
///
/// สิ่งที่ต้องรู้ก่อนใช้:
///
/// - ต้องตั้ง [menuStyle] ให้กับ `MenuAnchor` ด้วย ไม่งั้น Material จะวาดพื้นหลัง
///   กับเงาของมันเองทับ และ clip มุมเป็นเหลี่ยม
/// - พื้นหลังต้องโปร่งพอให้เห็น `BackdropFilter` ทำงาน (เคยตั้ง 95% ทึบแล้ว blur
///   เสียเปล่ามองไม่เห็นเลย)
class IosMenu extends StatelessWidget {

  const IosMenu({
    super.key,
    required this.children,
    this.width,
    this.maxHeight,
  });

  /// แถวในเมนู — ใช้ [IosMenuItem] เพื่อให้ระยะห่างและสีตรงกันทุกที่
  final List<Widget> children;

  final double? width;

  /// เมนูที่รายการยาว (เช่นเลือกปี) ต้องจำกัดความสูงแล้วให้เลื่อนเอา
  final double? maxHeight;

  static const double radius = 13;

  /// สี label ของ iOS โหมดสว่าง — ไม่ใช่ดำสนิท
  static const Color labelColor = Color(0xFF1C1C1E);

  /// ปิดหน้าตา default ของ Material ทิ้งให้หมด แล้วปล่อยให้ [IosMenu] วาดเอง
  static const MenuStyle menuStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(0),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
    visualDensity: VisualDensity.standard,
    // ต้องตรงกับ ClipRRect ข้างใน ไม่งั้น Material clip ทับจนมุมกลับเป็นเหลี่ยม
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(const _Separator());
      rows.add(children[i]);
    }

    Widget content = Column(mainAxisSize: MainAxisSize.min, children: rows);
    if (maxHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: SingleChildScrollView(primary: false, child: content),
      );
    }

    return Container(
      width: width,
      constraints: const BoxConstraints(minWidth: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(color: Color(0x24000000), blurRadius: 24, offset: Offset(0, 8)),
          BoxShadow(color: Color(0x14000000), blurRadius: 60, offset: Offset(0, 20)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: const Color(0xD6F2F2F2),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) => Container(
        height: 0.5,
        // separator ของ iOS จางมาก ไม่ใช่เส้นทึบแบบ Material Divider
        color: const Color(0x1F3C3C43),
      );
}

/// หนึ่งแถวในเมนู — สูง 44 ไอคอนซ้าย ข้อความ 17pt ตามสำนวน iOS
class IosMenuItem extends StatelessWidget {

  const IosMenuItem({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.iconData,
    this.selected = false,
  }) : assert(icon == null || iconData == null,
            'เลือกไอคอนได้ทางเดียว: svg ของแอป หรือ IconData');

  final String label;
  final VoidCallback onTap;

  /// ชื่อไฟล์ svg ใน assets/images (ไม่ใส่ก็ได้ เช่นเมนูเลือกเดือน/ปี)
  final String? icon;

  /// ไอคอนจากชุดของ Material — ใช้เมื่อยังไม่มี svg ของแอปสำหรับความหมายนั้น
  /// (ใส่พร้อม [icon] ไม่ได้ ให้เลือกอย่างใดอย่างหนึ่ง)
  final IconData? iconData;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        // iOS ไฮไลต์ทั้งแถวเป็นเทาจางตอนกด ไม่มี ripple แผ่
        splashFactory: NoSplash.splashFactory,
        highlightColor: const Color(0x1A000000),
        hoverColor: const Color(0x0D000000),
        onTap: onTap,
        child: Container(
          height: 44,
          color: selected ? const Color(0x0D000000) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (icon != null) ...[
                SvgPicture.asset(
                  'assets/images/$icon',
                  width: 21,
                  height: 21,
                  colorFilter: const ColorFilter.mode(
                    IosMenu.labelColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
              ] else if (iconData != null) ...[
                Icon(iconData, size: 21, color: IosMenu.labelColor),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    color: IosMenu.labelColor,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
