import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInputPopup extends PushPopup {

  final String label;
  final String info;
  final String value;

  final TextEditingController controller = TextEditingController(text: "Default value");

  TextInputPopup({
    required this.label, this.info = '', this.value = ''}) : super(
    content: Column(
      children: [
        _TextInputContent(value: value, label: label)
      ],
    ),
  );
}

class _TextInputContent extends StatefulWidget {
  final String value;
  final String label;

  const _TextInputContent({required this.value, required this.label});

  @override
  State<_TextInputContent> createState() => _TextInputContentState();
}

class _TextInputContentState extends State<_TextInputContent> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(
            color: Color(0xFFD9D9D9),
            width: 1,
          ),
        ),
      ),
    );
  }
}
