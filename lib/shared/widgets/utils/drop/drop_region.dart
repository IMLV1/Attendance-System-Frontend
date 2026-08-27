import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

export 'drop_region_io.dart' if (dart.library.js_interop) 'drop_region_web.dart';

/// สัญญาที่ทั้งสองฝั่ง (เว็บ / เดสก์ท็อป) ต้องทำให้ได้
///
/// - `onHover` บอกว่าตอนนี้มีไฟล์ลอยอยู่เหนือพื้นที่นี้ไหม (ไว้วาดกรอบไฮไลต์)
/// - `onFiles` ได้ไฟล์ที่ผู้ใช้วางแล้ว **พร้อม bytes** — ทั้งสองฝั่งอ่านให้เสร็จ
///   ก่อนส่งต่อ เพราะบนเว็บ `File` ที่ได้จาก drop อ่านได้เฉพาะระหว่าง event
typedef DropRegionBuilder = Widget Function({
  required Widget child,
  required void Function(bool hovering) onHover,
  required void Function(List<PlatformFile> files) onFiles,
});
