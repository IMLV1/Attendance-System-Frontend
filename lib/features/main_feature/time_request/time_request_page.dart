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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../services/time_request/time_request_model.dart';
import '../../../shared/widgets/utils/popup/date_filter_popup.dart';
import '../../../shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import '../../../shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import '../../../shared/widgets/utils/services/service_updater_promax.dart';

class TimeRequestPage extends StatefulWidget{
  const TimeRequestPage({super.key});

  @override
  State<TimeRequestPage> createState() {
    return _TimeRequestPageState();
  }
}

class _TimeRequestPageState extends State<TimeRequestPage> {
  List<AttendanceRequestModel> recentList = [];
  List<PendingAttendanceRequestModel> pendingList = [];

  DateTime? filterStart;
  DateTime? filterEnd;

  DateTime? filterStartAllow;
  DateTime? filterEndAllow;


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
                                if (res != null && res is PendingAttendanceRequestModel) {
                                  setState(() {
                                    pendingList.insert(0, res);
                                  });
                                }
                              },
                            )
                          ],
                        ),
                        ServiceUpdaterProMax(
                          requests: [
                            () =>TimeRequestService().getPending(),
                            () =>TimeRequestService().getRecent(filterStart, filterEnd),
                            () =>TimeRequestService().getFilterRange(),
                            // mockData1(),
                            // mockData2(),
                            // mockData3(),
                          ],
                          onSuccess: (idx, val) {
                            print(val['recent']);
                            setState(() {
                              switch (idx) {
                                case 0: pendingList = PendingAttendanceRequestModel.getList(val['pending']);
                                case 1: recentList = AttendanceRequestModel.getList(val['recent']);
                                case 2: {
                                  final start = DateTime.tryParse(val['start']);
                                  final end = DateTime.tryParse(val['end']);

                                  if (start != null) {
                                    filterStartAllow = DateTime(start.year, start.month, 1);
                                  }
                                  if (end != null) {
                                    filterEndAllow = DateTime(end.year, end.month + 1, 0);
                                  }
                                }
                              }
                            });
                          },
                            fetchOnInit: true,
                            builder: (trigger, getState) {
                              return (getState(0) == ServiceUpdaterProMaxState.loading && getState(1) == ServiceUpdaterProMaxState.loading) ? Center(child: CupertinoActivityIndicator()) :
                              Column(
                                spacing: 13,
                                children: [
                                  Container(
                                      padding: EdgeInsetsGeometry.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        color: Color(0xFFE9E9E9),
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
                                              Text('รอดำเนินการ'),
                                              if (getState(0) == ServiceUpdaterProMaxState.loading)
                                                CupertinoActivityIndicator(radius: 7)
                                            ],
                                          ),
                                          (pendingList.isEmpty && getState(0) != ServiceUpdaterProMaxState.loading) ? Padding(
                                            padding: EdgeInsetsGeometry.all(20),
                                            child: Text(
                                              'ไม่มีคำขอที่รอดำเนินการ',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF7D7D7D), // สีจาง
                                              ),
                                            ),
                                          ) :
                                          SeparatorCard(
                                            separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 10),
                                            children: [
                                              ...pendingList!.map((m) {
                                                return AppButton(
                                                  icon: 'icon_pending.svg',
                                                  iconColor: Color(0xFFE79E00),
                                                  title: formatRange(m.dateStart, m.dateEnd),
                                                  subTitle: 'หมายเลขคำขอ: ${m.id}',
                                                  weightTitle: FontWeight.w500,
                                                  onPressed: () async {
                                                    // PushPopup(
                                                    //   title: 'รายละเอียดคำขอ',
                                                    //   fit: FlexFit.tight,
                                                    //   maxHeight: 750,
                                                    //   builder: (context) {
                                                    //     return TimeRequestPopupDetail(
                                                    //       id: m.id,
                                                    //       onCancel: () {
                                                    //         setState(() {
                                                    //           pendingList.removeWhere((item) => item.id == m.id);
                                                    //         });
                                                    //       },
                                                    //       onResend: () { },
                                                    //     );
                                                    //   }
                                                    // ).showPopup(context);

                                                    DynamicPushPopup(
                                                      initialConfig: PopupConfig(
                                                        title: 'รายละเอียด',
                                                        fit: FlexFit.tight,
                                                        maxHeight: 750,
                                                      ),
                                                      builder: (context) {
                                                        return TimeRequestPopupDetail(
                                                            id: m.id,
                                                            onCancel: () {
                                                              setState(() {
                                                                pendingList.remove(m);
                                                                recentList.insert(0, AttendanceRequestModel(id: m.id, dateStart: m.dateStart, dateEnd: m.dateEnd, status: 'canceled'));
                                                              });
                                                            },
                                                            onResend: () {

                                                            },
                                                          );
                                                      }, // โยนหน้า 1 เข้าไป
                                                    ).showPopup(context);
                                                  },
                                                );
                                              })
                                            ],
                                          )
                                        ],
                                      )
                                  ),
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
                                          if (getState(1) == ServiceUpdaterProMaxState.loading)
                                            CupertinoActivityIndicator(radius: 7),
                                          Spacer(),
                                          InkWell(
                                            onTap: () {
                                              DateFilterPopup(
                                                  maxHeight: 750,
                                                  allowDateFrom: filterStartAllow,
                                                  allowDateTo: filterEndAllow,
                                                  currentDateFrom: filterStart,
                                                  currentDateTo: filterEnd,
                                                  onSubmit: (start, end) {
                                                    setState(() {
                                                      filterStart = start;
                                                      filterEnd = end;
                                                      trigger(1);
                                                    });
                                                  }
                                              ).showPopup(context);
                                            },
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
                                      (recentList.isEmpty && getState(1) != ServiceUpdaterProMaxState.loading) ?
                                      SeparatorCard(
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: double.infinity,
                                            padding: EdgeInsetsGeometry.all(25),
                                            child: Text(
                                              'ไม่มีพบคำขอเวลาเข้า-ออกงาน',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF7D7D7D), // สีจาง
                                              ),
                                            ),
                                          )
                                        ],
                                      ) :
                                      SeparatorCard(
                                        separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 10),
                                        children: [
                                          ...recentList!.map((m) {
                                            return AppButton(
                                              icon: switch(m?.status) {
                                                'approved' => 'icon_success.svg',
                                                'rejected' => 'icon_cancel.svg',
                                                'overdue'  => 'icon_overdue.svg',
                                                'canceled' => 'icon_request_cancel.svg',
                                                _ => 'icon_pending.svg'
                                              },
                                              iconColor: switch(m?.status) {
                                                'approved' => Color(0xFF30D143),
                                                'rejected' => Color(0xFFE7000B),
                                                'overdue'  => Color(0xFF000000),
                                                'canceled' => Color(0xFFFFA652),
                                                _ => Color(0xFFE79E00)
                                              },
                                              title: formatRange(m.dateStart, m.dateEnd),
                                              subTitle: 'หมายเลขคำขอ: ${m.id}',
                                              weightTitle: FontWeight.w500,
                                              onPressed: () async {
                                                // PushPopup(
                                                //     title: 'รายละเอียดคำขอ',
                                                //     fit: FlexFit.tight,
                                                //     maxHeight: 750,
                                                //     builder: (context) {
                                                //       return TimeRequestPopupDetail(
                                                //         id: m.id,
                                                //         onCancel: () {
                                                //
                                                //         },
                                                //         onResend: () {
                                                //           setState(() {
                                                //             recentList.removeWhere((item) => item.id == m.id);
                                                //             pendingList.insert(0,
                                                //               PendingAttendanceRequestModel(
                                                //                 id: m.id,
                                                //                 dateStart: m.dateStart,
                                                //                 dateEnd: m.dateEnd,
                                                //               )
                                                //             );
                                                //           });
                                                //         },
                                                //       );
                                                //     }
                                                // ).showPopup(context);

                                                DynamicPushPopup(
                                                  initialConfig: PopupConfig(
                                                    title: 'รายละเอียด',
                                                    fit: FlexFit.tight,
                                                    maxHeight: 750,
                                                  ),
                                                  builder: (context) {
                                                    return TimeRequestPopupDetail(
                                                      id: m.id,
                                                      onCancel: () {

                                                      },
                                                      onResend: () {
                                                        setState(() {
                                                          recentList.remove(m);
                                                          pendingList.insert(0, PendingAttendanceRequestModel(id: m.id, dateStart: m.dateStart, dateEnd: m.dateEnd));
                                                        });
                                                      },
                                                    );
                                                  }, // โยนหน้า 1 เข้าไป
                                                ).showPopup(context);
                                              },
                                            );
                                          })
                                        ],
                                      )
                                    ],
                                  )
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

Future<Response> mockData3() async {
  await Future.delayed(const Duration(milliseconds: 200));

  return Response(
      requestOptions: RequestOptions(path: '/api/attendance_request/filter_range'),
      statusCode: 200,
      data: {
        'start': '2025-04-01T00:00:00.000Z',
        'end': '2027-06-30T00:00:00.000Z'
      }
  );
}

Future<Response> mockData2() async {
  await Future.delayed(const Duration(milliseconds: 10000));

  return Response(
      requestOptions: RequestOptions(path: '/api/attendance_request/recent'),
      statusCode: 200,
      data: {
        'recent': [
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'approved' // approved, rejected,
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'approved'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'approved'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'approved'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'approved'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'approved'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'rejected'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'approved'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'approved'
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
            'status': 'approved'
          },
        ]
      }
  );
}

Future<Response> mockData1() async {
  await Future.delayed(const Duration(milliseconds: 1000));

  return Response(
      requestOptions: RequestOptions(path: '/api/attendance_request/pending'),
      statusCode: 200,
      data: {
        'pending': [
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
          {
            'id': 'REQ000000065013',
            'date-start': '2026-02-18T18:00:45.621Z',
            'date-end': '2026-02-18T18:00:45.621Z',
          },
        ]
      }
  );
}