import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextButton extends StatelessWidget {

  final String label;
  final bool arrow;
  final VoidCallback? onPressed;
  final Color color;

  const TextButton({super.key, required this.label, this.arrow = true, this.onPressed, this.color = Colors.black});

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