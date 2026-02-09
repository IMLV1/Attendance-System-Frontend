import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    cardColor: AppColors.cardColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    textTheme: defaultTargetPlatform == TargetPlatform.android
        ? const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Inter'),
      bodyMedium: TextStyle(fontFamily: 'Inter'),
      bodySmall: TextStyle(fontFamily: 'Inter'),
      titleMedium: TextStyle(fontFamily: 'Inter'),
      titleLarge: TextStyle(fontFamily: 'Inter'),
      labelLarge: TextStyle(fontFamily: 'Inter'),
    )
        : null,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cardColor,
        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        foregroundColor: Colors.black,

      ).copyWith(
        //overlayColor: MaterialStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        animationDuration: Duration(seconds: 0),
      ),
    ),
  );
}