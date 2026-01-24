import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    shadowColor: AppColors.shadowColor,
    cardColor: AppColors.cardColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    brightness: Brightness.light,
    fontFamily: 'Inter',
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