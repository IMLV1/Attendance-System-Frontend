import 'package:attendance_system/features/settings/approval/attendance/attendance_detail_popup.dart';
import 'package:attendance_system/services/approval/attendance/attendance_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../services/approval/attendance/attendance_model.dart';
import '../../../../services/time_request/time_request_model.dart';
import '../../../../shared/widgets/utils/app_button.dart';
import '../../../../shared/widgets/utils/popup/date_filter_popup.dart';
import '../../../../shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import '../../../../shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import '../../../../shared/widgets/utils/popup/push_popup.dart';
import '../../../../shared/widgets/utils/separator_card.dart';
import '../../../../shared/widgets/utils/services/service_updater_promax.dart';
import '../../../../shared/widgets/utils/utils.dart';

class AttendanceApproval extends StatefulWidget{
  const AttendanceApproval({super.key});

  @override
  State<AttendanceApproval> createState() {
    return _AttendanceApprovalState();
  }
}

class _AttendanceApprovalState extends State<AttendanceApproval> {
  List<PendingAttendanceApprovalModel> pendingList = [];
  List<RecentAttendanceApprovalModel> recentList = [];

  DateTime? filterStart;
  DateTime? filterEnd;

  DateTime? filterStartAllow;
  DateTime? filterEndAllow;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 13,
      children: [
        ServiceUpdaterProMax(
            requests: [
              // ()=> Utils.mockResponse(
              //   data: {
              //     'pending': [
              //       {
              //         'id': 'ATT',
              //         'name': 'กหฟ ฟหกกหฟ',
              //         'attendanceId': 'ATT213213'
              //       },
              //       {
              //       'id': 'ATT',
              //       'name': 'กหฟ ฟหกกหฟ',
              //       'attendanceId': 'ATT213213'
              //       },
              //       {
              //         'id': 'ATT',
              //         'name': 'กหฟ ฟหกกหฟ',
              //         'attendanceId': 'ATT213213'
              //       },
              //     ]
              //   }
              // ),
              // ()=> Utils.mockResponse(
              //     data: {
              //       'recent': [
              //         {
              //           'id': 'ATT',
              //           'name': 'กหฟ ฟหกกหฟ',
              //           'status': 'approved',
              //           'attendanceId': 'ATT213213'
              //         },
              //         {
              //           'id': 'ATT',
              //           'name': 'กหฟ ฟหกกหฟ',
              //           'status': 'rejected',
              //           'attendanceId': 'ATT213213'
              //         },
              //       ]
              //     }
              // ),
              // ()=> Utils.mockResponse(
              //   data: {
              //   'start': '2025-04-01T00:00:00.000Z',
              //   'end': '2027-06-30T00:00:00.000Z'
              //   }
              // )

              () => AttendanceApprovalService().getPending(),
              () => AttendanceApprovalService().getRecent(filterStart, filterEnd),
              () => AttendanceApprovalService().getFilterRange(),
            ],
            onSuccess: (idx, val) {
              setState(() {
                switch (idx) {
                  case 0: pendingList = PendingAttendanceApprovalModel.getList(val['pending']);
                  case 1: recentList = RecentAttendanceApprovalModel.getList(val['recent']);
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
                      (pendingList.isEmpty && getState(0) != ServiceUpdaterProMaxState.loading) ? SeparatorCard(
                        children: [
                          Container(
                            color: Colors.white,
                            width: double.infinity,
                            padding: EdgeInsetsGeometry.all(25),
                            child: Text(
                              'ไม่มีคำขอที่รอดำเนินการ',
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
                          ...pendingList!.map((m) {
                            return AppButton(
                              icon: 'icon_pending.svg',
                              iconColor: Color(0xFFE79E00),
                              title: m.name,
                              subTitle: 'หมายเลขคำขอ: ${m.attendanceId}',
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
                                      scroll: false,
                                      safeArea: false
                                  ),
                                  builder: (context) {
                                    return AttendanceDetailPopup(
                                      reqId: m.attendanceId,
                                      onSuccess: () {
                                        setState(() {
                                          pendingList.remove(m);
                                          recentList.insert(0, RecentAttendanceApprovalModel(id: m.id, status: 'approved', name: m.name, attendanceId: m.attendanceId));
                                        });
                                      },
                                      onRejected: () {
                                        setState(() {
                                          pendingList.remove(m);
                                          recentList.insert(0, RecentAttendanceApprovalModel(id: m.id, status: 'rejected', name: m.name, attendanceId: m.attendanceId));
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
                              title: m.name,
                              subTitle: 'หมายเลขคำขอ: ${m.attendanceId}',
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
                                      scroll: false,
                                      safeArea: false
                                  ),
                                  builder: (context) {
                                    return AttendanceDetailPopup(
                                      reqId: m.attendanceId,
                                      onSuccess: () {
                                        setState(() {

                                        });
                                      },
                                      onRejected: () {
                                        setState(() {

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
    );
  }
}