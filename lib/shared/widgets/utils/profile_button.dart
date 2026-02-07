import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {

  final Widget icon;
  final String title;
  final String subTitle;
  final bool disable;
  final VoidCallback? onPressed;

  const ProfileButton({super.key, required this.icon, required this.title, required this.subTitle, this.disable = false, this.onPressed});

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(

        onPressed: disable ? null : onPressed ?? () {},
        style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.all(0),
            disabledBackgroundColor: Colors.transparent,
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
                          width: 60,
                          height: 60,
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
                                style: TextStyle(fontSize: 16, color: Colors.black),
                                softWrap: true,
                              ),
                              Text(
                                subTitle,
                                style: TextStyle(fontSize: 13, color: Color(0xFF7E7E7E)),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ],
            )
        )
    );
  }
}