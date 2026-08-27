import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';

/// โครงสองคอลัมน์สำหรับหน้าที่เป็น "รายการ + รายละเอียดของรายการที่เลือก"
///
/// 🚩 (Phase 6, 2026-08-27) เกิดจากการแยกโค้ดที่เขียนไว้ใน `personnel_info.dart`
/// ตอน Phase 2 ออกมา ตอนนั้นมีที่ใช้ที่เดียวเลยเขียนคาไว้ในหน้านั้น พอ
/// `user-management` กับ `role-management` ต้องการรูปทรงเดียวกันก็จะกลายเป็น
/// โค้ดชุดเดิมสามชุด — ที่ไหนแก้ไม่ครบก็เพี้ยนกันเงียบๆ แบบที่เคยเกิดกับ
/// `personnel_statistic.dart` มาแล้ว
///
/// ตัวหน้าที่เรียกยังต้องตัดสินใจเองว่าจะใช้เมื่อไหร่ (ปกติคือ
/// `if (!Responsive.isCompact(context))`) เพราะบนมือถือแต่ละหน้าเลือกทางลง
/// ไม่เหมือนกัน — บางหน้า push หน้าใหม่ บางหน้าเปิด popup
class MasterDetailScaffold extends StatelessWidget {

  /// ข้อความบนแถบหัว — แถบหัวเป็นของทั้งหน้า ไม่ใช่ของคอลัมน์ใดคอลัมน์หนึ่ง
  final String title;

  /// คอลัมน์ซ้าย: รายการที่กดเลือกได้ ต้องไฮไลต์รายการที่เลือกอยู่เองด้วย
  /// ไม่งั้นผู้ใช้จะไม่รู้ว่าเนื้อหาทางขวาเป็นของใคร
  final Widget master;

  /// คอลัมน์ขวา: เนื้อหาของรายการที่เลือก — `null` เมื่อยังไม่ได้เลือกอะไร
  final Widget? detail;

  /// ข้อความตอนยังไม่ได้เลือก ควรบอกว่าให้ไปกดที่ไหน ไม่ใช่แค่ "ไม่มีข้อมูล"
  final String emptyLabel;

  /// 🚩 360 มาจากหน้าข้อมูลบุคลากร — แคบกว่านี้ป้ายตำแหน่งใน `UserInfoButton`
  /// จะตัดขึ้นบรรทัดใหม่จนแถวสูงไม่เท่ากัน หน้าที่รายการเรียบกว่านั้นลดได้
  final double masterWidth;

  /// ระยะขอบรอบคอลัมน์ซ้าย — ค่าเริ่มต้นเว้นบนมากกว่าล่างให้รายการไม่ชนแถบหัว
  final EdgeInsets masterPadding;

  const MasterDetailScaffold({
    super.key,
    required this.title,
    required this.master,
    required this.detail,
    required this.emptyLabel,
    this.masterWidth = 360,
    this.masterPadding = const EdgeInsets.fromLTRB(10, 20, 10, 10),
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      fullWidth: true,
      header: Header.subHeader(context, title: title),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: masterWidth,
                child: Padding(padding: masterPadding, child: master),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: detail ??
                    Center(
                      child: Text(
                        emptyLabel,
                        style: const TextStyle(color: Color(0xFF7F7F7F)),
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
