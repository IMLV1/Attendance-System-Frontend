import 'dart:js_interop';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'root_overlay_tracker.dart';

/// วาง `<input type="file">` ของจริงทับปุ่ม เพื่อให้ **ผู้ใช้แตะ element นั้นตรงๆ**
///
/// 🚩 (2026-08-27) รอบแรกลองสร้าง input ซ่อนไว้แล้วสั่ง `.click()` จากโค้ด แล้ว
/// วางตำแหน่งให้ตรงปุ่ม — วัดแล้ว rect ถูก แต่ A/B บน iPhone/iPad Safari ได้
/// ตำแหน่งเมนูเท่าเดิมเป๊ะ สรุปว่า **คลิกที่โปรแกรมยิงเองไม่มีบริบทให้ Safari
/// ยึดเมนู** มันเลยไปวางตำแหน่ง default
///
/// ทางที่ได้ผลคือให้ผู้ใช้แตะ element จริง (แบบเดียวกับ `<select>` ใน
/// native_select_web.dart) จึงฝัง input ลงไปด้วย HtmlElementView แล้วทำให้
/// โปร่งใสวางทับปุ่มที่ Flutter วาด — ผู้ใช้เห็นปุ่มเดิม แต่สิ่งที่แตะคือ input
///
/// ใช้ `opacity: 0` ไม่ใช่ `display:none`/`visibility:hidden` เพราะสองอันหลัง
/// ทำให้ element ไม่มีกรอบและรับ event ไม่ได้ ซึ่งพากลับไปที่ปัญหาเดิม
Widget? buildNativeFileInput({
  required List<String> extensions,
  required void Function(PlatformFile file) onPicked,
  required Widget child,
}) {
  return _NativeFileInput(
    extensions: extensions,
    onPicked: onPicked,
    child: child,
  );
}

class _NativeFileInput extends StatefulWidget {

  const _NativeFileInput({
    required this.extensions,
    required this.onPicked,
    required this.child,
  });

  final List<String> extensions;
  final void Function(PlatformFile file) onPicked;
  final Widget child;

  @override
  State<_NativeFileInput> createState() => _NativeFileInputState();
}

class _NativeFileInputState extends State<_NativeFileInput> {

  /// route บนสุด ณ ตอนที่ widget นี้โผล่ — ต้องอ่านหลังเฟรมแรก เพราะตอน build
  /// รอบแรก observer อาจยังไม่ทันบันทึก route ที่กำลัง push อยู่
  Route<dynamic>? _seenAtMount;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _seenAtMount = RootOverlayTracker.topRoute.value;
        _ready = true;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    // 🚩 (2026-08-27) HtmlElementView อยู่ใน DOM ชั้นเหนือ canvas ของ Flutter
    // popup ที่ Flutter วาดจึงทับมันไม่ได้ — แตะตรงตำแหน่งปุ่มทั้งที่ popup
    // เปิดอยู่ เมนูแนบไฟล์จะเด้งทะลุขึ้นมา ต้องถอด overlay ทิ้งเองตอนมีอะไรบัง
    return ValueListenableBuilder<Route<dynamic>?>(
      valueListenable: RootOverlayTracker.topRoute,
      builder: (context, _, child) {
        if (_ready && RootOverlayTracker.isCoveredSince(_seenAtMount)) {
          return widget.child;
        }
        return Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: _FileInputOverlay(
                extensions: widget.extensions,
                onPicked: widget.onPicked,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FileInputOverlay extends StatelessWidget {

  const _FileInputOverlay({required this.extensions, required this.onPicked});

  final List<String> extensions;
  final void Function(PlatformFile file) onPicked;

  void _onCreated(Object element) {
    final input = element as web.HTMLInputElement
      ..type = 'file'
      ..accept = extensions.map((e) => '.$e').join(',')
      ..multiple = false;

    input.style
      ..width = '100%'
      ..height = '100%'
      ..opacity = '0'
      ..cursor = 'pointer';

    input.onChange.listen((_) async {
      final files = input.files;
      if (files == null || files.length == 0) return;

      final file = files.item(0)!;
      try {
        final buffer = await file.arrayBuffer().toDart;
        onPicked(PlatformFile(
          name: file.name,
          size: buffer.toDart.lengthInBytes,
          bytes: buffer.toDart.asUint8List(),
        ));
      } finally {
        // เคลียร์เพื่อให้เลือกไฟล์เดิมซ้ำได้ (ไม่งั้น onChange ไม่ยิงรอบสอง)
        input.value = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'input',
      onElementCreated: _onCreated,
    );
  }
}
