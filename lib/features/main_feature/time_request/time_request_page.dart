import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/features/main_feature/time_request/time_request_create.dart';
import 'package:attendance_system/features/main_feature/time_request/time_request_popup_detail.dart';
import 'package:attendance_system/services/time_request/time_request_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../services/time_request/time_request_model.dart';

class TimeRequestPage extends StatefulWidget{
  const TimeRequestPage({super.key});

  @override
  State<TimeRequestPage> createState() {
    return _TimeRequestPageState();
  }
}

class _TimeRequestPageState extends State<TimeRequestPage> {
  List<AttendanceRequestModel> pendingList = [];
  List<AttendanceRequestModel> completedList = [];


  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      header: Header.mainHeader(
        context,
        title: 'ขออนุมัติเวลาเข้า-ออกงาน',
        subTitle: 'Attendance Request',
        iconPath: 'icon_time_request.svg',
        iconColor: Colors.white
      ),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 20
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      spacing: 13,
                      children: [
                        SeparatorCard(
                          children: [
                            IconTextButton(
                              icon: 'icon_create_role.svg',
                              label: 'สร้างคำขอใหม่',
                              color: Color(0xFF4986FF),
                              arrow: false,
                              onPressed: () async {
                                final res = await context.pushNamed(RouteNames.timeRequestCreate);
                                if (res != null && res is AttendanceRequestModel) {
                                  setState(() {
                                    pendingList.insert(0, res);
                                  });
                                }
                              },
                            )
                          ],
                        ),
                        ServiceLoader(
                          request: () {
                            // return TimeRequestService().getAttendanceRequest();
                            return mockAttendanceRequest();
                          },
                          onSuccess: (val) {
                            final all = (val["requests"] as List).map((e) => AttendanceRequestModel.fromJson(e)).toList();
                            setState(() {
                              completedList = all.where((e) => e.status.isCompleted).toList()..sort((a, b) => b.fromDate.compareTo(a.fromDate)); // ใหม่ก่อน
                              pendingList = all.where((e) => e.status.isPending).toList()..sort((a, b) => a.fromDate.compareTo(b.fromDate)); // เก่าก่อน
                            });
                          },
                          builder: () {
                            return Column(
                              spacing: 13,
                              children: [
                                if (pendingList.isNotEmpty) ...[
                                  Column(
                                    spacing: 6,
                                    children: [
                                      Container(
                                          padding: EdgeInsetsGeometry.only(
                                              left: 10,
                                              right: 10,
                                              top: 10,
                                              bottom: 10
                                          ),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFEAEAEA),
                                              borderRadius: BorderRadius.circular(22)
                                          ),
                                          child: Column(
                                            spacing: 6,
                                            children: [
                                              Row(
                                                spacing: 6,
                                                children: [
                                                  SizedBox(
                                                    width: 15,
                                                    height: 15,
                                                    child: SvgPicture.asset(
                                                      'assets/images/icon_pending.svg',
                                                      colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                      width: 10,
                                                    ),
                                                  ),
                                                  Text('รอการอนุมัติ')
                                                ],
                                              ),
                                              SeparatorCard(
                                                borderRadius: BorderRadius.circular(22),
                                                separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 10),
                                                children: [
                                                  ...pendingList.map((e) {
                                                    return AppButton(
                                                      icon: e.status.icon,
                                                      title: formatRange(e.fromDate.toLocal(), e.toDate.toLocal()),
                                                      weightTitle: FontWeight.w500,
                                                      iconColor: e.status.color,
                                                      subTitle: 'หมายเลขคำขอ: ${e.id}',
                                                    );
                                                  })
                                                ],
                                              )
                                            ],
                                          )
                                      ),
                                    ],
                                  ),
                                ],

                                if (completedList.isNotEmpty) ...[
                                  Column(
                                    spacing: 6,
                                    children: [
                                      Row(
                                        spacing: 6,
                                        children: [
                                          SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: SvgPicture.asset(
                                                'assets/images/icon_recent.svg'
                                            ),
                                          ),
                                          Text('รายการล่าสุด'),
                                          Spacer(),
                                          InkWell(
                                            child: Row(
                                              spacing: 6,
                                              children: [
                                                Text(
                                                    'ตัวกรอง',
                                                    style: TextStyle(
                                                        color: Color(0xFF2C2C2C)
                                                    )
                                                ),
                                                SvgPicture.asset(
                                                  'assets/images/filter.svg',
                                                  colorFilter: ColorFilter.mode(Color(0xFF2C2C2C), BlendMode.srcIn),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      SeparatorCard(
                                        borderRadius: BorderRadius.circular(22),
                                        separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 10),
                                        children: [
                                          ...completedList.map((e) {
                                            return AppButton(
                                              icon: e.status.icon,
                                              title: formatRange(e.fromDate.toLocal(), e.toDate.toLocal()),
                                              weightTitle: FontWeight.w500,
                                              iconColor: e.status.color,
                                              subTitle: 'หมายเลขคำขอ: ${e.id}',
                                              onPressed: () async {
                                                PushPopup(
                                                  title: 'เลือกวันที่',
                                                  fit: FlexFit.tight,
                                                  scroll: true,
                                                  builder: (context) {
                                                    return TimeRequestPopupDetail(model: e);
                                                  }
                                                ).showPopup(context);
                                              },
                                            );
                                          })
                                        ],
                                      )
                                    ],
                                  )
                                ]
                              ],
                            );
                          }
                        )
                      ],
                    )
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}

