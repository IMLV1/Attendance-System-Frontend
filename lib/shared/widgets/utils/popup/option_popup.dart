import 'package:attendance_system/shared/widgets/utils/option_pane.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OptionPopup {
  final String title;
  final String buttonLabel;
  final void Function(String value)? onSubmit;
  final bool backButton;
  final String selected;
  final List<String> options;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;


  const OptionPopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.onSubmit,
    this.backButton = true,
    this.selected = '',
    required this.options,
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.loose
  });

  void showPopup(BuildContext context) {

    String current = selected;

    PushPopup(
      title: title,
      buttonLabel: buttonLabel,
      fit: fit,
      maxHeight: maxHeight,
      minHeight: minHeight,
      buttonAction: (context) {
        Navigator.of(context).pop();
        if (onSubmit != null) onSubmit!(current);
      },
      content: OptionPane(
        onSelected: (option) {
          current = option;
        },
        selected: selected,
        borderRadius: BorderRadius.zero,
        options: options,
      )
    ).showPopup(context);
  }

}