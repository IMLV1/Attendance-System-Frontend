import 'dart:typed_data';
import 'package:attendance_system/services/signature/signature_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart'; // อย่าลืมแก้ path ให้ตรง
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class ServiceSignaturePage extends StatefulWidget {
  final void Function(Uint8List? pngByte)? onSuccess;
  final void Function(Uint8List? pngByte, dynamic data)? onSuccessResponse;
  final void Function(Uint8List? pngByte, dynamic data)? onError;
  final Future<Response<dynamic>> Function(Uint8List? pngByte) request;
  final bool required;
  final Widget? infoWidget;
  final bool importSignature;
  final Uint8List? current;

  const ServiceSignaturePage({
    super.key,
    this.onSuccess,
    this.onSuccessResponse,
    this.onError,
    required this.request,
    this.infoWidget,
    this.importSignature = true,
    this.current,
    this.required = false,
  });

  @override
  State<ServiceSignaturePage> createState() => _ServiceSignaturePageState();
}

class _ServiceSignaturePageState extends State<ServiceSignaturePage> {
  late SignatureController _controller;
  Uint8List? _current;
  Uint8List? _imported;
  String? _error;

  @override
  void initState() {
    super.initState();
    _current = widget.current;

    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    // เมื่อเริ่มวาด ให้เคลียร์ลายเซ็นเก่าและเคลียร์แจ้งเตือน Error
    _controller.onDrawStart = () {
      setState(() {
        _current = null;
        _error = null;
      });
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: ServiceUpdater(
        onError: (data) async {
          final bytes = await _controller.toPngBytes() ?? _current;
          return widget.onError?.call(bytes, data);
        },
        request: () async {
          final bytes = await _controller.toPngBytes() ?? _current;
          return widget.request(bytes);
        },
        onSuccess: () async {
          if (widget.onSuccess != null) {
            final bytes = await _controller.toPngBytes() ?? _current;
            widget.onSuccess?.call(bytes);
          }
        },
        onSuccessResponse: (data) async {
          if (widget.onSuccessResponse != null) {
            final bytes = await _controller.toPngBytes() ?? _current;
            widget.onSuccessResponse?.call(bytes, data);
          }
        },
        builder: (trigger, state, errorMessage) {

          final bool isApiLoading = (state == ServiceUpdatorState.loading);

          // ⚡ ส่งปุ่ม "ส่ง" ขึ้นไปที่ Header ด้านบน
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.isCurrent != true) return;

            final provider = PopupProvider.of(context);
            if (provider.config.isLoading != isApiLoading || provider.config.buttonAction != trigger) {
              provider.setConfig(
                  provider.config.copyWith(
                    isLoading: isApiLoading,
                    buttonAction: (ctx) {
                      // เช็ค Required ก่อนยิง API
                      if (widget.required && _current == null && _controller.isEmpty) {
                        setState(() {
                          _error = 'กรุณาเซ็นลายเซ็น';
                        });
                        return;
                      }

                      setState(() => _error = null); // เคลียร์ Error
                      trigger(); // กดยิง API
                    },
                  )
              );
            }
          });

          return Column(
            spacing: 15,
            children: [
              Column(
                spacing: 5,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _current = null;
                              _controller.clear();
                              _error = null; // เคลียร์ Error ตอนกดแก้ไขด้วย
                            });
                          },
                          overlayColor: WidgetStatePropertyAll(Colors.transparent),
                          child: const Text(
                            'แก้ไข',
                            style: TextStyle(
                                color: Color(0xFF626262),
                                fontSize: 17
                            ),
                          ),
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
                          strokeAlign: BorderSide.strokeAlignInside,
                          color: _error == null ? Colors.grey : Colors.red // เปลี่ยนสีขอบถ้ามี Error
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      children: [
                        if (_current != null)
                          Center(
                            child: Image.memory(
                              _current!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Signature(
                          controller: _controller,
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),

                  // แจ้งเตือน Error
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  if (widget.infoWidget != null) widget.infoWidget!
                ],
              ),

              if (widget.importSignature)
                ServiceUpdater(
                  request: () => SignatureService().get(),
                  onSuccessResponse: (pngBytes) {
                    setState(() {
                      _imported = pngBytes;
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
                              color: _imported == null ? AppColors.buttonDisable : AppColors.primaryColor,
                              // ⚡ แก้ไขบั๊กเดิม: เปลี่ยนมาเช็ค state2 ของตัวเองแทน
                              arrow: state2 == ServiceUpdatorState.loading,
                              arrowIcon: const CupertinoActivityIndicator(),
                              onPressed: _imported == null ? null : () {
                                _controller.clear();
                                setState(() {
                                  _current = _imported;
                                  _error = null; // เคลียร์ Error เมื่อนำเข้าลายเซ็นสำเร็จ
                                });
                              },
                            ),
                          ],
                        ),
                        if (_imported == null)
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
        },
      ),
    );
  }
}