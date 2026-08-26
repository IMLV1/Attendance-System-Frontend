import 'package:attendance_system/services/notification/notification_service.dart';
import 'package:attendance_system/services/time_request/time_request_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_state.dart';
import '../../../services/leave/leave_model.dart';
import '../../../services/time_request/time_request_model.dart';
import '../../../shared/widgets/utils/attachment_picker.dart';
import '../../../shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import '../../../shared/widgets/utils/popup/multi_page/service_signature_page.dart';
import '../../../shared/widgets/utils/separator_card.dart';
import '../../../shared/widgets/utils/services/service_updater.dart';
import '../../../shared/widgets/utils/utils.dart';

class TimeRequestResend extends StatefulWidget {
  final String id;
  final TimeRequestModel data;
  final List<NetworkFile> allFiles;
  final void Function() onResend;

  const TimeRequestResend({
    super.key,
    required this.allFiles,
    required this.onResend,
    required this.data,
    required this.id,
    required List<NetworkFile> files
  });

  @override
  State<TimeRequestResend> createState() {
    return _TimeRequestResendState();
  }
}

class _TimeRequestResendState extends State<TimeRequestResend> {
  int limitFileSize = 52428800;

  bool _isConfigured = false;

  String? remark;
  List<NetworkFile> oldFiles = [];
  List<PlatformFile> allFiles = [];

  bool submitted = false;

  final TextEditingController _textEditingController = TextEditingController();

  String _formatDate(DateTime? date) {
    if (date == null) return '---';
    return '${DateFormat.MMMd('th_TH').format(date)} ${date.year + 543}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '---';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();

    remark = widget.data.remark;
    oldFiles = [...widget.allFiles];
    _textEditingController.text = widget.data.remark!;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final setting = authState.attendanceConfig;

    return ServiceUpdater(
      request: () => TimeRequestService().resend(
          widget.id,
          remark!,
          oldFiles,
          allFiles,
          null
      ),
      onSuccessResponse: (jsonData) {
        Navigator.of(context, rootNavigator: true).pop();
        widget.onResend();

        NotificationService().sendRequestNotification('APPROVER_ATTENDANCE', widget.id);
      },
      builder: (trigger, state, errorMessage) {

        final bool isApiLoading = (state == ServiceUpdatorState.loading);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ModalRoute.of(context)?.isCurrent != true) return;

          final provider = PopupProvider.of(context);

          // 👈 เปลี่ยนเงื่อนไขมาเช็ค !_isConfigured แทนการเช็ค trigger
          if (provider.config.isLoading != isApiLoading || !_isConfigured) {

            _isConfigured = true; // 👈 สั่งให้บันทึกว่าตั้งค่าปุ่มไปแล้ว จะได้ไม่วนลูปอีก

            provider.setConfig(
              // copyWith ดีมากตรงที่มันจะเก็บ Title เดิมไว้ แต่เปลี่ยนแค่ปุ่มกับ Loading
                provider.config.copyWith(
                  isLoading: isApiLoading,
                  buttonAction: (ctx) async {
                    setState(() {
                      submitted = true;
                    });

                    if (setting!.requiredRemark && _textEditingController.text.isEmpty) return;
                    if (setting!.requiredEvidenceFile && allFiles.isEmpty && oldFiles.isEmpty) return;

                    if (allFiles.fold(0, (sum, file) => sum + file.size) + oldFiles.fold(0, (sum, file) => sum + file.fileSize) > limitFileSize) return;

                    if (setting!.requestNeedSignature) {
                      final provider = PopupProvider.of(context);
                      final oldConfig = provider.config;

                      provider.setConfig(PopupConfig(
                          title: 'ลายเซ็น',
                          buttonLabel: 'ส่ง',
                          maxHeight: 700
                      ));

                      await provider.push(context, ServiceSignaturePage(
                        required: true,
                        infoWidget: Row(
                          spacing: 5,
                          children: [
                            SvgPicture.asset(
                              'assets/images/iicon.svg',
                              width: 15,
                              height: 15,
                            ),
                            Expanded(
                                child: Text.rich(
                                    TextSpan(
                                      text: 'โปรดทราบว่า การเซ็นลายเซ็นดิจิทัลนี้ใช้สำหรับ',
                                      children: [
                                        TextSpan(
                                          text: 'ยืนยันการขอการเข้า-ออกงานในครั้งนี้เท่านั้น',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' และจะไม่ถูกนำไปใช้เพื่อวัตถุประสงค์อื่น',
                                        ),
                                      ],
                                    )
                                )
                            )
                          ],
                        ),
                        request: (pngByte) => TimeRequestService().resend(
                            widget.id,
                            remark!,
                            oldFiles,
                            allFiles,
                            pngByte
                        ),
                        onSuccessResponse: (pngBytes, jsonData) {
                          Navigator.of(context, rootNavigator: true).pop();
                          widget.onResend();

                          NotificationService().sendRequestNotification('APPROVER_ATTENDANCE', widget.id);
                        },
                      ));

                      provider.setConfig(oldConfig);
                    } else {
                      trigger();
                    }
                  }, // ผูกปุ่มขวาบนเข้ากับ trigger ของหน้านี้!
                )
            );
          }
        });

