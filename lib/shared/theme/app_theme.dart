import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme {

  /// ฟอนต์ที่ใช้ในแต่ละแพลตฟอร์ม
  ///
  /// 🚩 (2026-08-27) **เว็บใช้ฟอนต์ระบบไม่ได้** — CanvasKit วาดตัวอักษรลง canvas
  /// เอง จึงเข้าถึงฟอนต์ที่ติดตั้งใน OS ไม่ได้เลย ใช้ได้แค่ที่ bundle ไปให้
  /// (HTML renderer ที่เคยวาดเป็น DOM จริงและได้ฟอนต์ระบบ ถูกถอดออกไปแล้ว)
  ///
  /// ตอนแรกตั้งเว็บเป็น `system-ui` แล้วนึกว่าได้ผล เพราะตัวเลขดูคล้ายกัน — แต่
  /// ตัวไทยฟ้องว่าคนละฟอนต์ ตัว canvas ไปหยิบ fallback ที่คุมไม่ได้ ส่วน
  /// `<select>` ซึ่งเป็น DOM จริงได้ฟอนต์ระบบมาจริงๆ สองอันเลยไม่ตรงกัน
  ///
  /// จึงแยกทาง: แอปใช้ฟอนต์ระบบ (ตรงตามที่ต้องการ) ส่วนเว็บ bundle ฟอนต์ไปเอง
  /// เพื่อให้ทั้งหน้ากลืนกัน แล้วตั้ง CSS ของ `<select>` ให้ตรงกันด้วย
  static String? get fontFamily => kIsWeb ? 'Inter' : null;

  /// ไทยต้องมาจาก NotoSansThai เสมอบนเว็บ เพราะ Inter ไม่มี glyph ไทย
  /// ถ้าไม่ระบุ canvas จะไปหยิบ fallback ที่เราคุมไม่ได้
  static List<String>? get fontFamilyFallback =>
      kIsWeb ? const ['NotoSansThai'] : systemFontFallback;

  /// stack สำหรับ CSS ของ element ที่เบราว์เซอร์วาดเอง (เช่น `<select>`)
  /// ต้องตรงกับที่ canvas ใช้ ไม่งั้นข้อความสองที่จะคนละฟอนต์
  static const String cssFontStack =
      "Inter, NotoSansThai, system-ui, -apple-system, sans-serif";

  /// ใช้บนแอปเท่านั้น — ปล่อยให้ engine เลือกฟอนต์ระบบเอง
  static const List<String> systemFontFallback = [
    'system-ui',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
  ];
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    cardColor: AppColors.cardColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        decoration: TextDecoration.none
      ),
      bodyLarge: TextStyle(
          decoration: TextDecoration.none
      ),
      bodySmall: TextStyle(
          decoration: TextDecoration.none
      ),
      titleLarge: TextStyle(
          decoration: TextDecoration.none
      ),
      titleMedium: TextStyle(
          decoration: TextDecoration.none
      ),
      titleSmall: TextStyle(
          decoration: TextDecoration.none
      ),
      headlineLarge: TextStyle(
          decoration: TextDecoration.none
      ),
      headlineMedium: TextStyle(
          decoration: TextDecoration.none
      ),
      headlineSmall: TextStyle(
          decoration: TextDecoration.none
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cardColor,
        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        foregroundColor: Colors.black,

      ).copyWith(
        //overlayColor: MaterialStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        animationDuration: Duration.zero,
      ),
    ),
  );
}