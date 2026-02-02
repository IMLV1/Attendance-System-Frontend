import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextValueButton extends StatelessWidget {

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final String value;
  final bool disable;

  const TextValueButton({
    super.key,
    required this.label,
    required this.value,
    this.disable = false,
    this.onPressed,
    this.color = Colors.black,
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
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Row(
                  spacing: 3,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7C7C7C),
                        ),
                      ),
                    ),
                    if (!disable) const SizedBox(width: 4),
                    if (!disable)
                      SizedBox(
                        height: 10,
                        width: 10,
                        child: SvgPicture.asset(
                          'assets/images/icon_next.svg',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )
      )
    );
  }
}