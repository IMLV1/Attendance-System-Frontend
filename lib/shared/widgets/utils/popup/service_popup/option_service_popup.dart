import 'package:attendance_system/shared/widgets/utils/option_pane.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OptionServicePopup {
  final String title;
  final String buttonLabel;
  final void Function(String value)? onSuccess;
  final Future<Response<dynamic>> Function(String value) request;
  final bool backButton;
  final String selected;
  final List<String> options;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final String? Function(String?)? check;

  const OptionServicePopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.onSuccess,
    required this.request,
    this.backButton = true,
    this.selected = '',
    required this.options,
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.loose,
    this.check
  });

  void showPopup(BuildContext context) {

    String? validationError;
    String current = selected;

    ServicePopup(
      title: title,
      buttonLabel: buttonLabel,
      fit: fit,
      maxHeight: maxHeight,
      minHeight: minHeight,
      request: () => request(current),
      onSuccess: (context) {
        Navigator.of(context).pop();
        if (onSuccess != null) onSuccess!(current);
      },
      check: () {
        validationError = check?.call(current);
        return validationError;
      },
      builder: (trigger, state, errorMessage) {
        return Column(
              children: [
                if (validationError == null &&
                    state == ServiceUpdatorState.error)
                  const Text(
                    'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง...',
                    style: TextStyle(color: Colors.red),
                  ),

                if (validationError != null)
                  Text(
                    validationError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                OptionPane(
                  onSelected: (option) {
                    current = option;
                  },
                  selected: selected,
                  borderRadius: BorderRadius.zero,
                  options: options,
                ),
              ],
            );
      }
    ).showPopup(context);
  }

}