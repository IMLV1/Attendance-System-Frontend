import 'package:attendance_system/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {

  final Widget content;
  final AppBar? header;
  final bool hideNavigation;

  /// ปล่อยให้เนื้อหากินความกว้างเต็มจอ (สำหรับหน้าที่จัด layout เองอยู่แล้ว
  /// เช่นหน้าที่แบ่งเป็นสองคอลัมน์)
  final bool fullWidth;

  /// ความกว้างสูงสุดของเนื้อหาบนจอกว้าง — ไม่มีผลถ้า [fullWidth] เป็น true
  ///
  /// (Phase 3) เลือกด้วย `Responsive.widthFor(ContentShape.form/list/dashboard)`
  /// ตามรูปทรงของหน้า ค่า default คงพฤติกรรมเดิม (dashboard = 1100)
  final double maxWidth;

  const AppScaffold({
    super.key,
    this.hideNavigation = false,
    this.fullWidth = false,
    this.maxWidth = Responsive.contentMaxWidth,
    required this.content,
    this.header
  });

  @override
  Widget build(BuildContext context) {

    // 🚩 (2026-08-24) เดิมห่อทั้งหน้าด้วย MediaQuery ที่ตั้ง
    // `textScaler: TextScaler.linear(1.0 / 1.2 / 1.4)` ตามความกว้างจอ
    //
    // ผลคือบน iPad/desktop ตัวหนังสือทุกตัวถูกขยาย 20–40% แต่กล่อง/ปุ่ม/ความสูง
    // ที่ hardcode ไว้ไม่ได้ขยายตาม -> ข้อความล้นกล่องแทบทุกหน้า และยังทับกับ
    // textScaler ของระบบที่ผู้ใช้ตั้งเองด้วย
    // ตกลงกันแล้วว่าใช้ขนาดเดียวทุกจอ จึงถอดออกทั้งหมด

    // 🚩 (2026-08-25) เดิม `Align` ส่ง constraint แบบหลวมให้เนื้อหา (minHeight: 0)
    // วิดเจ็ตส่วนใหญ่ยืดเต็มความสูงเองอยู่แล้วเลยไม่มีใครสังเกต แต่
    // `SingleChildScrollView` หดตามเนื้อหาแทนที่จะเต็ม viewport หน้าที่เอา
    // scroll view เป็นชั้นนอกสุดจึงเพี้ยนบนจอสูงๆ (พื้นหลังไม่เต็มจอ /
    // เลื่อนแล้วเหมือนโดนตัด) — บังคับ minHeight เท่าความสูง viewport
    // เนื้อหาสั้นก็เต็มจอ เนื้อหายาวก็ยัง scroll ได้เหมือนเดิม
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: header,
      body: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // จำกัดความกว้างเนื้อหาบนจอกว้าง ไม่งั้นบรรทัดข้อความยาวข้ามจอจนอ่านยาก
              maxWidth: fullWidth ? double.infinity : maxWidth,
              minHeight:
                  constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
