import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/popup/floating_popup.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AdminConfigUtils {
  static void showSaveConfirmation({
    required BuildContext context,
    required Future<Response<dynamic>> Function() onSave,
    required VoidCallback onDiscard,
    VoidCallback? onNavigateBack,
  }) {
    FloatingPopup(
      title: 'บันทึกการเปลี่ยนแปลง',
      description: 'คุณยืนยันที่จะบันทึกการเปลี่ยนแปลงนี้หรือไม่',
      buttons: (void Function(String) setError, BuildContext context1) {
        return [
          FloatingPopupButton(
            foregroundColor: Colors.red,
            onPressed: () {
              Navigator.of(context1).pop(); // Close popup
              onDiscard();
            },
            text: 'ละทิ้ง',
          ),
          FloatingServicePopupButton(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            onSuccess: () {
              Navigator.of(context1).pop(); // Close popup
              // Bug 2.1: Navigate back after successful save
              if (onNavigateBack != null) {
                onNavigateBack();
              }
            },
            text: 'บันทึก',
            request: onSave,
            setError: setError,
          )
        ];
      },
    ).showPopup(context);
  }
}
