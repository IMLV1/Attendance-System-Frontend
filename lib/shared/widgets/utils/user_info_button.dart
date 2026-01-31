import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserInfoButton extends StatelessWidget {

  final Widget icon;
  final String title;
  final String subTitle;
  final List<Map<String, String>> roles;
  final bool arrow;
  final VoidCallback? onPressed;

  const UserInfoButton({super.key, required this.icon, required this.title, required this.subTitle, this.arrow = true, this.onPressed, required this.roles});

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(

      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.all(0),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
      ),

      child: Padding(
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
                        style: TextStyle(fontSize: 14),
                        softWrap: true,
                      ),
                      Text(
                        subTitle,
                        style: TextStyle(fontSize: 10),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            )
            ),
            Expanded(
              flex: 2,
              child: IntrinsicHeight(
                child: Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 1,
                      color: Colors.grey, // 👈 remove fixed height
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          ...roles.map((m) {
                            String? hex = m['role-color'];
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Color(int.parse("33$hex", radix: 16)),
                              ),
                              child: Text(
                                m['role-name'] as String,
                                style: TextStyle(
                                  color: Color(int.parse("FF$hex", radix: 16)),
                                  fontSize: 10
                                ),
                              )
                            );
                          })
                        ]
                      ),
                    ),
                  ],
                ),
              )
            ),
            if (arrow) SizedBox(
              height: 10,
              width: 10,
              child: SvgPicture.asset(
                'assets/images/icon_next.svg',
              )
            ),
          ],
        )
      )
    );
  }

}