import 'dart:io';

import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'download/save_bytes_stub.dart'
    if (dart.library.js_interop) 'download/save_bytes_web.dart';

/// 🚩 (2026-08-26) เดิมคลาสนี้มีเมธอดเดียวชื่อ `downloadFile` ที่ทำสองความหมาย
/// ปนกัน — บนมือถือมันโหลดลง temp แล้วเปิด **share sheet** (= "ส่งต่อ") ส่วนบน
/// เว็บมันเปิดแท็บใหม่ (= "ดู") ไม่มีทางไหนเลยที่เป็น "บันทึกลงเครื่อง" จริงๆ
/// ทั้งที่ปุ่มเขียนว่า "ส่งออกไฟล์"
///
/// แยกเป็นสองเมธอดตามความตั้งใจของผู้ใช้ แล้วให้แต่ละแพลตฟอร์มไปทำท่าที่ถูกต้อง
/// ของตัวเอง — ท่า "ดาวน์โหลด" ของแต่ละที่ไม่เหมือนกันเลย:
///
/// | แพลตฟอร์ม | บันทึก |
/// |---|---|
/// | iOS / iPadOS | "บันทึกไปยังไฟล์" (`flutter_file_dialog`) |
/// | Android | SAF ให้ผู้ใช้เลือกที่เก็บเอง (ตัวเดียวกัน) |
/// | web | blob + `<a download>` |
/// | macOS / Windows / Linux | ไดอะล็อก Save As (`file_picker.saveFile`) |
///
/// (iOS/Android ไม่มีโฟลเดอร์ Downloads ให้แอปเขียนลงตรงๆ อยู่แล้ว — ไดอะล็อก
/// ของระบบคือของที่เทียบเท่าที่สุด ไม่ใช่ทางอ้อม)
class Downloader {

  final void Function(int receivedBytes, int totalBytes)? onProgress;
  final void Function()? onDownloadSuccess;
  final void Function()? onDownloadStart;
  final void Function(dynamic e)? onError;

  const Downloader({this.onProgress, this.onDownloadSuccess, this.onDownloadStart, this.onError});

