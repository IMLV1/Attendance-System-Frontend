import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserCancelCheckbox extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subTitle;
  final bool checkBox;
  final VoidCallback? onCancel;
  final ValueChanged<bool>? onChanged;
  final bool value;

  const UserCancelCheckbox({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.checkBox = false,
    this.onCancel,
    this.onChanged,
    this.value = false,
  });

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
                  child: icon,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title),
                      Text(
                        subTitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF7E7E7E),
                        ),
                      ),
                    ],
                  ),
                ),

                if (!checkBox)
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onCancel,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 17,
                        color: Colors.black,
                      ),
                    ),
                  )
                else
                  Checkbox(
                    value: value,
                    activeColor: const Color(0xFF505050),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onChanged: (val) {
                      onChanged?.call(val ?? false);
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
