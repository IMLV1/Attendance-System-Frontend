import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:attendance_system/shared/theme/app_theme.dart';
import 'package:web/web.dart' as web;

/// ฝัง `<select>` ของจริงลงในหน้า เพื่อให้ **OS เป็นคนวาดเมนูให้**
///
/// 🚩 (2026-08-27) Flutter Web วาดทุกอย่างลง canvas ผืนเดียว เบราว์เซอร์จึงไม่
/// เห็นว่ามีดรอปดาวน์อยู่ตรงไหน เมนูที่เราวาดเองจึงเป็นแค่ของเลียนแบบ
///
/// แต่ `HtmlElementView.fromTagName` ฝัง DOM element จริงลงไปได้ พอเป็น
/// `<select>` แท้ iOS Safari จะเด้งเมนูของ OS ให้เอง — ลอยยึดกับช่อง มีเครื่องหมาย
/// ถูกที่ตัวเลือกปัจจุบัน ซึ่งเลียนแบบด้วย Flutter ให้เหมือนเป๊ะไม่ได้
///
/// ข้อแลกที่ต้องรู้: element นี้อยู่คนละ layer กับ canvas สไตล์จึงต้องตั้งด้วย CSS
/// ไม่ได้มาจาก theme ของ Flutter และได้เฉพาะบนเว็บเท่านั้น
Widget? buildNativeSelect({
  required List<(String, String)> options,
  required String value,
  required ValueChanged<String> onChanged,
  required TextStyle textStyle,
}) {
  return _WebSelect(
    options: options,
    value: value,
    onChanged: onChanged,
    textStyle: textStyle,
  );
}

class _WebSelect extends StatefulWidget {

  const _WebSelect({
    required this.options,
    required this.value,
    required this.onChanged,
    required this.textStyle,
  });

  /// (ค่าที่ส่งกลับ, ข้อความที่แสดง)
  final List<(String, String)> options;
  final String value;
  final ValueChanged<String> onChanged;
  final TextStyle textStyle;

  @override
  State<_WebSelect> createState() => _WebSelectState();
}

class _WebSelectState extends State<_WebSelect> {

  web.HTMLSelectElement? _element;

  @override
  void didUpdateWidget(_WebSelect old) {
    super.didUpdateWidget(old);
    // รายการเดือนเปลี่ยนตามปีที่เลือก จึงต้องเขียน option ใหม่เมื่อ props เปลี่ยน
    if (old.options != widget.options || old.value != widget.value) {
      _sync();
    }
  }

  void _sync() {
    final el = _element;
    if (el == null) return;

    el.innerHTML = ''.toJS;
    for (final (value, label) in widget.options) {
      final option = web.document.createElement('option') as web.HTMLOptionElement
        ..value = value
        ..text = label;
      el.appendChild(option);
    }
    el.value = widget.value;
  }

  void _onCreated(Object element) {
    final el = element as web.HTMLSelectElement;
    _element = el;

    final style = widget.textStyle;
    el.style
      ..width = '100%'
      ..height = '100%'
      ..boxSizing = 'border-box'
      ..padding = '8px'
      ..border = '1px solid ${_css(Colors.grey)}'
      ..borderRadius = '10px'
      ..background = 'transparent'
      ..color = _css(style.color ?? Colors.black)
      ..fontSize = '${style.fontSize ?? 14}px'
      // element นี้เบราว์เซอร์วาดเอง จึงต้องระบุ stack ให้ตรงกับที่ canvas ใช้
      // ไม่งั้นข้อความในช่องกับข้อความรอบๆ จะคนละฟอนต์ (เคยเป็นแบบนั้นมาแล้ว)
      ..fontFamily = AppTheme.cssFontStack
      // ตัดลูกศร default ของเบราว์เซอร์ทิ้ง ให้หน้าตาใกล้ของเดิม
      ..appearance = 'none'
      ..textAlign = 'center';

    el.onChange.listen((_) => widget.onChanged(el.value));
    _sync();
  }

  static String _css(Color c) =>
      'rgba(${(c.r * 255).round()}, ${(c.g * 255).round()},'
      ' ${(c.b * 255).round()}, ${c.a})';

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'select',
      onElementCreated: _onCreated,
    );
  }
}
