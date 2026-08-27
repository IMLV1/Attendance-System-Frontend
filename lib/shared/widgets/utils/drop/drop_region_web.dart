import 'dart:async';
import 'dart:js_interop';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// รับไฟล์ที่ลากมาวางบนเว็บ — ต่อ event ของ DOM เอง ไม่ผ่าน `desktop_drop`
///
/// 🚩 (2026-08-27) เดิมใช้ `desktop_drop` ทั้งเว็บและเดสก์ท็อป แต่ฝั่งเว็บของมัน
/// ใช้ไม่ได้จริงกับแอปนี้ เจอสองอาการซ้อนกันตอนทดสอบ:
///
/// 1. `MissingPluginException(No implementation found for method entered on
///    channel desktop_drop)` — ทุก event ที่ปลั๊กอินยิงข้าม method channel
///    ตกหายหมด ("A message on the desktop_drop channel was discarded")
/// 2. ต่อให้ข้อ 1 ผ่าน โค้ดของมันเรียก `item.webkitGetAsEntry()!` แบบ non-null
///    ทั้งที่เมธอดนี้คืน null สำหรับ item ที่ไม่ใช่ไฟล์ — และการลากไฟล์จริงจาก
///    Finder/เบราว์เซอร์แนบ item ชนิด string (`text/uri-list`) มาด้วยเสมอ
///    จึงพังทุกครั้งที่ลากของจริงมาวาง
///
/// ฝั่งเว็บไม่ต้องพึ่ง entry API เลย — `dataTransfer.files` ให้ `File` ตรงๆ
/// อยู่แล้ว ที่เหลือคือดักว่าเมาส์อยู่เหนือพื้นที่ของ widget ตัวไหน
///
/// (ฝั่ง macOS/Windows/Linux ยังใช้ `desktop_drop` ต่อ เพราะโค้ดตรงนั้นเป็น
/// native จริงคนละชุดกับ shim ฝั่งเว็บ — ดู drop_region_io.dart)
Widget buildDropRegion({
  required Widget child,
  required void Function(bool hovering) onHover,
  required void Function(List<PlatformFile> files) onFiles,
}) {
  return _WebDropRegion(
    onHover: onHover,
    onFiles: onFiles,
    child: child,
  );
}

class _WebDropRegion extends StatefulWidget {

  const _WebDropRegion({
    required this.child,
    required this.onHover,
    required this.onFiles,
  });

  final Widget child;
  final void Function(bool hovering) onHover;
  final void Function(List<PlatformFile> files) onFiles;

  @override
  State<_WebDropRegion> createState() => _WebDropRegionState();
}

class _WebDropRegionState extends State<_WebDropRegion> {

  late final JSFunction _onDragOver = _handleDragOver.toJS;
  late final JSFunction _onDragLeave = _handleDragLeave.toJS;
  late final JSFunction _onDrop = _handleDrop.toJS;

  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    // ต้องดักที่ document ไม่ใช่ element ของตัวเอง เพราะ Flutter วาดลง canvas
    // ตัวเดียว — ไม่มี DOM element ของ widget นี้ให้ผูก listener
    web.document.addEventListener('dragover', _onDragOver);
    web.document.addEventListener('dragleave', _onDragLeave);
    web.document.addEventListener('drop', _onDrop);
  }

  @override
  void dispose() {
    web.document.removeEventListener('dragover', _onDragOver);
    web.document.removeEventListener('dragleave', _onDragLeave);
    web.document.removeEventListener('drop', _onDrop);
    super.dispose();
  }

  /// พื้นที่ของ widget นี้ในพิกัดหน้าจอ — เทียบกับ `clientX/clientY` ได้ตรงๆ
  /// เพราะ logical pixel ของ Flutter web คือ CSS pixel หน่วยเดียวกัน
  Rect? get _bounds {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  bool _isInside(num x, num y) {
    final rect = _bounds;
    return rect != null && rect.contains(Offset(x.toDouble(), y.toDouble()));
  }

  void _setHover(bool value) {
    if (_hovering == value) return;
    _hovering = value;
    widget.onHover(value);
  }

  void _handleDragOver(web.Event event) {
    final e = event as web.DragEvent;
    // ไม่ preventDefault = เบราว์เซอร์จะเปิดไฟล์แทนที่จะยอมให้วาง
    e.preventDefault();
    _setHover(_isInside(e.clientX, e.clientY));
  }

  void _handleDragLeave(web.Event event) {
    final e = event as web.DragEvent;
    // `dragleave` ยิงตอนข้ามขอบ element ย่อยด้วย ไม่ใช่แค่ตอนออกนอกหน้าต่าง
    // จึงเช็กพิกัดซ้ำ — ค่า 0,0 คือออกนอกหน้าต่างไปแล้วจริงๆ
    if (!_isInside(e.clientX, e.clientY)) _setHover(false);
  }

  /// 🚩 ต้องเป็น `void` ไม่ใช่ `Future<void>` — `.toJS` ปฏิเสธ signature ที่คืน
  /// Future ("Function converted via 'toJS' contains invalid types") และ
  /// `flutter analyze` ไม่จับให้ ไปพังตอน compile เท่านั้น
  ///
  /// ที่ต้องทำ**ในจังหวะ event จริงๆ** มีแค่ `preventDefault` กับการหยิบ `File`
  /// ออกจาก `dataTransfer` (ตัว dataTransfer หมดอายุเมื่อ handler จบ) ส่วน
  /// `File` ที่หยิบออกมาแล้วเป็น Blob อ่านทีหลังได้ จึงแยกไปทำต่อแบบ async
  void _handleDrop(web.Event event) {
    final e = event as web.DragEvent;
    e.preventDefault();

    final inside = _isInside(e.clientX, e.clientY);
    _setHover(false);
    if (!inside) return;

    final list = e.dataTransfer?.files;
    if (list == null) return;

    final files = <web.File>[];
    for (var i = 0; i < list.length; i++) {
      final file = list.item(i);
      if (file != null) files.add(file);
    }
    if (files.isNotEmpty) unawaited(_readAndReport(files));
  }

  Future<void> _readAndReport(List<web.File> files) async {
    final picked = <PlatformFile>[];
    for (final file in files) {
      final buffer = await file.arrayBuffer().toDart;
      picked.add(PlatformFile(
        name: file.name,
        size: buffer.toDart.lengthInBytes,
        bytes: buffer.toDart.asUint8List(),
      ));
    }

    if (picked.isNotEmpty && mounted) widget.onFiles(picked);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
