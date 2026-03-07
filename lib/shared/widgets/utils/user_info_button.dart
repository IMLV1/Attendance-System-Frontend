import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserInfoButton extends StatelessWidget {

  final Widget icon;
  final String title;
  final String? subTitle;
  final List<Role> roles;
  final bool arrow;
  final VoidCallback? onPressed;
  final Color titleColor;
  final Color subTitleColor;
  final double? fontTitle;
  final double? fontSub;
  final FontWeight? fontWeightTitle;

  const UserInfoButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.arrow = true,
    this.onPressed,
    required this.roles,
    this.titleColor = Colors.black,
    this.subTitleColor = const Color(0xFF7E7E7E),
    this.fontTitle = 14,
    this.fontSub = 10,
    this.fontWeightTitle = FontWeight.normal
  });

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
                        style: TextStyle(fontSize: fontTitle, color: titleColor, fontWeight: fontWeightTitle),
                        softWrap: true,
                      ),

                      if (subTitle != null)
                        Text(
                          subTitle!,
                          style: TextStyle(fontSize: fontSub, color: subTitleColor),
                          softWrap: true,
                        ),
                    ],
                  ),
                ),
              ],
            )
            ),
          if (roles == [])
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
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: m.color.withAlpha((20 * 255 / 100).toInt()),
                              ),
                              child: Text(
                                m.name as String,
                                style: TextStyle(
                                  color: m.color,
                                  fontSize: 10
                                ),
                              )
                            );
                          }),
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