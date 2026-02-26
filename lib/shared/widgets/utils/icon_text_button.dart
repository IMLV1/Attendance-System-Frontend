import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconTextButton extends StatelessWidget {

  final String icon;
  final String label;
  final bool arrow;
  final VoidCallback? onPressed;
  final Color? color;
  final Widget? arrowIcon;
  final Color? backgroundColor;

  const IconTextButton({
    super.key,
    required this.icon,
    required this.label,
    this.arrow = true,
    this.onPressed,
    this.color = Colors.black,
    this.backgroundColor = Colors.white,
    this.arrowIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(

        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.all(0),
          shadowColor: Colors.transparent,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          disabledBackgroundColor: backgroundColor,
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
                      colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
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
                if (arrow)
                  (arrowIcon == null) ? SizedBox(
                    height: 10,
                    width: 10,
                    child: SvgPicture.asset(
                      'assets/images/icon_next.svg',
                    )
                  ) :
                  arrowIcon!
              ],
            )
        )
    );
  }
}