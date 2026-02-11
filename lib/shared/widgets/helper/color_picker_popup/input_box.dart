import 'package:flutter/material.dart';

class InputBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final int flex;

  const InputBox({super.key, required this.label, required this.controller, required this.onChanged, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}