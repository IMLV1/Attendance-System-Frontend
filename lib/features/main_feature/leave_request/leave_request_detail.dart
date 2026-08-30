import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/features/main_feature/leave_request/date_select.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_request_resend.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_type.dart';
import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/services/leave/leave_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/downloader.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/file_preview_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/floating_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/utils/animation/animated_widget.dart';

String formatDateTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')} น.';
}

String _formatDate(DateTime? date) {
  if (date == null) return '---';
  return '${DateFormat.MMMd('th_TH').format(date)} ${date.year + 543}';
}

String _formatTime(TimeOfDay? time) {
  if (time == null) return '---';
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

class LeaveRequestDetail extends StatefulWidget {
  final String requestID;
  final void Function() onCancel;
  final void Function() onResend;

  const LeaveRequestDetail({
    super.key,
    required this.requestID,
    required this.onCancel,
    required this.onResend,
  });

  @override
  State<LeaveRequestDetail> createState() {
    return _LeaveRequestDetailState();
  }
}

class _LeaveRequestDetailState extends State<LeaveRequestDetail> {

  LeaveRequestDetailModel? requestDetail;
  bool onSelect = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        // 🚩 (2026-08-27) จอมือถือกว้าง 393pt แต่โดนขอบกินไปสองชั้น
        // (หน้า + การ์ดสีเทา) เหลือให้เนื้อหาจริงไม่ถึง 330pt — บีบขอบหน้า
        // ลงบนจอเล็ก จอใหญ่ยังเว้นเท่าเดิมเพราะมีที่เหลือเฟือ
        top: 10,
        left: Responsive.isCompact(context) ? 14 : 20,
        right: Responsive.isCompact(context) ? 14 : 20,
      ),
      child: ServiceLoader(
          request: () => LeaveRequestService().getRequestDetail(widget.requestID),
          onSuccess: (val) {

            print(val);
            setState(() {
              requestDetail = LeaveRequestDetailModel.fromJson(val);
            });
          },
          builder: () {

            final status = requestDetail?.approveDetail.status ?? .pending;

            return Column(
              spacing: 13,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SeparatorCard(
                  borderRadius: BorderRadius.circular(22),
                  children: [
                    Column(
                      children: [
                        AppButton(
                          icon: status.icon,
                          title: switch (status) {
                            .approved => 'อนุมัติแล้ว',
                            .rejected => 'ไม่อนุมัติ',
                            .pending => 'รออนุมัติ',
                            .overdue => 'เลยกำหนดเวลา',
                            .canceled => 'ยกเลิก',
                          },
                          iconColor: status.color,
                          weightTitle: FontWeight.w500,
                          subTitle: switch (status) {
                            .overdue => 'คำขอนี้เลยกำหนดเวลาอนุมัติแล้ว',
                            .canceled => 'คำขอนี้ถูกยกเลิกแล้ว',
                            .pending => 'ตำแหน่งที่รับผิดชอบการอนุมัติ: ${requestDetail?.approveDetail.approveRole ?? '-'}',
                            _ => 'เนื่องจาก: ${requestDetail?.approveDetail.reason ?? '-'}',
                          },
                          arrow: false,
                          timeStamp: requestDetail?.approveDetail.approveDate != null
                              ? formatDateTime(requestDetail!.approveDetail.approveDate!)
                              : null,
                          onPressed: () {
                            setState(() {
                              onSelect = (!onSelect) ? true : false;
                            });
                          },
                        ),
                        AnimatedSizeWidget(
                          enable: onSelect && !(status == .pending || status == .overdue || status == .canceled),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              Padding(
                                  padding: EdgeInsetsGeometry.only(right: 15, left: 60),
                                  child: Divider(height: 0)
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 60, right: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ผู้อนุมัติ:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.lightTextColor,
                                        ),
                                      ),
                                      Text(
                                        requestDetail?.approveDetail.approver ?? '-',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                        softWrap: true,
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  )
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Color(0xFFEAEAEA)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppButton(
                        icon: requestDetail?.requestDetail.leaveType.icon ?? 'leave.svg',
                        title: requestDetail?.requestDetail.leaveType.display ?? '---',
                        bg: Colors.white,
                        weightTitle: FontWeight.w500,
                        subTitle: 'หมายเลขตำขอ ${widget.requestID}',
                        arrow: false,
                        onPressed: null,
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 12),
                          decoration: BoxDecoration(
                              color: Color(0xFFEAEAEA),
                              borderRadius: BorderRadius.circular(22)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                spacing: 10,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
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
                                                  Expanded(
                                                    // 🚩 (2026-08-27) ต้องห่อ Expanded ไม่งั้น Column กว้างตามเนื้อหาตัวเอง
                                                    // แล้วล้นกรอบบนจอแคบ — เจอบน iPhone: "RIGHT OVERFLOWED BY 2.9 PIXELS"
                                                    // ตรงบรรทัด "4 ส.ค. 2569 เช้า" (ยาวกว่าที่มีให้อยู่ไม่กี่ px)
                                                    child: Column(
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
                                                            '${_formatDate(requestDetail!.requestDetail.dateFrom)} ${(requestDetail!.requestDetail.fromDateMorning) ? 'เช้า' : 'เย็น'}',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors.black
                                                            )
                                                        ),
                                                      ],
                                                    ),
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
                                                  horizontal: 10,
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
                                                  Expanded(
                                                    // 🚩 (2026-08-27) ต้องห่อ Expanded ไม่งั้น Column กว้างตามเนื้อหาตัวเอง
                                                    // แล้วล้นกรอบบนจอแคบ — เจอบน iPhone: "RIGHT OVERFLOWED BY 2.9 PIXELS"
                                                    // ตรงบรรทัด "4 ส.ค. 2569 เช้า" (ยาวกว่าที่มีให้อยู่ไม่กี่ px)
                                                    child: Column(
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
                                                            '${_formatDate(requestDetail!.requestDetail.dateTo)} ${(requestDetail!.requestDetail.toDateMorning) ? 'เช้า' : 'เย็น'}',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors.black
                                                            )
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                  /*Row(
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
                                                          _formatTime(widget.model.startTime),
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.black
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
                                                          _formatTime(widget.model.endTime),
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.black
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
                                )*/
                                ],
                              ),
                            ],
                          )
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'หมายเหตุ:',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.lightTextColor,
                              ),
                            ),
                            Text(
                              requestDetail?.requestDetail.remark ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              softWrap: true,
                            ),
                            SizedBox(height: 10)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  spacing: 10,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        SvgPicture.asset('assets/images/icon_attach_evidence.svg'),
                        Text('ไฟล์ที่แนบมา')
                      ],
                    ),
                    if (requestDetail!.requestDetail.evidenceFiles.isNotEmpty)
                      ...requestDetail!.requestDetail.evidenceFiles.map((file) {

                        bool downloading = false;
                        MenuController menuController = MenuController();

                        return Material(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                FilePreviewPopup(

                                    file: file
                                ).showPopup(context);
                              },
                              splashFactory: NoSplash.splashFactory,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      child: Row(
                                        spacing: 6,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: SvgPicture.asset(
                                              file.fileType.toLowerCase() == 'pdf' ? 'assets/images/file.svg' : 'assets/images/photos_upload.svg',
                                              colorFilter: ColorFilter.mode(Colors.grey.shade800, BlendMode.srcIn),
                                            ),
                                          ),
                                          Expanded(child: Text(file.fileName)),
                                        ],
                                      ),
                                    ),
                                  ),

                                  StatefulBuilder(
                                      builder: (context, setState) {
                                        return downloading ?
                                        Padding(
                                          padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                                          child: Center(child: CupertinoActivityIndicator()),
                                        ) :
                                        MenuAnchor(
                                          controller: menuController,
                                          useRootOverlay: true,
                                          builder: (context, controller, child) {
                                            return InkWell(
                                              overlayColor: WidgetStatePropertyAll(Colors.transparent),
                                              onTap: () {
                                                menuController.open();
                                              },
                                              child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                  child: SvgPicture.asset(
                                                    'assets/images/icon_file_menu.svg',
                                                    colorFilter: ColorFilter.mode(
                                                      Colors.grey.shade600,
                                                      BlendMode.srcIn,
                                                    ),
                                                  )
                                              ),
                                            );
                                          },
                                          clipBehavior: Clip.none,
                                          consumeOutsideTap: true,
                                          style: const MenuStyle(
                                            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                                            elevation: WidgetStatePropertyAll(0),
                                          ),
                                          menuChildren: [
                                            TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0, end: 1),
                                              duration: const Duration(milliseconds: 250),
                                              curve: Curves.easeOut,
                                              builder: (context, value, child) {
                                                return Opacity(
                                                  opacity: value,
                                                  child: child,
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.18),
                                                      blurRadius: 100,
                                                      spreadRadius: 6,
                                                      offset: Offset.zero,
                                                    ),
                                                  ],
                                                ),
                                                child: SeparatorCard(
                                                  borderRadius: BorderRadius.circular(20),
                                                  children: [
                                                    // 🚩 (2026-08-26) เดิมเป็นปุ่มเดียวชื่อ "ส่งออกไฟล์" ที่ทำสองความหมายปนกัน
                                                    // — บนมือถือมันเปิด share sheet (ส่งต่อ) บนเว็บมันเปิดแท็บใหม่ (ดู)
                                                    // ไม่มีทางไหนเลยที่บันทึกลงเครื่องจริงๆ แยกเป็นสองปุ่มตามที่ผู้ใช้ตั้งใจ
                                                    IconTextButton(
                                                      icon: 'download.svg',
                                                      arrow: false,
                                                      label: 'บันทึกไฟล์',
                                                      onPressed: () async {
                                                        menuController.close();
                                                        Downloader(
                                                            onDownloadStart: () => setState(() {
                                                              downloading = true;
                                                            }),
                                                            onDownloadSuccess: () => setState(() {
                                                              downloading = false;
                                                            })
                                                        ).saveFile(file);
                                                      },
                                                    ),
                                                    // เว็บไม่มี share sheet ที่ส่งไฟล์ได้จริง จึงไม่ต้องมีปุ่มนี้
                                                    if (Downloader.canShare)
                                                      IconTextButton(
                                                        icon: 'icon_send.svg',
                                                        arrow: false,
                                                        label: 'แชร์ไฟล์',
                                                        onPressed: () async {
                                                          menuController.close();
                                                          Downloader(
                                                              onDownloadStart: () => setState(() {
                                                                downloading = true;
                                                              }),
                                                              onDownloadSuccess: () => setState(() {
                                                                downloading = false;
                                                              })
                                                          ).shareFile(file, origin: Downloader.originOf(context));
                                                        },
                                                      ),
                                                    Padding(
                                                      padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 5),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'ขนาด: ${Utils.formatBytes(file.fileSize)}',
                                                            style: TextStyle(
                                                                color: Color(0xFF7D7D7D)
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                  )
                                ],
                              )
                          ),
                        );

                        // if (file.fileType.toLowerCase() == 'pdf') {
                        //   return SizedBox(
                        //     height: 500, // สำคัญมาก
                        //     child: SfPdfViewer.network(
                        //         file.fileUrl
                        //     ),
                        //   );
                        // }
                        //
                        // return Image.network(file.fileUrl);
                      })
                    else
                      SizedBox(
                        width: double.infinity,
                        child: SeparatorCard(
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.all(20),
                              child: Text(
                                'ไม่มีไฟล์แนบ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF7D7D7D), // สีจาง
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                  ],
                ),

                if (requestDetail!.approveDetail.status == .pending)
                  SeparatorCard(
                    children: [
                      IconTextButton(
                        icon: 'cancel.svg',
                        label: 'ยกเลิกคำขอลางาน',
                        color: Colors.red, // ลบ const ข้างหน้าออก
                        arrow: false,
                        onPressed: () async {
                          FloatingPopup(
                              title: 'ยกเลิกคำขอ',
                              description: 'คุณยืนยันที่จะยกเลิกคำขอ${requestDetail!.requestDetail.leaveType.display} หมายเลข: ${widget.requestID} หรือไม่? การดำเนินการนี้จะไม่สามารถย้อนกลับมาได้อีก',
                              buttons: (setError, context2) {
                                return [
                                  FloatingPopupButton(
                                    onPressed: () {
                                      Navigator.of(context2).pop();
                                    },
                                    text: 'ยกเลิก',
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.primaryColor,
                                  ),
                                  FloatingServicePopupButton(
                                      setError: setError,
                                      foregroundColor: Colors.red,
                                      text: 'ยืนยัน',
                                      onSuccess: () async {
                                        Navigator.of(context2).pop();
                                        await Future.delayed(const Duration(milliseconds: 200));
                                        if (!context.mounted) return;
                                        Navigator.of(context, rootNavigator: true).pop();
                                        widget.onCancel();
                                      },
                                      request: () => LeaveRequestService().cancelRequest(widget.requestID),
                                  ),
                                ];
                              }
                          ).showPopup(context);
                        },
                      )
                    ],
                  )
                else if ((requestDetail!.approveDetail.status == .rejected || requestDetail!.approveDetail.status == .canceled) && (requestDetail!.requestDetail.leaveType.getSetting(context)!.allowRetroactive || requestDetail!.requestDetail.dateFrom.isAfter(DateTime.now())))
                  SeparatorCard(
                    children: [
                      IconTextButton(
                        icon: 'redo.svg',
                        label: 'แก้ไขรายละเอียด และส่งคำขอใหม่',
                        color: AppColors.primaryColor, // ลบ const ข้างหน้าออก
                        arrow: false,
                        onPressed: () async {

                          final provider = PopupProvider.of(context);
                          final oldConfig = provider.config;

                          provider.setConfig(PopupConfig(
                              title: 'แก้ไขรายละเอียด',
                              buttonLabel: 'ส่งอีกครั้ง',
                              maxHeight: 700
                            // buttonAction: (ctx) {...} ยังไม่ต้องใส่ เพราะเดี๋ยวหน้า 2 จะมาทับให้
                          ));

                          await provider.push(
                              context,
                              LeaveRequestResend(
                                requestId: widget.requestID,
                                leaveType: requestDetail!.requestDetail.leaveType,
                                leaveDate: LeaveDate(
                                  fromDate: requestDetail!.requestDetail.dateFrom,
                                  toDate: requestDetail!.requestDetail.dateTo,
                                  fromDateMorning: requestDetail!.requestDetail.fromDateMorning,
                                  toDateMorning: requestDetail!.requestDetail.toDateMorning,
                                ),
                                remark: requestDetail!.requestDetail.remark,
                                allFiles: requestDetail!.requestDetail.evidenceFiles,
                                onResend: widget.onResend,
                              )
                          );

                          provider.setConfig(oldConfig);
                        },
                      )
                    ],
                  )
              ],
            );
          }
      ),
    );
  }
}