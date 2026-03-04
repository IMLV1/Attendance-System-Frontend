import 'package:attendance_system/features/main_feature/time_request/time_request_resend.dart';
import 'package:attendance_system/services/time_request/time_request_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../services/time_request/time_request_model.dart';
import '../../../shared/widgets/utils/animation/animated_widget.dart';
import '../../../shared/widgets/utils/downloader.dart';
import '../../../shared/widgets/utils/icon_text_button.dart';
import '../../../shared/widgets/utils/popup/file_preview_popup.dart';
import '../../../shared/widgets/utils/popup/floating_popup.dart';
import '../../../shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import '../../../shared/widgets/utils/utils.dart';

Future<Response> mockData() async {

  await Future.delayed(
    const Duration(milliseconds: 200),
  );

  return Response(

    requestOptions: RequestOptions(path: '/api/attendance_request/detail'),
    statusCode: 200,
    data: {

      'request-detail': {
        'date-from': '2026-02-18T18:00:45.621Z',
        'date-to': '2026-02-18T18:00:45.621Z',
        'time-start': '08:00',
        'time-end': '9:00',
        'remark': 'ปวดหัว อาเจียน เป็นไข้ ทิฟฟี่แผงสีเขียว',
        'evidence-files': [
          {
            'file-name': 'final algorithm.pdf',
            'file-url': 'https://drive.google.com/uc?export=download&id=1vlrDqDVuYZhqy8E3HQXf8DsxctgnYUCN',
            'file-type': 'pdf',
            'file-size': 3079943
          },
          {
            'file-name': 'IMG_3535.jpg',
            'file-url': 'https://media.discordapp.net/attachments/1339973422494515212/1466642651330777222/61346471-07C0-4AED-AF16-B46C7876F3D4.jpg?ex=69a11568&is=699fc3e8&hm=156a11fcf6d2687752a07202dac4988fd913061d0fe04c11b82df47b62994eab&=&format=webp&width=669&height=1189',
            'file-type': 'jpg',
            'file-size': 5434478723
          }
        ],
        'request-date': '2026-02-18T18:00:45.621Z',
      },
      'approve-detail': {
        'status': 'rejected', // pending, approved, rejected
        'approve-role': 'คณบดี',
        'approver': 'ด้วยดี ตามไท',
        'reason': 'ดีมาก',
        'approve-date': '2026-02-01T08:00:00.000Z',
      }
    },
  );
}

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

class TimeRequestPopupDetail extends StatefulWidget {
  final String id;
  final void Function() onCancel;
  final void Function() onResend;

  const TimeRequestPopupDetail({
    super.key,
    required this.id,
    required this.onCancel,
    required this.onResend,
  });

  @override
  State<TimeRequestPopupDetail> createState() {
    return _TimeRequestPopupDetailState();
  }
}

class _TimeRequestPopupDetailState extends State<TimeRequestPopupDetail> {

  AttendanceDetail? data;
  bool onSelect = false;
  
