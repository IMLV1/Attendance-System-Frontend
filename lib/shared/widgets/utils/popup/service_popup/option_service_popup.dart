import 'package:attendance_system/shared/widgets/utils/option_pane.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/service_popup.dart';
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
    this.fit = FlexFit.loose
  });

  void showPopup(BuildContext context) {

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
      builder: (trigger, state, load, error) =>
      Column(
        children: [
          error,

          OptionPane(
            onSelected: (option) {
              current = option;
            },
            selected: selected,
            borderRadius: BorderRadius.zero,
            options: options,
          )
        ],
      )
    ).showPopup(context);
  }

}