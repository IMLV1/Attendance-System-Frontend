import 'package:attendance_system/services/time_request/time_request_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../services/time_request/time_request_model.dart';
import '../../../shared/widgets/utils/animation/animated_widget.dart';

Future<Response> mockAttendance() async {

  await Future.delayed(
    const Duration(milliseconds: 200),
  );

  return Response(

    requestOptions: RequestOptions(path: '/api/attendance_request/detail'),
    statusCode: 200,
    data: {
      'approver': 'ด้วยดี ตามไท',
      'status': 'approved', // rejected, pending
      'remark-approver': 'ดีมาก',
      'time-approver': '2026-02-01T08:00:00.000Z',
      'role-approver-name': 'คณบดี',
      'remark-requester': 'ปวดหัว อาเจียน เป็นไข้ ทิฟฟี่แผงสีเขียว'
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
  final AttendanceRequestModel model;

  const TimeRequestPopupDetail({
    super.key,
    required this.model,
  });

  @override
  State<TimeRequestPopupDetail> createState() {
    return _TimeRequestPopupDetailState();
  }
}

class _TimeRequestPopupDetailState extends State<TimeRequestPopupDetail> {

  ApproverDetailModel? data;
  bool onSelect = false;
  
  @override
  Widget build(BuildContext context) {
    return ServiceLoader(
        request: () {
          return mockAttendance();
        },
        onSuccess: (val) {
          setState(() {
            data = ApproverDetailModel.fromJson(val);
          });
        },
        builder: () {

          final status = data?.status ?? AttendanceRequestStatus.pending;

          return Column(
            spacing: 13,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                spacing: 6,
                children: [
                  SvgPicture.asset(
                    'assets/images/icon_status_list.svg',
                    width: 15,
                    height: 15,
                  ),
                  Text('สถานะปัจจุบัน')
                ],
              ),

              SeparatorCard(
                borderRadius: BorderRadius.circular(22),
                children: [
                  Column(
                    children: [
                      AppButton(
                        icon: status.icon,

                        title: switch (status) {
                          AttendanceRequestStatus.approved => 'อนุมัติแล้ว',
                          AttendanceRequestStatus.rejected => 'ไม่อนุมัติ',
                          AttendanceRequestStatus.pending => 'รออนุมัติ',
                        },
                        iconColor: status.color,
                        weightTitle: FontWeight.w500,
                        subTitle: status == AttendanceRequestStatus.pending
                            ? 'ตำแหน่งที่รับผิดชอบการอนุมัติ: ${data?.roleApproverName ?? '-'}'
                            : 'ผู้อนุมัติ: ${data?.approver ?? '-'}',
                        arrow: !(status == AttendanceRequestStatus.pending),
                        timeStamp: data?.timeApprover != null
                            ? formatDateTime(data!.timeApprover!)
                            : null,
                        onPressed: () {
                          setState(() {
                            onSelect = (!onSelect) ? true : false;
                          });
                        },
                      ),
                      AnimatedSizeWidget(
                        enable: onSelect && !(status == AttendanceRequestStatus.pending),
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
                                    data?.remarkApprover ?? '-',
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
                      subTitle: 'หมายเลขตำขอ ${widget.model.id}',
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
                                                        _formatDate(widget.model.fromDate),
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
                                                        _formatDate(widget.model.toDate),
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
                            data?.remarkRequester ?? '-',
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
              )
            ],
          );
        }
    );
  }
}