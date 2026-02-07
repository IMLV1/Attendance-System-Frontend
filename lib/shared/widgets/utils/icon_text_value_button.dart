import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconTextValueButton extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final bool arrow;
  final Color lebelColor;
  final Color lebelValue;
  final VoidCallback? onPressed;
  final bool disable;

  const IconTextValueButton({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.arrow = true,
    this.onPressed,
    this.disable = false,
    this.lebelColor = Colors.black, 
    this.lebelValue = const Color(0xFF7C7C7C),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: disable ? null : onPressed ?? () {},
        style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.all(0),
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
        ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          spacing: 10,
          children: [
            SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                  'assets/images/$icon',
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                )
            ),
            Text(
                label,
                style: TextStyle(
                    fontSize: 15,
                    color: lebelColor,
                )
            ),
            Spacer(),
            Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: lebelValue,
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