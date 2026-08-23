import 'package:attendance_system/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {

  final Widget content;
  final AppBar? header;
  final bool hideNavigation;

  /// ปล่อยให้เนื้อหากินความกว้างเต็มจอ (สำหรับหน้าที่จัด layout เองอยู่แล้ว
  /// เช่นหน้าที่แบ่งเป็นสองคอลัมน์)
  final bool fullWidth;

  const AppScaffold({
    super.key,
    this.hideNavigation = false,
    this.fullWidth = false,
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: header,
      body: Align(
        alignment: Alignment.topCenter,
        child: fullWidth
            ? content
            // จำกัดความกว้างเนื้อหาบนจอกว้าง ไม่งั้นบรรทัดข้อความยาวข้ามจอจนอ่านยาก
            : ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Responsive.contentMaxWidth),
                child: content,
              ),
      ),
    );
  }
}
