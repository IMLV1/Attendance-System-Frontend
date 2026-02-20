import 'package:attendance_system/core/data/entities/user_management_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextRoleButton extends StatelessWidget {

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final List<Role> roles;
  final bool disable;
  final Widget icon;

  const TextRoleButton({
    super.key,
    required this.label,
    required this.roles,
    this.disable = false,
    this.onPressed,
    this.color = Colors.black,
    required this.icon
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
                  flex: 2,
                  child: Row(
                    spacing: 10,
                    children: [
                      SizedBox(
                          height: 20,
                          width: 20,
                          child: icon
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          color: color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                ),
                Flexible(
                  flex: 3,
                  child: Row(
                    spacing: 3,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
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
                            })
                          ]
                        )
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