import 'dart:io';

import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/ios_menu.dart';
import 'package:attendance_system/shared/widgets/utils/native_select/native_file_input_stub.dart'
    if (dart.library.js_interop) 'package:attendance_system/shared/widgets/utils/native_select/native_file_input_web.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

/// ตัวเลือกไฟล์แนบตัวกลางของทั้งแอป
///
/// 🚩 (2026-08-27) เดิมโค้ดชุดนี้ถูกก๊อปไว้ 4 ที่ (`leave_request` /
/// `time_request` × `create` / `resend`) ที่ละ ~90 บรรทัด และแต่ละที่วาด
/// **เมนูของตัวเอง** ขึ้นมาทับสิ่งที่ OS มีให้อยู่แล้ว
///
/// สองปัญหาที่ตามมา:
///
/// 1. ปุ่ม "ถ่ายรูป" โผล่บน web/desktop ที่ไม่มีกล้อง กดแล้วไม่เกิดอะไร
/// 2. บนเว็บ เราไปบังชีตของระบบทิ้ง — iOS Safari เด้ง
///    Photo Library / Take Photo / Choose Files ให้เองอยู่แล้วถ้าเจอ
///    `<input type="file">` ธรรมดา ซึ่ง `file_picker` สร้างให้อยู่แล้ว
///
/// ทางที่ถูกของแต่ละแพลตฟอร์มจึงไม่เหมือนกัน:
///
/// | แพลตฟอร์ม | ทำอะไร |
/// |---|---|
/// | web | เรียก file picker ตรงๆ ปล่อยให้เบราว์เซอร์/OS เด้งชีตเอง |
/// | iOS / Android | เมนูลอยยึดกับปุ่มที่กด (ทรงเดียวกับ menu ของ iOS) |
/// | macOS / Windows / Linux | ไดอะล็อกเลือกไฟล์ของ OS ตรงๆ (ไม่มีกล้อง) |
///
/// 🚩 (รอบสอง) เคยทำเป็น `CupertinoActionSheet` เลื่อนขึ้นจากขอบล่าง ซึ่งเป็น
/// control ของ iOS จริงแต่**คนละตัว**กับที่ Safari ใช้ — ของ Safari เป็นเมนูลอย
/// ยึดกับปุ่ม (UIMenu) ไม่ใช่ action sheet และบน iPad การเลื่อนขึ้นจากล่างยัง
/// ผิดสำนวนด้วย (ควรเป็น popover ชี้ที่ปุ่ม) จึงเปลี่ยนมาใช้ `MenuAnchor` ที่
/// ยึดกับ child ของตัวเองอยู่แล้ว ได้ตำแหน่งถูกทั้งสองเครื่องโดยไม่ต้องแยกโค้ด
///
/// **บนแอป native ไม่มีชีตสำเร็จรูปของ OS ที่รวมรูป+กล้อง+ไฟล์ไว้ด้วยกัน**
/// แม้แต่ Safari ก็ประกอบเองจาก UIAlertController เราจึงยังต้องมีสามตัวเลือกเอง
/// ต่างกันแค่ไปวาดด้วย widget ของแพลตฟอร์มแทนการ์ดที่ออกแบบเอง
class AttachmentPicker {

  const AttachmentPicker._();

  /// ชนิดไฟล์ที่ระบบรับ
  ///
  /// ต้องมีนามสกุลรูปอยู่ด้วยเสมอ ไม่ใช่แค่ pdf — เพราะบนเว็บค่านี้กลายเป็น
  /// attribute `accept` ของ `<input>` และ **iOS Safari ใช้มันตัดสินว่าจะโชว์
  /// ตัวเลือกไหนในชีต** ถ้าเหลือแค่ `.pdf` จะได้แค่ "Choose Files" ไม่มี
  /// Photo Library / Take Photo (ของเดิมปุ่ม "เลือกไฟล์" จำกัด `['pdf']` ล้วน)
  static const allowedExtensions = [
    'pdf', 'jpg', 'jpeg', 'png', 'heic', 'heif', 'webp',
  ];

  /// แพลตฟอร์มนี้มีกล้องให้เรียกไหม
  static bool get hasCamera => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  // ── การหยิบไฟล์จริง ────────────────────────────────────────────────────

  static Future<PlatformFile?> _pickFrom(_Source source) async {
    switch (source) {
      case _Source.gallery:
        return _pickFromCamera(ImageSource.gallery);
      case _Source.camera:
        return _pickFromCamera(ImageSource.camera);
      case _Source.files:
        return pickFiles();
    }
  }

