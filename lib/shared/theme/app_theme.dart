import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme {

  /// ฟอนต์ของระบบในแต่ละแพลตฟอร์ม
  ///
  /// 🚩 (2026-08-27) เดิมทั้งแอปบังคับใช้ Inter ที่ bundle มาเอง เปลี่ยนมาใช้
  /// ฟอนต์ของ OS เพื่อให้หน้าตากลืนกับระบบที่ผู้ใช้ใช้อยู่
  ///
  /// - บนแอป: `null` = ปล่อยให้ engine เลือกเอง (SF บน iOS/macOS, Roboto บน
  ///   Android) ซึ่งเป็นฟอนต์ระบบอยู่แล้ว
  /// - บนเว็บ: ต้องระบุเป็นคีย์เวิร์ด CSS เพราะ engine ไม่มีค่า default ให้
  ///
  /// `fontFamilyFallback` ไล่ลงมาเผื่อ browser/OS ที่ไม่รู้จัก `system-ui`
  static String? get systemFontFamily => kIsWeb ? 'system-ui' : null;

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
    fontFamily: systemFontFamily,
    fontFamilyFallback: systemFontFallback,
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