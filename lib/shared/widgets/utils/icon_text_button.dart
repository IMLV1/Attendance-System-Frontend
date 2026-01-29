import 'package:attendance_system/app/app.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconTextButton extends StatelessWidget {

  final String icon;
  final String label;
  final bool arrow;

  const IconTextButton({super.key, required this.icon, required this.label, this.arrow = true});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(

        onPressed: () {},
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
                SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      'assets/images/$icon',
                    )
                ),
                SizedBox(width: 10),
                Text(
                    label,
                    style: TextStyle(
                        fontSize: 15,
                      color: AppColors.blackTextColor,
                    )
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