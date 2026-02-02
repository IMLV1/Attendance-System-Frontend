import 'dart:io';

import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PushPopup {

  final String title;
  final String buttonLabel;
  final VoidCallback? buttonAction;
  final bool backButton;
  final Widget content;

  const PushPopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.buttonAction,
    this.backButton = true,
    required this.content
  });

  void showPopup(BuildContext context) {

    final theme = Theme.of(context);

    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return Theme(
            data: theme,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(minHeight: 750),
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 15,
                    children: [
                      Container(
                        color: Color(0xFFA6A6A6),
                        width: 70,
                        height: 3,
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                              spacing: 13,
                              children: [
                                Column(
                                  spacing: 1,
                                  children: [
                                    Stack(
                                      children: [
                                        if (backButton) Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Transform.translate(
                                                offset: Offset(-5, 0),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                                    minimumSize: Size.zero,
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor: Colors.transparent,
                                                    overlayColor: Colors.transparent,
                                                  ),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: SvgPicture.asset(
                                                    'assets/images/back_button.svg',
                                                    colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                  ),
                                                )
                                            )
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                              title,
                                              style: TextStyle(
                                                decoration: TextDecoration.none,
                                                fontSize: 20,
                                                color: Colors.black,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.normal,

                                              )
                                          ),
                                        ),

                                        if (buttonLabel != '') Align(
                                            alignment: Alignment.bottomRight,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                overlayColor: Colors.transparent,
                                              ),
                                              onPressed: buttonAction,
                                              child: Text(
                                                  buttonLabel,
                                                  style: TextStyle(
                                                    decoration: TextDecoration.none,
                                                    fontSize: 17,
                                                    color: AppColors.primaryColor,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.normal,

                                                  )
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                    Divider(height: 0)
                                  ],
                                ),
                                content
                              ]
                          )
                      ),
                    ],
                  ),
                ),
              ),
            )
          );
        }
    );
  }
}
