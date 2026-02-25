import 'package:attendance_system/services/signature/signature_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
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
  final bool required;
  final Widget? infoWidget;
  final bool importSignature;
  final Uint8List? current;

  const ServiceSignaturePopup({
    this.title = 'Default Title',
    this.buttonLabel = '',
    this.onSuccess,
    this.onSuccessResponse,
    required this.request,
    this.backButton = true,
    this.maxHeight = 700,
    this.minHeight = 0,
    this.fit = FlexFit.tight,
    this.infoWidget,
    this.importSignature = true,
    this.current,
    this.required = false,
  });


  void showPopup(BuildContext context) {

    Uint8List? current = this.current;
    Uint8List? imported;

    String? error;

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
      check: () {
        if (required) {
          if (current == null && controller.isEmpty) {
            error = 'กรุณาเซ็นลายเซ็น';
            return error;
          }
        }
      },
      request: () async {
        return request(await controller.toPngBytes() ?? current);
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
                            color: error == null ? Colors.grey : Colors.red
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
                    if (error != null)Text(
                      error!,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.red
                      ),
                    ),
                    ?infoWidget
                  ],
                ),
                if (importSignature)
                  ServiceUpdater(
                    request: () => SignatureService().get(),
                    onSuccessResponse: (pngBytes) {
                      setState(() {
                        imported = pngBytes;
                      });
                    },
                    fetchOnInit: true,
                    builder: (trigger2, state2, errorMessage2) {

                      return Column(
                        children: [
                          SeparatorCard(
                            children: [
                              IconTextButton(
                                icon: 'icon_signature.svg',
                                label: 'นำเข้าลายเซ็น',
                                color: imported == null ? AppColors.buttonDisable : AppColors.primaryColor,
                                arrow: state == ServiceUpdatorState.loading,
                                arrowIcon: CupertinoActivityIndicator(),
                                onPressed: imported == null ? null : () {
                                  setState(() {
                                    current = imported;
                                  });
                                },
                              ),
                            ],
                          ),

                          if (imported == null)
                            Padding(
                                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                                child: Row(
                                  spacing: 6,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text.rich(
                                            TextSpan(
                                              text: 'เพิ่มลายเซ็นเพื่อใช้ฟีเจอร์ \'นำเข้าลายเซ็น\' ในหน้า ',
                                              style: TextStyle(
                                                color: Color(0xFF7D7D7D),
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'การตั้งค่า > เพิ่มลายเซ็น',
                                                  style: TextStyle(
                                                    color: Color(0xFF7D7D7D),
                                                    decorationColor: Color(0xFF7D7D7D),
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                )
                                              ],
                                            )
                                        )
                                    )
                                  ],
                                )
                            )
                        ],
                      );
                    },
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