String formatRange(DateTime from, DateTime to) {
  final fromDay = from.day.toString().padLeft(2, '0');
  final fromMonth = from.month.toString().padLeft(2, '0');
  final fromYear = from.year;

  final toDay = to.day.toString().padLeft(2, '0');
  final toMonth = to.month.toString().padLeft(2, '0');
  final toYear = to.year;

  return "$fromDay/$fromMonth/$fromYear - ""$toDay/$toMonth/$toYear";
}

Future<Response> mockAttendanceRequest() async {

  await Future.delayed(
    const Duration(milliseconds: 200),
  );

  return Response(

    requestOptions: RequestOptions(
      path: '/api/attendance_request/get',
    ),

    statusCode: 200,

    data: {

        "requests": [

          {
            "id": "PEN0001",
            "status": "pending",
            "fromDate": "2026-02-01T08:00:00.000Z",
            "toDate": "2026-02-01T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },
          {
            "id": "PEN0002",
            "status": "pending",
            "fromDate": "2026-02-02T08:00:00.000Z",
            "toDate": "2026-02-02T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },
          {
            "id": "PEN0003",
            "status": "pending",
            "fromDate": "2026-02-03T08:00:00.000Z",
            "toDate": "2026-02-03T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },
          {
            "id": "PEN0004",
            "status": "pending",
            "fromDate": "2026-02-04T08:00:00.000Z",
            "toDate": "2026-02-04T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },
          {
            "id": "PEN0005",
            "status": "pending",
            "fromDate": "2026-02-05T08:00:00.000Z",
            "toDate": "2026-02-05T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },
          {
            "id": "PEN0006",
            "status": "pending",
            "fromDate": "2026-02-06T08:00:00.000Z",
            "toDate": "2026-02-06T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },
          {
            "id": "PEN0007",
            "status": "pending",
            "fromDate": "2026-02-07T08:00:00.000Z",
            "toDate": "2026-02-07T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },
          {
            "id": "PEN0008",
            "status": "pending",
            "fromDate": "2026-02-08T08:00:00.000Z",
            "toDate": "2026-02-08T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },
          {
            "id": "PEN0009",
            "status": "pending",
            "fromDate": "2026-02-09T08:00:00.000Z",
            "toDate": "2026-02-09T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },
          {
            "id": "PEN0010",
            "status": "pending",
            "fromDate": "2026-02-10T08:00:00.000Z",
            "toDate": "2026-02-10T17:00:00.000Z",
            "startTime": "08:00",
            "endTime": "17:00"
          },

          {
            "id": "APP0001",
            "status": "approved",
            "fromDate": "2026-01-01T09:00:00.000Z",
            "toDate": "2026-01-01T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },
          {
            "id": "APP0002",
            "status": "approved",
            "fromDate": "2026-01-02T09:00:00.000Z",
            "toDate": "2026-01-02T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },
          {
            "id": "APP0003",
            "status": "approved",
            "fromDate": "2026-01-03T09:00:00.000Z",
            "toDate": "2026-01-03T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },
          {
            "id": "APP0004",
            "status": "approved",
            "fromDate": "2026-01-04T09:00:00.000Z",
            "toDate": "2026-01-04T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },
          {
            "id": "APP0005",
            "status": "approved",
            "fromDate": "2026-01-05T09:00:00.000Z",
            "toDate": "2026-01-05T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },
          {
            "id": "APP0006",
            "status": "approved",
            "fromDate": "2026-01-06T09:00:00.000Z",
            "toDate": "2026-01-06T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },
          {
            "id": "APP0007",
            "status": "approved",
            "fromDate": "2026-01-07T09:00:00.000Z",
            "toDate": "2026-01-07T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },
          {
            "id": "APP0008",
            "status": "approved",
            "fromDate": "2026-01-08T09:00:00.000Z",
            "toDate": "2026-01-08T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },
          {
            "id": "APP0009",
            "status": "approved",
            "fromDate": "2026-01-09T09:00:00.000Z",
            "toDate": "2026-01-09T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },
          {
            "id": "APP0010",
            "status": "approved",
            "fromDate": "2026-01-10T09:00:00.000Z",
            "toDate": "2026-01-10T18:00:00.000Z",
            "startTime": "09:00",
            "endTime": "18:00"
          },

          {
            "id": "REJ0001",
            "status": "rejected",
            "fromDate": "2025-12-01T08:30:00.000Z",
            "toDate": "2025-12-01T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          },
          {
            "id": "REJ0002",
            "status": "rejected",
            "fromDate": "2025-12-02T08:30:00.000Z",
            "toDate": "2025-12-02T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          },
          {
            "id": "REJ0003",
            "status": "rejected",
            "fromDate": "2025-12-03T08:30:00.000Z",
            "toDate": "2025-12-03T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          },
          {
            "id": "REJ0004",
            "status": "rejected",
            "fromDate": "2025-12-04T08:30:00.000Z",
            "toDate": "2025-12-04T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          },
          {
            "id": "REJ0005",
            "status": "rejected",
            "fromDate": "2025-12-05T08:30:00.000Z",
            "toDate": "2025-12-05T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          },
          {
            "id": "REJ0006",
            "status": "rejected",
            "fromDate": "2025-12-06T08:30:00.000Z",
            "toDate": "2025-12-06T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          },
          {
            "id": "REJ0007",
            "status": "rejected",
            "fromDate": "2025-12-07T08:30:00.000Z",
            "toDate": "2025-12-07T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          },
          {
            "id": "REJ0008",
            "status": "rejected",
            "fromDate": "2025-12-08T08:30:00.000Z",
            "toDate": "2025-12-08T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          },
          {
            "id": "REJ0009",
            "status": "rejected",
            "fromDate": "2025-12-09T08:30:00.000Z",
            "toDate": "2025-12-09T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          },
          {
            "id": "REJ0010",
            "status": "rejected",
            "fromDate": "2025-12-10T08:30:00.000Z",
            "toDate": "2025-12-10T17:30:00.000Z",
            "startTime": "08:30",
            "endTime": "17:30"
          }

        ]
    },
  );
}