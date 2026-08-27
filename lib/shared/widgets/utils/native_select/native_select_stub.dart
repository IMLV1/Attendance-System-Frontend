import 'package:flutter/material.dart';

/// บนแพลตฟอร์มที่ไม่ใช่เว็บไม่มี `<select>` ให้ใช้ — คืน null เพื่อให้ผู้เรียก
/// ถอยไปใช้เมนูที่วาดเอง
Widget? buildNativeSelect({
  required List<(String, String)> options,
  required String value,
  required ValueChanged<String> onChanged,
  required TextStyle textStyle,
}) => null;
