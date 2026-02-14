import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FloatingPopup {

  final String title;
  final double width;
  final String description;
  final List<Widget> Function(void Function(String errorMessage), BuildContext context) buttons;

  FloatingPopup({this.title = 'Default Title', this.description = 'Default description', required this.buttons, this.width = 300});

  void showPopup(BuildContext context) {

    String errorMessage = '';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: CupertinoColors.black.withValues(alpha: 0.2),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {

        return StatefulBuilder(
          builder: (context, setState) {

            void setError(String message) {
              setState(() {
                errorMessage = message;
              });
            }

            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );

            final isReversing = animation.status == AnimationStatus.reverse;

            Widget dialog = Center(
              child: Container(
                width: width,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground
                      .resolveFrom(context),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30,
                      color: CupertinoColors.black.withValues(alpha: 0.2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.all(10),
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF767676),
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      spacing: 5,
                      children: [
                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [...buttons(setError, context).map((m) => Expanded(child: m))],
                        ),
                        if (errorMessage.isNotEmpty)
                          Text(
                            'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง...',
                            style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.none,
                              fontSize: 13,
                              fontWeight: FontWeight.normal
                            ),
                          )
                      ],
                    )
                  ],
                ),
              ),
            );

            // 🔥 เข้า = scale + fade
            if (!isReversing) {
              dialog = Transform.scale(
                scale: Tween(begin: 1.1, end: 1.0).evaluate(curved),
                child: Theme(
                  data: Theme.of(context),
                  child: dialog,
                ),
              );
            }

            // 🔥 ออก = fade อย่างเดียว
            return FadeTransition(
              opacity: curved,
              child: Theme(
                data: Theme.of(context),
                child: dialog,
              ),
            );
          }
        );
      },
    );
  }
}

class FloatingPopupButton extends StatelessWidget {

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final String text;

  const FloatingPopupButton({super.key, required this.onPressed, required this.text, this.backgroundColor = const Color(0xFFE0E0E2), this.foregroundColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50)
        ),
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 11),
        shadowColor: Colors.transparent,
        elevation: 0,
        overlayColor: Color(0xFF000000),
      ).copyWith(
        //overlayColor: MaterialStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        animationDuration: Duration(seconds: 0),
      ),
      onPressed: onPressed,

      child: Text(
        text,
        style: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: foregroundColor,
          fontSize: 17
        ),
      )
    );
  }
}

class FloatingServicePopupButton extends StatelessWidget {

  final VoidCallback onSuccess;
  final Color backgroundColor;
  final Color foregroundColor;
  final String text;
  final Future<Response<dynamic>> Function() request;
  final void Function(String errorMessage) setError;

  const FloatingServicePopupButton({
    super.key,
    required this.onSuccess,
    required this.text,
    required this.request,
    required this.setError,
    this.backgroundColor = const Color(0xFFE0E0E2),
    this.foregroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ServiceUpdater(
        request: request,
        onSuccess: onSuccess,
        builder: (trigger, state, errorMessage) {

          if (state == ServiceUpdatorState.error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setError(errorMessage);
            });
          }

          return ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)
                ),
                backgroundColor: backgroundColor,
                padding: EdgeInsets.symmetric(vertical: 11),
                shadowColor: Colors.transparent,
                elevation: 0,
                overlayColor: Color(0xFF000000),
              ).copyWith(
                //overlayColor: MaterialStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                animationDuration: Duration(seconds: 0),
              ),
              onPressed: trigger,

              child: (state == ServiceUpdatorState.loading) ? CupertinoActivityIndicator(color: foregroundColor) :
              Text(
                text,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                    fontSize: 17
                ),
              )
          );
        }
    );
  }
}