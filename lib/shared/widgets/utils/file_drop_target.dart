import 'dart:io';

import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/attachment_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// พื้นที่ที่ลากไฟล์จากนอกแอปมาวางได้ (Phase 5.2)
///
/// 🚩 (2026-08-27) นี่คือ "ท่า native ของ desktop/web" ตัวจริงที่แอปยังไม่เคยมี
/// — บนเครื่องคอม การลากไฟล์จาก Finder/Explorer มาวางเป็นวิธีที่คนใช้เป็น
/// สัญชาตญาณ ก่อนหน้านี้แนบไฟล์ได้ทางเดียวคือกดปุ่มแล้วเปิดไดอะล็อก
///
/// ปิดตัวเองบน iOS/Android เพราะไม่มี "เคอร์เซอร์ที่ถือไฟล์อยู่" ให้ลากมาวาง
/// (iPadOS มี drag & drop ระหว่างแอปจริง แต่ `desktop_drop` ไม่รองรับ — ถ้าจะทำ
/// ต้องใช้ `super_drag_and_drop` ซึ่งพ่วง Rust toolchain เข้ามาใน build ทุก
/// platform จึงไม่คุ้มกับฟีเจอร์เดียว)
///
/// ใช้ `desktop_drop` ไม่ใช่ `super_drag_and_drop` ตามที่จดไว้ในแผนเดิม เพราะ
/// ตัวหลังต้องมี Rust ตอน build (cargokit) = ใครก็ตามที่ clone repo แล้ว build
/// ไม่ผ่านทันทีถ้าไม่มี Rust ส่วน `desktop_drop` เป็น platform channel ล้วนๆ
class FileDropTarget extends StatefulWidget {

  const FileDropTarget({
    super.key,
    required this.child,
    required this.onPicked,
  });

  final Widget child;

  /// เรียกทีละไฟล์ ให้ signature ตรงกับ [AttachmentPickerButton] เพื่อให้ call
  /// site ส่ง callback ตัวเดียวกันเข้าทั้งสองทางได้เลย
  final void Function(PlatformFile file) onPicked;

  /// ลากมาวางได้เฉพาะที่มีเมาส์/trackpad จริง
  static bool get isSupported => kIsWeb || !(Platform.isIOS || Platform.isAndroid);

  /// ไฟล์ชื่อนี้แนบได้ไหม — เงื่อนไขเดียวกับ `accept` ของตัวเลือกไฟล์
  ///
  /// ทางเข้าคนละทางต้องรับของชนิดเดียวกัน ไม่งั้นผู้ใช้จะลากไฟล์ที่ปุ่มไม่ยอมให้
  /// เลือกเข้ามาได้ แล้วไปพังเอาตอน backend ปฏิเสธ
  static bool accepts(String fileName) {
    final ext = p.extension(fileName).replaceFirst('.', '').toLowerCase();
    return AttachmentPicker.allowedExtensions.contains(ext);
  }

  @override
  State<FileDropTarget> createState() => _FileDropTargetState();
}

class _FileDropTargetState extends State<FileDropTarget> {

  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    if (!FileDropTarget.isSupported) return widget.child;

    return DropTarget(
      onDragEntered: (_) => setState(() => _hovering = true),
      onDragExited: (_) => setState(() => _hovering = false),
      onDragDone: _onDrop,
      child: Stack(
        children: [
          widget.child,

          // กรอบไฮไลต์ตอนถือไฟล์ลอยอยู่เหนือพื้นที่ — ต้องไม่กินทัช ไม่งั้นปุ่ม
          // ข้างล่างจะกดไม่ได้ในเฟรมที่ยังไม่ทัน setState กลับ
          if (_hovering)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'วางไฟล์ที่นี่',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onDrop(DropDoneDetails details) async {
    setState(() => _hovering = false);

    for (final item in details.files) {
      // โฟลเดอร์ลากมาวางได้เหมือนกัน แต่แนบเป็นไฟล์แนบไม่ได้ — ข้ามเงียบๆ
      if (item is DropItemDirectory) continue;

      final name = item.name.isNotEmpty ? item.name : p.basename(item.path);
      if (!FileDropTarget.accepts(name)) continue;

      final bytes = await item.readAsBytes();
      if (!mounted) return;

      widget.onPicked(PlatformFile(
        name: name,
        size: bytes.length,
        // บนเว็บ path เป็น blob URL ใช้อ่านไฟล์ในเครื่องไม่ได้ ต้องเป็น null
        // ให้เหมือนที่ `file_picker` คืนมา ไม่งั้นโค้ดฝั่งอัพโหลดจะเลือกทางผิด
        path: kIsWeb ? null : item.path,
        bytes: bytes,
      ));
    }
  }
}
