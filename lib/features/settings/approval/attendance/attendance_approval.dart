import 'package:attendance_system/features/settings/approval/attendance/attendance_detail_popup.dart';
import 'package:attendance_system/services/approval/attendance/attendance_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../services/approval/attendance/attendance_model.dart';
import '../../../../shared/widgets/utils/app_button.dart';
import '../../../../shared/widgets/utils/popup/date_filter_popup.dart';
import '../../../../shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import '../../../../shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import '../../../../shared/widgets/utils/separator_card.dart';
import '../../../../shared/widgets/utils/services/service_updater_promax.dart';
import '../../../../shared/widgets/utils/sliver_separator_list.dart';

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

  /// ⚠️ build ตัวนี้คืน **sliver** ไม่ใช่ widget ปกติ — ต้องถูกวางใน CustomScrollView
  /// ของ approval.dart เท่านั้น (ดูคอมเมนต์ในไฟล์นั้น)
  @override
  Widget build(BuildContext context) {
    return ServiceUpdaterProMax(
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
              if (getState(0) == ServiceUpdaterProMaxState.loading &&
                  getState(1) == ServiceUpdaterProMaxState.loading) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CupertinoActivityIndicator()),
                );
              }

              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Row(
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
                    ),
                  ),

                  if (pendingList.isEmpty && getState(0) != ServiceUpdaterProMaxState.loading)
                    SliverToBoxAdapter(
                      child: SeparatorCard(
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
                      ),
                    )
                  else
                    SliverSeparatorList(
                      separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 10),
                      itemCount: pendingList.length,
                      itemBuilder: (context, index) {
                          final m = pendingList[index];
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
                                          recentList.insert(0, RecentAttendanceApprovalModel(status: 'approved', name: m.name, attendanceId: m.attendanceId));
                                        });
                                      },
                                      onRejected: () {
                                        setState(() {
                                          pendingList.remove(m);
                                          recentList.insert(0, RecentAttendanceApprovalModel(status: 'rejected', name: m.name, attendanceId: m.attendanceId));
                                        });
                                      },
                                    );
                                  }, // โยนหน้า 1 เข้าไป
                                ).showPopup(context);
                              },
                            );
                      },
                    ),

                  SliverToBoxAdapter(child: SizedBox(height: 13)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Row(
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
                    ),
                  ),

                  if (recentList.isEmpty && getState(1) != ServiceUpdaterProMaxState.loading)
                    SliverToBoxAdapter(
                      child: SeparatorCard(
                        children: [
                          Container(
                            color: Colors.white,
                            width: double.infinity,
                            padding: EdgeInsetsGeometry.all(25),
                            child: Text(
                              'ไม่พบคำขอเวลาเข้า-ออกงาน',
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
                  else
                    SliverSeparatorList(
                      separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 10),
                      itemCount: recentList.length,
                      itemBuilder: (context, index) {
                          final m = recentList[index];
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
                      },
                    ),
                ],
              );
            }
        );
  }
}