        return Padding(
          padding: EdgeInsetsGeometry.only(right: 15, left: 15),
          child: Column(
            spacing: 6,
            children: [
              Row(
                spacing: 5,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      'assets/images/icon_req_lev.svg',
                    ),
                  ),
                  Text(
                    'รายละเอียดการเข้า-ออก',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  )
                ],
              ),
              Column(
                spacing: 13,
                children: [
                  Container(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10
                              ),
                              child: Row(
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(
                                      'assets/images/calendar_in.svg',
                                      colorFilter: ColorFilter.mode(Color(0xFF5F5F5F), BlendMode.srcIn),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'จากวันที่',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                          )
                                      ),
                                      Text(
                                          _formatDate(widget.data.fromDate),
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ),
                        Container(
                            width: 1.5,
                            height: 40,
                            color: Colors.grey[400],
                            margin: EdgeInsetsGeometry.symmetric(
                                horizontal: 3
                            )
                        ),
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10
                              ),
                              child: Row(
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(
                                      'assets/images/calendar_out.svg',
                                      colorFilter: ColorFilter.mode(
                                          Color(0xFF5F5F5F),
                                          BlendMode.srcIn
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'ถึงวันที่',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                          )
                                      ),
                                      Text(
                                          _formatDate(widget.data.toDate),
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF626262)
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                          'assets/images/clock_calendar.svg',
                                          colorFilter: ColorFilter.mode(
                                              Color(0xFF626262),
                                              BlendMode.srcIn
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'เวลาเข้างาน',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF626262)
                                              )
                                          ),
                                          Text(
                                              _formatTime(widget.data.startTime),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF626262)
                                              )
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            )
                        ),
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                          'assets/images/clock_calendar.svg',
                                          colorFilter: ColorFilter.mode(
                                              Color(0xFF626262),
                                              BlendMode.srcIn
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'เวลาออกงาน',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF626262)
                                              )
                                          ),
                                          Text(
                                              _formatTime(widget.data.endTime),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF626262)
                                              )
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            )
                        )
                      ],
                    ),
                  ),

                  if (setting!.specifyRemark)
                    TextField(
                      controller: _textEditingController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        errorText: (submitted && setting!.requiredRemark == true && _textEditingController.text.isEmpty) ? 'กรุณาระบุหมายเหตุ' : null,
                        errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 14
                        ),
                        isDense: true,
                        hintText: 'ระบุหมายเหตุ...',
                        hintStyle: TextStyle(
                            color: Color(0xFF7D7D7D),
                            fontSize: 15
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 11,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  if (setting!.evidenceFile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: (submitted &&
                                setting?.requiredEvidenceFile == true &&
                                ((allFiles.isEmpty && oldFiles.isEmpty) || (allFiles.fold(0, (sum, file) => sum + file.size) + oldFiles.fold(0, (sum, file) => sum + file.fileSize) > limitFileSize)))
                                ? Border.all(
                              color: Colors.red,
                              width: 1.5,
                            ) : null,
                          ),
                          child: SeparatorCard(
                            separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
                            children: [
                              // 🚩 (2026-08-27) เดิมตรงนี้เป็น MenuAnchor ~120 บรรทัดที่วาดเมนู
                              // คลังรูปภาพ/ถ่ายรูป/เลือกไฟล์ ขึ้นมาเอง และถูกก๊อปไว้เหมือนกัน 4 ที่
                              //
                              // ย้ายไป AttachmentPicker ซึ่งเลือกท่าให้ตรงกับแต่ละแพลตฟอร์ม — บนเว็บ
                              // ปล่อยให้เบราว์เซอร์เด้งชีตของ OS เอง (iOS Safari ให้ Photo Library /
                              // Take Photo / Choose Files อยู่แล้ว) ส่วนบนแอปใช้ชีตของ iOS/Android จริงๆ
                              AttachmentPickerButton(
                                onPicked: (file) => setState(() {
                                  allFiles.add(file);
                                }),
                              ),

                              Padding(
                                  padding: EdgeInsetsGeometry.all(10),
                                  child: (allFiles.isEmpty && oldFiles.isEmpty) ? Padding(
                                    padding: EdgeInsetsGeometry.all(5),
                                    child: Text(
                                      'ยังไม่ได้อัพโหลดไฟล์',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF7D7D7D), // สีจาง
                                      ),
                                    ),
                                  ) : SizedBox(
                                      width: double.infinity,
                                      child: Wrap(

                                        spacing: 5,
                                        runSpacing: 7,
                                        children: [

                                          ...oldFiles.map((file) {

                                            return Container(

                                                constraints: BoxConstraints(
                                                    maxWidth: 230
                                                ),

                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Color(0xFFBDBDBD), // stroke color
                                                    width: 2, // stroke width
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsetsGeometry.all(5),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Flexible(child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(file.fileName,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w800
                                                            )
                                                        ),
                                                        Text('ขนาด ${Utils.formatBytes(file.fileSize)}',
                                                            style: TextStyle(
                                                                color: Color(0xFF7D7D7D),
                                                                fontWeight: FontWeight.normal
                                                            )
                                                        ),
                                                      ],
                                                    )),
                                                    InkWell(
                                                      customBorder: CircleBorder(),
                                                      onTap: () {
                                                        setState(() {
                                                          oldFiles.remove(file);
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets.all(6),
                                                        child: Icon(
                                                          CupertinoIcons.xmark_circle_fill,
                                                          size: 17,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            );
                                          }),

                                          ...allFiles.map((file) {
                                            return Container(

                                                constraints: BoxConstraints(
                                                    maxWidth: 230
                                                ),

                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Color(0xFFBDBDBD), // stroke color
                                                    width: 2, // stroke width
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsetsGeometry.all(5),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Flexible(child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(file.name,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w800
                                                            )
                                                        ),
                                                        Text('ขนาด ${Utils.formatBytes(file.size)}',
                                                            style: TextStyle(
                                                                color: Color(0xFF7D7D7D),
                                                                fontWeight: FontWeight.normal
                                                            )
                                                        ),
                                                      ],
                                                    )),
                                                    InkWell(
                                                      customBorder: CircleBorder(),
                                                      onTap: () {
                                                        setState(() {
                                                          allFiles.remove(file);
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets.all(6),
                                                        child: Icon(
                                                          CupertinoIcons.xmark_circle_fill,
                                                          size: 17,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            );
                                          })
                                        ],
                                      )
                                  )
                              )
                            ],
                          ),
                        ),

                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, -0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: (submitted && setting!.requiredEvidenceFile && ((allFiles.isEmpty && oldFiles.isEmpty) || allFiles.fold(0, (sum, file) => sum + file.size) + oldFiles.fold(0, (sum, file) => sum + file.fileSize) > limitFileSize))
                              ? Padding(
                            padding: EdgeInsets.only(left: 13, top: 8),
                            child: Text(
                              (allFiles.fold(0, (sum, file) => sum + file.size) + oldFiles.fold(0, (sum, file) => sum + file.fileSize) > limitFileSize) ? 'ขนาดไฟล์รวมเกิน ${Utils.formatBytes(limitFileSize)}' : 'กรุณาแนบไฟล์',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ) : SizedBox(),
                        )
                      ],
                    ),
                ],
              ),
              SizedBox(height: 10),
              if (state == ServiceUpdatorState.error)
                const Text(
                  'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง...',
                  style: TextStyle(color: Colors.red),
                )
            ],
          ),
        );
      }
    );
  }
}