import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// นอกเว็บไม่มี `<input type="file">` ให้ฝัง — คืน null เพื่อให้ผู้เรียกใช้ทางเดิม
Widget? buildNativeFileInput({
  required List<String> extensions,
  required void Function(PlatformFile file) onPicked,
  required Widget child,
}) => null;
