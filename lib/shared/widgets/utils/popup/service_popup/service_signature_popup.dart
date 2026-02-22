import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/service_popup/service_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';

class ServiceSignaturePopup {
  final String title;
  final String buttonLabel;
  final void Function(Uint8List? pngByte)? onSuccess;
  final void Function(Uint8List? pngByte, dynamic data)? onSuccessResponse;
  final Future<Response<dynamic>> Function(Uint8List? pngByte) request;
  final bool backButton;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final String? Function()? check;
  final Widget? infoWidget;
  final bool importSignature;
  final Uint8List? current;

  const ServiceSignaturePopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.onSuccess,
    this.onSuccessResponse,
    required this.request,
    this.check,
    this.backButton = true,
    this.maxHeight = 700,
    this.minHeight = 0,
    this.fit = FlexFit.tight,
    this.infoWidget,
    this.importSignature = true,
    this.current,
  });

  void showPopup(BuildContext context) {

    Uint8List? current = this.current;

    final SignatureController controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    ServicePopup(
      title: title,
      buttonLabel: buttonLabel,
      minHeight: minHeight,
      maxHeight: maxHeight,
      fit: fit,
      request: () async {
        final signatureBytes = await controller.toPngBytes();
        return request(signatureBytes);
      },
      onSuccess: (context) async {
        if (onSuccess != null) {
          Navigator.of(context).pop();
          onSuccess?.call(await controller.toPngBytes() ?? current);
        }
      },
      onSuccessResponse: (context, data) async {
        if (onSuccessResponse != null) {
          Navigator.of(context).pop();
          onSuccessResponse?.call(await controller.toPngBytes() ?? current, data);
        }
      },
      check: check,
      builder: (trigger, state, errorMessage) {

        return StatefulBuilder(

          builder: (context, setState) {
            controller.onDrawStart = () {
              setState(() {
                current = null;
              });
            };

            return Column(
              spacing: 15,
              children: [
                Column(
                  spacing: 5,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            child: Text(
                              'แก้ไข',
                              style: TextStyle(
                                  color: Color(0xFF626262),
                                  fontSize: 17
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                current = null;
                                controller.clear();
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 250,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            strokeAlign: BorderSide.strokeAlignOutside,
                            color: Colors.grey
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Stack(
                        children: [
                          if (current != null)
                            Center(
                              child: Image.memory(
                                current!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Signature(
                            controller: controller,
                            backgroundColor: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                    ?infoWidget
                  ],
                ),
                if (importSignature) SeparatorCard(
                  children: [
                    IconTextButton(
                      icon: 'icon_signature.svg',
                      label: 'นำเข้าลายเซ็น',
                      color: AppColors.primaryColor,
                      arrow: false,
                    )
                  ],
                ),
                if (state == ServiceUpdatorState.error)
                  const Text(
                    'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง...',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            );
          }
        );
      }
    ).showPopup(context);
  }

}