  /// เก็บไฟล์ไว้ในเครื่องผู้ใช้ — ปลายทางแล้วแต่ผู้ใช้เลือกจากไดอะล็อกของระบบ
  Future<void> saveFile(NetworkFile file) async {
    try {
      if (kIsWeb) {
        // 🚩 (2026-08-26) การดาวน์โหลดจริงบนเว็บต้องอ่าน bytes เองก่อน ซึ่งแปลว่า
        // เซิร์ฟเวอร์ไฟล์**ต้องส่ง CORS header มาด้วย** ตอนเขียนนี้ route /uploads
        // ของ backend ยังถูกลงทะเบียนก่อน cors middleware จึงไม่ส่งมาเลย (patch
        // ไว้แล้วฝั่ง backend แต่ยังไม่ได้ deploy)
        //
        // ถ้าอ่าน bytes ไม่ได้ ไม่ควรจบด้วยความเงียบ — ถอยไปเปิดแท็บใหม่ซึ่งเป็น
        // พฤติกรรมเดิมของแอป ผู้ใช้ยังกดบันทึกเองจากเบราว์เซอร์ได้ ไม่ใช่ทางที่ดี
        // ที่สุดแต่ดีกว่ากดแล้วไม่เกิดอะไรเลย
        try {
          final bytes = await _downloadBytes(file);
          await saveBytesToDevice(bytes, file.fileName);
        } catch (e) {
          debugPrint('🟠 ดาวน์โหลดตรงไม่ได้ (น่าจะติด CORS) ถอยไปเปิดแท็บใหม่ — $e');
          final uri = Uri.parse(file.fileUrl);
          if (!await launchUrl(uri, webOnlyWindowName: '_blank')) rethrow;
        }
        return;
      }

      final tempPath = await _downloadToTemp(file);

      if (Platform.isIOS || Platform.isAndroid) {
        // คืนค่า null เมื่อผู้ใช้กดยกเลิก — ไม่ใช่ error ไม่ต้องแจ้งอะไร
        await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(sourceFilePath: tempPath),
        );
        return;
      }

      // desktop — `file_picker.saveFile` แค่ถามที่เก็บ ไม่ได้เขียนไฟล์ให้
      // ต้องก๊อปจาก temp ไปเองอีกที
      final target = await FilePicker.platform.saveFile(
        dialogTitle: 'บันทึกไฟล์',
        fileName: file.fileName,
      );
      if (target == null) return;

      await File(tempPath).copy(target);
    } catch (e) {
      onError?.call(e);
    }
  }

  /// ส่งต่อไฟล์ให้แอปอื่น — share sheet ของระบบ
  ///
  /// ไม่รองรับบนเว็บ (Web Share API ยังส่งไฟล์ไม่ได้ทุกเบราว์เซอร์) ปุ่มนี้
  /// จึงถูกซ่อนไปเลยบนเว็บ ดู `Downloader.canShare`
  ///
  /// 🚩 (2026-08-27) [origin] **บังคับต้องส่ง** ไม่ใช่ของเสริม — บน iPad กับ
  /// macOS ระบบแสดง share sheet เป็น **popover ที่ต้องชี้ไปยังของบางอย่างบนจอ**
  /// ถ้าไม่บอกว่าชี้ที่ไหน `UIActivityViewController` จะไม่ขึ้นมาเลย
  ///
  /// อาการที่ผู้ใช้เจอ: กด "แชร์ไฟล์" บน iPad แล้วไม่เกิดอะไรขึ้น เงียบสนิท
  /// ไม่มี error ให้เห็นด้วย (iPhone ไม่มีปัญหาเพราะขึ้นเป็นชีตเต็มจอ ไม่ใช่
  /// popover จึงไม่สนใจค่านี้)
  ///
  /// ทำเป็น named แบบ `required` เพื่อให้ลืมไม่ได้ — ค่า null ยังยอมรับได้
  /// สำหรับจุดที่หา RenderBox ไม่เจอจริงๆ แต่ต้องเขียนออกมาให้เห็นว่าตั้งใจ
  Future<void> shareFile(NetworkFile file, {required Rect? origin}) async {
    try {
      final tempPath = await _downloadToTemp(file);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempPath)],
          subject: file.fileName,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      onError?.call(e);
    }
  }

  /// กรอบของ widget ที่กดในพิกัดจอ — ใช้เป็นจุดที่ popover ของ iPad ชี้ไป
  ///
  /// ส่ง context ของ **ปุ่มที่ผู้ใช้กด** มา ไม่ใช่ของทั้งหน้า ไม่งั้น popover
  /// จะไปโผล่กลางจอห่างจากปุ่ม
  static Rect? originOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// เว็บไม่มี share sheet ที่ส่งไฟล์ได้จริง — ให้ผู้เรียกซ่อนปุ่มแชร์เอง
  static bool get canShare => !kIsWeb;

  /// เปิดไฟล์ด้วยแอปเริ่มต้นของระบบ — Preview/Acrobat/Photos/แท็บใหม่ แล้วแต่ OS
  ///
  /// 🚩 (2026-08-27) นี่คือครึ่งหลังของทาง **B3** ที่เคาะไว้ใน Phase 5.3: พรีวิว
  /// หลักยังอยู่ในแอป (คุมหน้าตาได้ ไม่หลุดบริบท) แต่ผู้ใช้ที่อยากได้ของแถมจาก
  /// ระบบ — สั่งพิมพ์ ค้นข้อความในเอกสาร เขียนโน้ตทับ ส่งเข้า Files — กดปุ่มนี้
  /// ออกไปหาแอปของ OS ได้ ซึ่ง viewer ที่เขียนเองไม่มีวันทำได้ครบ
  ///
  /// ท่าเปิดของแต่ละแพลตฟอร์มคนละตัวกันหมด:
  /// - web: เปิดแท็บใหม่ตรงจาก URL ไม่ต้องโหลดอะไรลงเครื่อง
  /// - iOS/Android: ต้องมีไฟล์จริงในเครื่องก่อน แล้วส่งให้ `OpenFilex`
  ///   (= `UIDocumentInteractionController` / `ACTION_VIEW`)
  /// - desktop: `Uri.file()` ผ่าน `url_launcher` = ดับเบิลคลิกไฟล์นั่นแหละ
  ///   (`OpenFilex` ไม่รองรับ desktop)
  Future<void> openExternally(NetworkFile file) async {
    try {
      if (kIsWeb) {
        final uri = Uri.parse(file.fileUrl);
        if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
          throw Exception('เปิดแท็บใหม่ไม่สำเร็จ');
        }
        return;
      }

      final tempPath = await _downloadToTemp(file);

      if (Platform.isIOS || Platform.isAndroid) {
        final result = await OpenFilex.open(tempPath);
        // `done` = ระบบรับช่วงต่อแล้ว นอกนั้นคือไม่มีแอปเปิดไฟล์ชนิดนี้/ถูกปฏิเสธ
        if (result.type != ResultType.done) {
          throw Exception('เปิดไฟล์ไม่ได้ — ${result.message}');
        }
        return;
      }

      if (!await launchUrl(Uri.file(tempPath))) {
        throw Exception('เปิดไฟล์ไม่ได้');
      }
    } catch (e) {
      onError?.call(e);
    }
  }

  /// โหลดลงโฟลเดอร์ชั่วคราวแล้วคืน path — ข้ามการโหลดถ้าไฟล์เดิมครบอยู่แล้ว
  Future<String> _downloadToTemp(NetworkFile file) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/${file.fileName}';
    final tempFile = File(tempPath);

    if (await tempFile.exists() && await tempFile.length() == file.fileSize) {
      return tempPath;
    }

    onDownloadStart?.call();
    await Dio().download(
      file.fileUrl,
      tempPath,
      onReceiveProgress: (receivedBytes, totalBytes) {
        if (totalBytes != -1) onProgress?.call(receivedBytes, totalBytes);
      },
      deleteOnError: true,
    );
    onDownloadSuccess?.call();

    return tempPath;
  }

  /// เว็บไม่มีระบบไฟล์ให้เขียน temp จึงต้องถือ bytes ไว้ในหน่วยความจำ
  Future<Uint8List> _downloadBytes(NetworkFile file) async {
    onDownloadStart?.call();

    final response = await Dio().get<List<int>>(
      file.fileUrl,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (receivedBytes, totalBytes) {
        if (totalBytes != -1) onProgress?.call(receivedBytes, totalBytes);
      },
    );

    onDownloadSuccess?.call();
    return Uint8List.fromList(response.data ?? const []);
  }
}
