import 'package:attendance_system/shared/widgets/utils/popup/service_popup/service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextServicePopup {
  final String title;
  final String buttonLabel;
  final void Function(String value)? onSuccess;
  final Future<Response<dynamic>> Function(String value) request;
  final bool backButton;
  final String currentValue;
  final String fieldLabel;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?)? check;

  const TextServicePopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.onSuccess,
    required this.request,
    this.check,
    this.backButton = true,
    this.currentValue = '',
    this.fieldLabel = '',
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.loose,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
  });

  void showPopup(BuildContext context) {

    final formKey = GlobalKey<FormState>();
    final TextEditingController controller = TextEditingController(text: currentValue);

    ServicePopup(
        title: title,
        buttonLabel: buttonLabel,
        minHeight: minHeight,
        maxHeight: maxHeight,
        fit: fit,
        request: () => request(controller.text),
        onSuccess: (context) {
          Navigator.of(context).pop();
          if (onSuccess != null) onSuccess!(controller.text);
        },
        check: () {
          formKey.currentState!.validate();
          return check?.call(controller.text);
        },
        builder: (trigger, state, errorMessage) => Column(
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
            if (state == ServiceUpdatorState.error)
              Text(
                'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง...',
                style: TextStyle(
                    color: Colors.red
                ),
              ),
          ],
        )
    ).showPopup(context);
  }

}