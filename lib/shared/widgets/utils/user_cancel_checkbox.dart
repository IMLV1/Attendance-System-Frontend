import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserCancelCheckbox extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subTitle;
  final bool checkBox;

  const UserCancelCheckbox({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.checkBox = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              spacing: 13,
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

                Expanded( // 👈 gives bounded width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        softWrap: true,
                      ),
                      Text(
                        subTitle,
                        style: TextStyle(fontSize: 10, color: Color(0xFF7E7E7E)),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                if (!checkBox)
                  InkWell(
                    customBorder: CircleBorder(),
                    onTap: () {
                      // TODO: cancel select
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
              ],
            )
          ),
        ],
      )
    );
  }
}
