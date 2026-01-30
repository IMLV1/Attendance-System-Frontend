import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserInfoButton extends StatelessWidget {

  final Widget icon;
  final String title;
  final String subTitle;
  final bool arrow;
  final VoidCallback? onPressed;

  const UserInfoButton({super.key, required this.icon, required this.title, required this.subTitle, this.arrow = true, this.onPressed});

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
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  color: Colors.red
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