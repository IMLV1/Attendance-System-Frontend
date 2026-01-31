import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconTextButton extends StatelessWidget {

  final String icon;
  final String label;
  final bool arrow;
  final VoidCallback? onPressed;
  final Color color;

  const IconTextButton({
    super.key,
    required this.icon,
    required this.label,
    this.arrow = true,
    this.onPressed,
    this.color = Colors.black
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
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      'assets/images/$icon',
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    )
                ),
                SizedBox(width: 10),
                Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      color: color
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