import 'package:flutter/cupertino.dart';
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
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.red,
                  ),
                  child: Center(child: icon)
                ),
                Spacer(),
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