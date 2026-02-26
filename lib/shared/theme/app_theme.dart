import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    cardColor: AppColors.cardColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    brightness: Brightness.light,
    fontFamily: 'Inter',
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