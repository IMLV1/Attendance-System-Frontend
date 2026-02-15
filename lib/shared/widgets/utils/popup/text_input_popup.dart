import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputPopup {
  final String title;
  final String buttonLabel;
  final void Function(String value)? onSubmit;
  final bool backButton;
  final String currentValue;
  final String fieldLabel;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?)? check;

  const TextInputPopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.onSubmit,
    this.backButton = true,
    this.currentValue = '',
    this.fieldLabel = '',
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.loose,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.check
  });

  void showPopup(BuildContext context) {

    final formKey = GlobalKey<FormState>();
    final TextEditingController controller = TextEditingController(text: currentValue);

    PushPopup(
        title: title,
        buttonLabel: buttonLabel,
        minHeight: minHeight,
        maxHeight: maxHeight,
        fit: fit,
        buttonAction: (context) {

          formKey.currentState!.validate();

          if (check?.call(controller.text) == null) {
            Navigator.of(context).pop();
            if (onSubmit != null) onSubmit!(controller.text);
          }
        },
        builder: (_) => Column(
          children: [

            Form(
              key: formKey,
              child: TextFormField(
                validator: check,
                keyboardType: keyboardType,
                controller: controller,
                textInputAction: TextInputAction.done,
                inputFormatters: inputFormatters,
                decoration: InputDecoration(
                  labelText: fieldLabel,
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF7D7D7D), // 👈 สีตอนปกติ
                      width: 1,
                    ),
                  ),
                  suffixIcon: InkWell(
                    customBorder: CircleBorder(),
                    onTap: () {
                      controller.clear();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 17,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    ).showPopup(context);
  }

}