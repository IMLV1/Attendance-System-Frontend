import 'dart:io';

import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
/// | iOS | `CupertinoActionSheet` — ตัวเดียวกับที่ Safari ใช้ (`UIAlertController`) |
/// | Android | bottom sheet ของ Material |
/// | macOS / Windows / Linux | ไดอะล็อกเลือกไฟล์ของ OS ตรงๆ (ไม่มีกล้อง) |
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

  /// เปิดตัวเลือกไฟล์ตามสำนวนของแพลตฟอร์มนั้น — คืน `null` ถ้าผู้ใช้ยกเลิก
  static Future<PlatformFile?> pick(BuildContext context) async {
    // เว็บ: อย่าวาดเมนูเอง ชีตของ OS ดีกว่าและได้มาฟรี
    if (kIsWeb) return _pickFromFiles();

    if (Platform.isIOS) return _iosSheet(context);
    if (Platform.isAndroid) return _androidSheet(context);

    // desktop ไม่มีกล้องและไม่มีคลังรูปแยก — ไดอะล็อกเดียวจบ
    return _pickFromFiles();
  }

  // ── ชีตของแต่ละแพลตฟอร์ม ───────────────────────────────────────────────

  static Future<PlatformFile?> _iosSheet(BuildContext context) async {
    final source = await showCupertinoModalPopup<_Source>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          _cupertinoAction(context, _Source.gallery, 'photos_upload.svg', 'คลังรูปภาพ'),
          _cupertinoAction(context, _Source.camera, 'camera_upload.svg', 'ถ่ายรูป'),
          _cupertinoAction(context, _Source.files, 'file_upload.svg', 'เลือกไฟล์'),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
      ),
    );
    return _pickFrom(source);
  }

  static CupertinoActionSheetAction _cupertinoAction(
    BuildContext context,
    _Source source,
    String icon,
    String label,
  ) {
    return CupertinoActionSheetAction(
      onPressed: () => Navigator.of(context).pop(source),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          SvgPicture.asset('assets/images/$icon', width: 20, height: 20),
          Text(label),
        ],
      ),
    );
  }

  static Future<PlatformFile?> _androidSheet(BuildContext context) async {
    final source = await showModalBottomSheet<_Source>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _materialTile(context, _Source.gallery, 'photos_upload.svg', 'คลังรูปภาพ'),
            _materialTile(context, _Source.camera, 'camera_upload.svg', 'ถ่ายรูป'),
            _materialTile(context, _Source.files, 'file_upload.svg', 'เลือกไฟล์'),
          ],
        ),
      ),
    );
    return _pickFrom(source);
  }

  static Widget _materialTile(
    BuildContext context,
    _Source source,
    String icon,
    String label,
  ) {
    return ListTile(
      leading: SvgPicture.asset('assets/images/$icon', width: 22, height: 22),
      title: Text(label, style: const TextStyle(color: AppColors.blackTextColor)),
      onTap: () => Navigator.of(context).pop(source),
    );
  }

  // ── การหยิบไฟล์จริง ────────────────────────────────────────────────────

  static Future<PlatformFile?> _pickFrom(_Source? source) async {
    switch (source) {
      case _Source.gallery:
        return _pickFromCamera(ImageSource.gallery);
      case _Source.camera:
        return _pickFromCamera(ImageSource.camera);
      case _Source.files:
        return _pickFromFiles();
      case null:
        return null; // ผู้ใช้ปิดชีตทิ้ง
    }
  }

  static Future<PlatformFile?> _pickFromFiles() async {
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
