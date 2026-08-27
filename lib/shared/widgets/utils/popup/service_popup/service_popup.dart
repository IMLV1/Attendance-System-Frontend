import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/theme/app_theme.dart';
import 'package:attendance_system/shared/widgets/utils/popup/popup_surface.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServicePopup {

  final String title;
  final String buttonLabel;
  final void Function(BuildContext context)? onSuccess;
  final void Function(BuildContext context, dynamic data)? onSuccessResponse;
  final bool backButton;
  final bool actionButton;
  final Widget Function(
      Function() trigger,
      ServiceUpdatorState state,
      String errorMessage
      ) builder;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final Future<Response<dynamic>> Function() request;
  final String? Function()? check;

  const ServicePopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.backButton = true,
    this.actionButton = true,
    required this.request,
    this.onSuccess,
    this.onSuccessResponse,
    required this.builder,
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.loose,
    this.check,
  });

  void showPopup(BuildContext context) {

    // 🚩 (2026-08-24) ย้ายเปลือก (แผ่นเลื่อน/มุมโค้ง/เงา/ขีดจับ/เพดานความสูง)
    // ไปให้ PopupSurface ตัดสินตามขนาดจอ — ดูคำอธิบายเหตุผลใน popup_surface.dart
    PopupSurface.show(
      context: context,
      maxHeight: maxHeight,
      minHeight: minHeight,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ServiceUpdater(
                              request: request,
                              onSuccess: () => onSuccess?.call(context),
                              onSuccessResponse: (jsonData) => onSuccessResponse?.call(context, jsonData),
                              builder: (trigger, state, errorMessage) {
                                return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 15,
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
                                                          fontFamily: AppTheme.systemFontFamily,
                                                          fontWeight: FontWeight.normal,

                                                        )
                                                    ),
                                                  ),

                                                  if (actionButton) Align(
                                                      alignment: Alignment.bottomRight,
                                                      child: (state == ServiceUpdatorState.loading) ? CupertinoActivityIndicator() :
                                                      TextButton(
                                                          style: TextButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                                            minimumSize: Size.zero,
                                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              if (check?.call() == null) {
                                                                trigger();
                                                              }
                                                            });
                                                          },
                                                          child: Text(
                                                            buttonLabel,
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              color: AppColors.primaryColor,
                                                              fontFamily: AppTheme.systemFontFamily,
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          )
                                                      )
                                                  ),
                                                ],
                                              ),
                                              Divider(height: 0)
                                            ],
                                          ),

                                          Flexible(
                                              // ดูคำอธิบายเดียวกันใน push_popup.dart
                                              fit: PopupSurface.presentationOf(context) == PopupPresentation.dialog
                                                  ? FlexFit.loose
                                                  : fit,
                                              child: SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                                physics: const AlwaysScrollableScrollPhysics(),
                                                child: builder(trigger, state, errorMessage),
                                              )
                                          )
                                        ],
                                );
                              }
            );
          }
        );
      }
    );
  }
}
