import 'package:flutter/widgets.dart';

/// รูปแบบ layout ที่แอปรองรับ
///
/// 🚩 (2026-08-24) เดิมตัดสินจาก "ความกว้าง" อย่างเดียว (mobile <600,
/// tablet 600–1200, desktop >=1200) ซึ่งพลาดกับ iPad แทบทุกรุ่น:
/// - iPad Pro 11" แนวนอน = 1194 -> ไม่ถึง 1200 เลยไม่ได้ sidebar
/// - iPad แนวตั้ง = 834 -> ไม่ใช่ mobile เลยไม่ได้ปุ่ม hamburger ด้วย
///   = เข้าหน้า 'การตั้งค่าและการจัดการ' ไม่ได้เลยทั้งจอ
///
/// ตอนนี้ใช้ "แนวการวาง" ร่วมด้วยตามที่ตกลงกันไว้:
/// แนวนอนบนจอใหญ่ = sidebar, นอกนั้น = bottom navigation
/// รูปทรงของเนื้อหาหน้า — ใช้เลือกความกว้างสูงสุดผ่าน [Responsive.widthFor]
/// (Phase 3, ดู PHASE3_PAGE_DESIGN.md ข้อ 1)
enum ContentShape {
  /// หน้ากรอกฟอร์ม, หน้าตั้งค่าที่มีไม่กี่ช่อง
  form,

  /// รายการที่มีบรรทัดเดียวต่อแถว
  list,

  /// หน้าที่มีการ์ด/กราฟหลายก้อนวางเรียงกันจริงๆ
  dashboard,
}

enum LayoutMode {
  /// มือถือทุกแนว — bottom navigation
  compact,

  /// แท็บเล็ตแนวตั้ง — bottom navigation แต่มีพื้นที่กว้างกว่ามือถือ
  medium,

  /// แท็บเล็ตแนวนอน / desktop — sidebar
  expanded,
}

class Responsive {
  // Breakpoints (Material-ish)
  static const double mobileMax = 600;
  static const double tabletMax = 1200;

  /// ความสูงขั้นต่ำที่ยอมให้ใช้ sidebar ได้ในแนวนอน
  ///
  /// กันเคสมือถือจอใหญ่หมุนแนวนอน (เช่น iPhone Pro Max = 956x440) ซึ่งกว้างเกิน
  /// 600 และกว้างกว่าสูง แต่เตี้ยเกินกว่าจะเอา sidebar 300px มาแปะ
  static const double _sidebarMinHeight = 600;

  /// ความกว้างสูงสุดของเนื้อหาบนจอกว้าง — เกินกว่านี้ข้อความจะยาวจนอ่านยาก
  ///
  /// 🚩 (Phase 3, 2026-08-24) เดิมค่าเดียว 1100 ใช้กับทุกหน้าเหมือนกันหมด ทำให้
  /// หน้าที่มีของแค่ซ้ายสุด/ขวาสุด (ฟอร์ม, รายการบรรทัดเดียว) ยืดจนป้ายกับค่า
  /// ห่างกันเกินสายตากวาดถึง (ดู PHASE3_PAGE_DESIGN.md ข้อ 1) ตอนนี้แยกตาม
  /// "รูปทรง" ของหน้าแทน — เลือกด้วย [ContentShape] หรือใช้ค่าคงที่ตรงๆ ก็ได้
  static const double contentWidthForm = 600;
  static const double contentWidthList = 800;
  static const double contentWidthDashboard = 1100;

  /// ชื่อเดิมของ [contentWidthDashboard] — คงไว้เป็น alias กันโค้ดที่ยังไม่ได้
  /// migrate มาใช้ [ContentShape] พัง (ค่า default ของ `AppScaffold` ก็ยังอิงตัวนี้)
  static const double contentMaxWidth = contentWidthDashboard;

  static double widthFor(ContentShape shape) {
    switch (shape) {
      case ContentShape.form:
        return contentWidthForm;
      case ContentShape.list:
        return contentWidthList;
      case ContentShape.dashboard:
        return contentWidthDashboard;
    }
  }

  static LayoutMode mode(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    if (size.width < mobileMax) return LayoutMode.compact;
    if (size.width >= tabletMax) return LayoutMode.expanded;

    final isLandscape = size.width > size.height;
    return (isLandscape && size.height >= _sidebarMinHeight)
        ? LayoutMode.expanded
        : LayoutMode.medium;
  }

  /// โชว์ sidebar มั้ย — ถ้าไม่ แปลว่าใช้ bottom navigation แทน
  ///
  /// เป็นตัวเดียวกับที่ตัดสินว่าต้องมีปุ่ม hamburger ไปหน้าตั้งค่ารึเปล่า
  /// (sidebar มีทางเข้าหน้าตั้งค่าอยู่ที่แถบโปรไฟล์ด้านล่างแล้ว)
  static bool showSidebar(BuildContext context) =>
      mode(context) == LayoutMode.expanded;

  static bool isCompact(BuildContext context) =>
      mode(context) == LayoutMode.compact;

  // ── เดิม (ตัดสินด้วยความกว้างล้วน) — เหลือไว้ให้จุดที่สนใจ "ความกว้าง" จริงๆ
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileMax && width < tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMax;
}
