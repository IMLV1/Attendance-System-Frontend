import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PushPopup {

  final String title;
  final String buttonLabel;
  final void Function(BuildContext context)? buttonAction;
  final bool backButton;
  final Widget content;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final bool scroll;

  const PushPopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.buttonAction,
    this.backButton = true,
    required this.content,
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.loose,
    this.scroll = true,
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
                  child: ConstrainedBox(constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight),
                    child: Material(borderRadius: BorderRadius.circular(40), child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
                      child: SafeArea(
                          top: false,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.88
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 15,
                              children: [
                                Container(
                                  color: Color(0xFFA6A6A6),
                                  width: 70,
                                  height: 3,
                                ),
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
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              onPressed: buttonAction == null
                                                  ? null
                                                  : () => buttonAction!(context),
                                              child: Text(
                                                buttonLabel,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: AppColors.primaryColor,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                    Divider(height: 0)
                                  ],
                                ),

                                Flexible(
                                  fit: fit,
                                  child: scroll ? SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: content,
                                  ) : content,
                                )


                                // Flexible(
                                //   key: _contentKey,
                                //   fit: FlexFit.tight,
                                //   child: SingleChildScrollView(
                                //     physics: const AlwaysScrollableScrollPhysics(),
                                //     child: content,
                                //   )
                                // )
                              ],
                            ),
                          )
                      ),
                    )),
                  )
                )
            );
        }
    );
  }
}
