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
  final String? Function(String?)? check;

  const OptionPopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.onSubmit,
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

    PushPopup(
      title: title,
      buttonLabel: buttonLabel,
      fit: fit,
      maxHeight: maxHeight,
      minHeight: minHeight,
      buttonAction: (context) {

        validationError = check?.call(current);

        if (validationError == null) {
          Navigator.of(context).pop();
          if (onSubmit != null) onSubmit!(current);
        }
      },
      builder: (_) => Column(
        children: [

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
          )
        ],
      )
    ).showPopup(context);
  }

}