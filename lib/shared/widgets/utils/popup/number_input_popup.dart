import 'dart:math';

import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberInputPopup {
  final String title;
  final String buttonLabel;
  final void Function(double value)? onSubmit;
  final bool backButton;
  final double currentValue;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final List<TextInputFormatter> inputFormatters;
  final String suffixText;
  final double step;
  final double minValue;
  final double maxValue;
  final bool decimal;
  final int decimalRange;

  const NumberInputPopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.onSubmit,
    this.backButton = true,
    this.currentValue = 0,
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.loose,
    this.inputFormatters = const [],
    this.suffixText = '',
    this.step = 1,
    this.minValue = 0,
    this.maxValue = double.infinity,
    this.decimal = false,
    this.decimalRange = 0
  });

  void showPopup(BuildContext context) {

    NumberFormat _formatter = NumberFormat('#,###.#');

    final TextEditingController controller = TextEditingController(text: _formatter.format(currentValue));

    PushPopup(
        title: title,
        buttonLabel: buttonLabel,
        minHeight: minHeight,
        maxHeight: maxHeight,
        fit: fit,
        buttonAction: (context) {
          Navigator.of(context).pop();
          if (onSubmit != null) onSubmit!(_formatter.parse(controller.text).toDouble());
        },
        builder: (_) => Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                ElevatedButton(
                    onPressed: () {
                      num currentValue = _formatter.parse(controller.text);
                      controller.text = _formatter.format(currentValue - step < minValue ? minValue : currentValue - step);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      fixedSize: Size(40, 40),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)
                      )
                    ),
                    child: Center( // ✅ บังคับ center ชัด ๆ
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w300,
                          height: 1, // ✅ ตัด line height ส่วนเกิน
                        ),
                      ),
                    ),
                ),
                SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 60,
                          maxWidth: 80
                        ),
                        child: IntrinsicWidth(
                          child: TextField(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
                            controller: controller,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              ...inputFormatters,
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*(\.\d{0,2})?'),
                              ),
                              _Formatter(),
                              DecimalTextInputFormatter(decimalRange: decimalRange),
                              _Formatter2(_formatter, minValue, maxValue),
                            ],
                            cursorColor: Colors.transparent,
                            decoration: InputDecoration(

                              isDense: true,
                              filled: true,
                              fillColor: Color(0xFFF6F6F6),
                              isCollapsed: true, // สำคัญ
                              contentPadding: EdgeInsets.all(0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                            ),
                          ),
                        ),
                      ),

                      Text(
                        suffixText,
                        style: TextStyle(
                            fontSize: 20
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {

                    num currentValue = _formatter.parse(controller.text);

                    controller.text = _formatter.format(currentValue + step > maxValue ? maxValue : currentValue + step);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    fixedSize: Size(40, 40),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerRight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)
                    )
                  ),
                  child: Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        )
    ).showPopup(context);
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {

  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 0});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, // unused.
      TextEditingValue newValue,
      ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: min(truncated.length, truncated.length + 1),
          extentOffset: min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }

    return newValue;
  }
}

class _Formatter2 extends TextInputFormatter {
  
  final double minValue;
  final double maxValue;
  final NumberFormat formatter;
  
  const _Formatter2(this.formatter, double this.minValue, double this.maxValue);
  
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text;

    // ถ้ามีมากกว่า 1 ตัว และขึ้นต้นด้วย 0 แต่ตัวถัดไปไม่ใช่ .
    if (formatter.parse(text) < minValue) {
      return TextEditingValue(text: formatter.format(minValue));
    }

    if (formatter.parse(text) > maxValue) {
      return TextEditingValue(text: formatter.format(maxValue));
    }

    return newValue;
  }
}

class _Formatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text;

    // ถ้ามีมากกว่า 1 ตัว และขึ้นต้นด้วย 0 แต่ตัวถัดไปไม่ใช่ .
    if (text.length > 1 && text.startsWith('0') && !text.startsWith('0.')) {
      text = text.substring(1);
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    if (text.isEmpty) {
      return TextEditingValue(
          text: '0',
      );
    }

    return newValue;
  }
}