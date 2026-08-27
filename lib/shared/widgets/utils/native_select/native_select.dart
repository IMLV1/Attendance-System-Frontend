import 'package:flutter/material.dart';

import 'native_select_stub.dart'
    if (dart.library.js_interop) 'native_select_web.dart';

/// ดรอปดาวน์ที่ใช้ `<select>` ของจริงบนเว็บ (OS วาดเมนูให้) และถอยไปใช้
/// [fallback] บนแอป ซึ่งไม่มี `<select>` ให้ใช้
class NativeSelect extends StatelessWidget {

  const NativeSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.fallback,
    this.height = 38,
    this.textStyle = const TextStyle(fontSize: 14, color: Colors.black),
  });

  /// (ค่าที่ส่งกลับ, ข้อความที่แสดง)
  final List<(String, String)> options;
  final String value;
  final ValueChanged<String> onChanged;

  /// ใช้เมื่อแพลตฟอร์มไม่มี `<select>` — คือทุกที่ที่ไม่ใช่เว็บ
  final Widget fallback;

  final double height;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final native = buildNativeSelect(
      options: options,
      value: value,
      onChanged: onChanged,
      textStyle: textStyle,
    );
    if (native == null) return fallback;

    return SizedBox(height: height, child: native);
  }
}
