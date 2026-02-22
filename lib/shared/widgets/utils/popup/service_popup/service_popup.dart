import 'package:attendance_system/shared/theme/app_colors.dart';
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

    final theme = Theme.of(context);

    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 400), // 👈 ปรับความช้าตรงนี้
      reverseDuration: const Duration(milliseconds: 200),
    );

    showModalBottomSheet(
      context: context,
      useRootNavigator: true, // 👈 เพิ่มบรรทัดนี้
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionAnimationController: controller,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Theme(
                data: theme,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight),
                      child: Material(borderRadius: BorderRadius.circular(40), child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 30,
                                spreadRadius: 10,
                                offset: const Offset(0, 0), // 👈 360° shadow
                              ),
                            ],
                          ),
                          child: ServiceUpdater(
                              request: request,
                              onSuccess: () => onSuccess?.call(context),
                              onSuccessResponse: (jsonData) => onSuccessResponse?.call(context, jsonData),
                              builder: (trigger, state, errorMessage) {
                                return SafeArea(
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

                                                  if (actionButton) Align(
                                                      alignment: Alignment.bottomRight,
                                                      child: (state == ServiceUpdatorState.loading) ? CupertinoActivityIndicator(color: AppColors.primaryColor) :
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
                                                              fontFamily: 'Inter',
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
                                              fit: fit,
                                              child: SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                                physics: const AlwaysScrollableScrollPhysics(),
                                                child: builder(trigger, state, errorMessage),
                                              )
                                          )
                                        ],
                                      ),
                                    )
                                );
                              }
                          )
                      )),
                    )
                )
            );
          }
        );
      }
    );
  }
}
