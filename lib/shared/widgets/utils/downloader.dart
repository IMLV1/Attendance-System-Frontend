import 'dart:io';

import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
        final bytes = await _downloadBytes(file);
        await saveBytesToDevice(bytes, file.fileName);
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
  Future<void> shareFile(NetworkFile file) async {
    try {
      final tempPath = await _downloadToTemp(file);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempPath)],
          subject: file.fileName,
        ),
      );
    } catch (e) {
      onError?.call(e);
    }
  }

  /// เว็บไม่มี share sheet ที่ส่งไฟล์ได้จริง — ให้ผู้เรียกซ่อนปุ่มแชร์เอง
  static bool get canShare => !kIsWeb;

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