  static Future<PlatformFile?> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }

  /// รูปจากคลัง/กล้องไม่มีชื่อไฟล์ที่สื่ออะไร (บางเครื่องเป็น `image_picker_xxx`)
  /// จึงตั้งชื่อใหม่เป็น `IMG_xxxxx` ให้เหมือนกันทุกที่ — ย้ายมาจากที่ที่ก๊อปซ้ำเดิม
  static Future<PlatformFile?> _pickFromCamera(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;

    final bytes = await image.readAsBytes();
    return PlatformFile(
      name: 'IMG_${Utils.generateRandomNumber(5)}${p.extension(image.name)}',
      size: bytes.length,
      path: kIsWeb ? null : image.path,
      bytes: bytes,
    );
  }
}

enum _Source { gallery, camera, files }

/// ปุ่ม "อัพโหลดไฟล์" พร้อมเมนูเลือกแหล่งไฟล์ที่**ยึดกับตัวปุ่มเอง**
///
/// เป็น widget ไม่ใช่ฟังก์ชัน เพราะตำแหน่งเมนูต้องอ้างอิง render object ของปุ่ม
/// `MenuAnchor` ทำให้อยู่แล้วโดยไม่ต้องส่ง GlobalKey หรือคำนวณพิกัดเอง
///
/// บนเว็บ/desktop ไม่มีเมนู กดแล้วเปิดตัวเลือกไฟล์ของ OS ตรงๆ (ดู [AttachmentPicker])
class AttachmentPickerButton extends StatefulWidget {

  const AttachmentPickerButton({super.key, required this.onPicked});

  final void Function(PlatformFile file) onPicked;

  @override
  State<AttachmentPickerButton> createState() => _AttachmentPickerButtonState();
}

class _AttachmentPickerButtonState extends State<AttachmentPickerButton> {

  /// 🚩 (2026-08-27) ต้องถือ controller ไว้เองเพื่อ **ปิดเมนู** ตอนเลือกเสร็จ
  ///
  /// เมนูของ `MenuAnchor` วาดอยู่ใน overlay ไม่ใช่ route — เดิมเผลอปิดด้วย
  /// `Navigator.of(context).pop()` ซึ่งไปเด้ง route ของ "หน้า" ออกแทน
  /// กดเลือกไฟล์ทีเดียวเลยหลุดกลับไปหน้าก่อนหน้า
  final MenuController _menuController = MenuController();

  bool get _usesMenu => AttachmentPicker.hasCamera;

  @override
  Widget build(BuildContext context) {
    if (!_usesMenu) {
      final button = _button(onPressed: () async {
        final file = await AttachmentPicker.pickFiles();
        if (file != null) widget.onPicked(file);
      });

      // บนเว็บวาง <input type="file"> จริงทับปุ่ม เพื่อให้ผู้ใช้แตะ element นั้น
      // ตรงๆ — Safari จะได้ยึดเมนูของ OS ไว้กับปุ่ม แทนที่จะไปโผล่ตำแหน่ง default
      // (ปุ่ม Flutter ข้างล่างยังทำงานอยู่ เผื่อเบราว์เซอร์ที่ฝัง input ไม่ได้)
      return buildNativeFileInput(
            extensions: AttachmentPicker.allowedExtensions,
            onPicked: widget.onPicked,
            child: button,
          ) ??
          button;
    }

    return MenuAnchor(
      controller: _menuController,
      // iOS วางเมนูใต้ตัวควบคุมโดยเว้นช่องเล็กน้อย
      alignmentOffset: const Offset(0, 6),
      style: IosMenu.menuStyle,
      menuChildren: [
        IosMenu(
          children: [
            _item(_Source.gallery, 'photos_upload.svg', 'คลังรูปภาพ'),
            _item(_Source.camera, 'camera_upload.svg', 'ถ่ายรูป'),
            _item(_Source.files, 'file_upload.svg', 'เลือกไฟล์'),
          ],
        ),
      ],
      builder: (context, controller, child) => _button(
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }

  Widget _item(_Source source, String icon, String label) {
    return IosMenuItem(
      icon: icon,
      label: label,
      onTap: () async {
        // เมนูอยู่ใน overlay ไม่ใช่ route — ปิดด้วย controller เท่านั้น
        // (เคยเผลอใช้ Navigator.pop() แล้วมันไปเด้งหน้าออกแทน)
        _menuController.close();
        final file = await AttachmentPicker._pickFrom(source);
        if (file != null) widget.onPicked(file);
      },
    );
  }

  Widget _button({required VoidCallback onPressed}) {
    return IconTextButton(
      icon: 'icon_upload_file.svg',
      label: 'อัพโหลดไฟล์',
      color: AppColors.primaryColor,
      onPressed: onPressed,
    );
  }

}
