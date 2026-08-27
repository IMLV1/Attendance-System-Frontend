import 'dart:io';
import 'dart:ui';

import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
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
class AttachmentPickerButton extends StatelessWidget {

  /// มุมโค้งของเมนู iOS
  static const double _radius = 13;

  /// สี label ของ iOS โหมดสว่าง (ไม่ใช่ดำสนิท)
  static const Color _labelColor = Color(0xFF1C1C1E);

  const AttachmentPickerButton({super.key, required this.onPicked});

  final void Function(PlatformFile file) onPicked;

  bool get _usesMenu => AttachmentPicker.hasCamera;

  @override
  Widget build(BuildContext context) {
    if (!_usesMenu) {
      return _button(onPressed: () async {
        final file = await AttachmentPicker.pickFiles();
        if (file != null) onPicked(file);
      });
    }

    return MenuAnchor(
      // iOS วางเมนูใต้ตัวควบคุมโดยเว้นช่องเล็กน้อย
      alignmentOffset: const Offset(0, 6),

      // ปิดหน้าตา default ของ Material ทิ้งให้หมด แล้วไปวาดการ์ดเองใน
      // menuChildren — เพราะพื้นหลังแบบ iOS ต้องมี BackdropFilter ซึ่ง
      // MenuStyle ทำให้ไม่ได้
      style: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        elevation: WidgetStatePropertyAll(0),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        visualDensity: VisualDensity.standard,
        // ต้องตั้งให้ตรงกับ ClipRRect ข้างใน ไม่งั้น Material clip ทับเป็นมุมเหลี่ยม
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(_radius)),
          ),
        ),
      ),
      menuChildren: [_menuCard()],
      builder: (context, controller, child) => _button(
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
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

  /// การ์ดเมนูทรง iOS
  ///
  /// อ้างอิงจากเมนูที่ Safari เด้งให้ตอนแตะ `<input type="file">` (จับภาพเทียบ
  /// บน iPhone/iPad จริง): พื้นหลังโปร่งเบลอ มุมโค้ง 13 แถวสูง 44 ไอคอนอยู่ซ้าย
  /// ข้อความ 17pt ชิดซ้าย คั่นด้วยเส้น hairline เต็มความกว้าง และเงานุ่มฟุ้ง
  ///
  /// วาดเองทั้งการ์ดแทนการใช้ `MenuItemButton` เพราะตัวนั้นบังคับ padding/สี
  /// ตามสำนวน Material ซึ่งคนละทรงกัน
  Widget _menuCard() {
    return Container(
      constraints: const BoxConstraints(minWidth: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 60,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            // เทียบจากเมนูจริง: โปร่งพอให้เห็นของหลังเบลอทะลุมา ถ้าทึบเกิน
            // BackdropFilter จะเสียเปล่า (เคยตั้ง 0xF2 = 95% แล้วมองไม่เห็นเลย)
            color: const Color(0xD6F2F2F2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _row(_Source.gallery, 'photos_upload.svg', 'คลังรูปภาพ'),
                _separator(),
                _row(_Source.camera, 'camera_upload.svg', 'ถ่ายรูป'),
                _separator(),
                _row(_Source.files, 'file_upload.svg', 'เลือกไฟล์'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _separator() => Container(
        height: 0.5,
        // separator ของ iOS จางมาก — ของเดิม 30% เข้มจนเห็นเป็นเส้นดำ
        color: const Color(0x1F3C3C43),
      );

  Widget _row(_Source source, String icon, String label) {
    return Builder(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: InkWell(
          // iOS ไฮไลต์ทั้งแถวเป็นเทาจางตอนกด ไม่มี ripple แผ่
          splashFactory: NoSplash.splashFactory,
          highlightColor: const Color(0x1A000000),
          hoverColor: const Color(0x0D000000),
          onTap: () async {
            Navigator.of(context).pop();
            final file = await AttachmentPicker._pickFrom(source);
            if (file != null) onPicked(file);
          },
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/$icon',
                    width: 21,
                    height: 21,
                    colorFilter: const ColorFilter.mode(
                      _labelColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 17,
                        color: _labelColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
