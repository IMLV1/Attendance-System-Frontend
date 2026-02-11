import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserCancelCheckbox extends StatefulWidget {
  final Widget icon;
  final String title;
  final String subTitle;
  final bool checkBox;
  final VoidCallback? onCancel;
  final ValueChanged<bool>? onChanged;

  const UserCancelCheckbox({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.checkBox = false,
    this.onCancel,
    this.onChanged,
  });

  @override
  State<UserCancelCheckbox> createState() => _UserCancelCheckboxState();
}

class _UserCancelCheckboxState extends State<UserCancelCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: widget.icon,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.subTitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF7E7E7E),
                        ),
                      ),
                    ],
                  ),
                ),

                /// ❌ ปุ่มลบ
                if (!widget.checkBox)
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onCancel,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 17,
                        color: Colors.black,
                      ),
                    ),
                  )

                /// ☑️ Checkbox
                else
                  Checkbox(
                    value: isChecked,
                    activeColor: Color(0xFF505050),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(5)
                    ),
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                      widget.onChanged?.call(isChecked);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