  @override
  Widget build(BuildContext context) {
    return ServiceLoader(
        request: () {
          // return mockData();
          return TimeRequestService().getDetail(widget.id);
        },
        onSuccess: (val) {
          setState(() {
            data = AttendanceDetail.fromJson(val);
          });
        },
        builder: () {

          return Padding(
            padding: EdgeInsetsGeometry.only(left: 15, right: 15),
            child: Column(
              spacing: 13,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Row(
                //   spacing: 6,
                //   children: [
                //     SvgPicture.asset(
                //       'assets/images/icon_status_list.svg',
                //       width: 15,
                //       height: 15,
                //     ),
                //     Text('สถานะปัจจุบัน')
                //   ],
                // ),

                SeparatorCard(
                  borderRadius: BorderRadius.circular(22),
                  children: [
                    Column(
                      children: [
                        AppButton(
                          icon: switch(data?.approveDetail.status) {
                            'approved' => 'icon_success.svg',
                            'rejected' => 'icon_cancel.svg',
                            _ => 'icon_pending.svg'
                          },
                          iconColor: switch(data?.approveDetail.status) {
                            'approved' => Color(0xFF30D143),
                            'rejected' => Color(0xFFE7000B),
                            _ => Color(0xFFE79E00)
                          },
                          title: switch(data?.approveDetail.status) {
                            'approved' => 'อนุมัติแล้ว',
                            'rejected' => 'ไม่อนุมัติ',
                            _ => 'รอดำเนินการ'
                          },
                          weightTitle: FontWeight.w500,
                          subTitle: data?.approveDetail.status == 'pending'
                              ? 'ตำแหน่งที่รับผิดชอบการอนุมัติ: ${data?.approveDetail.approveRole ?? '-'}'
                              : 'อนุมัติโดย ${data?.approveDetail.approver}' ?? '-',
                          arrow: false,
                          onPressed: data?.approveDetail.status != 'pending' ? () {
                            setState(() {
                              onSelect = !onSelect;
                            });
                          } : null,
                        ),
                        AnimatedSizeWidget(
                          enable: onSelect,
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
                                        'เนื่องจาก:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.lightTextColor,
                                        ),
                                      ),
                                      Text(
                                        data?.approveDetail.reason ?? '-',
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
                        icon: 'icon_time_request.svg',
                        title: 'การเข้างาน - ออกงาน',
                        bg: Colors.white,
                        weightTitle: FontWeight.w500,
                        subTitle: 'หมายเลขตำขอ ${widget.id}',
                        arrow: false,
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
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
                                                          _formatDate(data?.requestDetail.dateFrom),
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
                                                          _formatDate(data?.requestDetail.dateTo),
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
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
                                                            _formatTime(data?.requestDetail.timeStart),
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
                                                            _formatTime(data?.requestDetail.timeEnd),
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
                                  )
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
                              data?.requestDetail.remark ?? '-',
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
                    ...data!.requestDetail.evidenceFiles.map((file) {

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
                                                  IconTextButton(
                                                    icon: 'download.svg',
                                                    arrow: false,
                                                    label: 'ส่งออกไฟล์',
                                                    onPressed: () async {
                                                      menuController.close();
                                                      Downloader(
                                                          onDownloadStart: () => setState(() {
                                                            downloading = true;
                                                          }),
                                                          onDownloadSuccess: () => setState(() {
                                                            downloading = false;
                                                          })
                                                      ).downloadFile(file);
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
                    }),
                  ],
                ),
                if (data?.approveDetail.status == 'pending') ...[
                  SeparatorCard(
                    children: [
                      IconTextButton(
                        icon: 'cancel.svg',
                        label: 'ยกเลิกคำขอเวลาเข้าออกงาน',
                        color: Colors.red, // ลบ const ข้างหน้าออก
                        arrow: false,
                        onPressed: () async {
                          FloatingPopup(
                              title: 'ยกเลิกคำขอ',
                              description: 'คุณยืนยันที่จะลบคำขอหมายเลข: ${widget.id} หรือไม่? \n\nการดำเนินการนี้จะไม่สามารถย้อนกลับมาได้อีก',
                              buttons: (setError, context1) {
                                return [
                                  FloatingPopupButton(
                                    onPressed: () {
                                      Navigator.of(context1).pop();
                                    },
                                    text: 'ยกเลิก',
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.primaryColor,
                                  ),
                                  FloatingServicePopupButton(
                                    text: 'ยันยัน',
                                    foregroundColor: Colors.red,
                                    request: () => TimeRequestService().delete(widget.id),
                                    setError: setError,
                                    onSuccess: () async {
                                      Navigator.of(context1).pop();
                                      await Future.delayed(const Duration(milliseconds: 200));
                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                      widget.onCancel();
                                    },
                                  )
                                ];
                              }
                          ).showPopup(context);
                        },
                      )
                    ],
                  )
                ] else if (data?.approveDetail.status == 'rejected')...[
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

                          await provider.push(context,
                              TimeRequestResend(
                                id: widget.id,
                                allFiles: data!.requestDetail.evidenceFiles,
                                onResend: widget.onResend,
                                files: data!.requestDetail.evidenceFiles,
                                data: TimeRequestModel(
                                  fromDate: data!.requestDetail.dateFrom,
                                  toDate: data!.requestDetail.dateTo,
                                  startTime: data!.requestDetail.timeStart,
                                  endTime: data!.requestDetail.timeEnd,
                                  remark: data!.requestDetail.remark,
                                ),
                              )
                          );

                          provider.setConfig(oldConfig);
                        },
                      )
                    ],
                  )
                ]
              ],
            ),
          );
        }
    );
  }
}