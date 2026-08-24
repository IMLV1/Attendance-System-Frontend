import 'package:attendance_system/services/approval/leave/leave_service.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../services/approval/leave/leave_model.dart';
import '../../../../services/leave/leave_model.dart';
import '../../../../shared/widgets/utils/app_button.dart';
import '../../../../shared/widgets/utils/popup/date_filter_popup.dart';
import '../../../../shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import '../../../../shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import '../../../../shared/widgets/utils/separator_card.dart';
import '../../../../shared/widgets/utils/services/service_updater_promax.dart';
import '../../../../shared/widgets/utils/sliver_separator_list.dart';
import '../../../main_feature/leave_request/leave_type.dart';
import 'leave_approval_detail.dart';
import 'leave_approval_detail_popup.dart';

class LeaveApproval extends StatefulWidget {
  const LeaveApproval({super.key});

  @override
  State<LeaveApproval> createState() {
    return _LeaveApprovalState();
  }
}

class _LeaveApprovalState extends State<LeaveApproval> {

  List<PendingLeaveApproval> pendingList = [];
  List<RecentLeaveApproval> recentList = [];

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
              () => LeaveApprovalService().pending(),
              () => LeaveApprovalService().recent(filterStart, filterEnd),
              () => LeaveApprovalService().getFilterRange()
            ],
            onSuccess: (idx, val) {
              setState(() {
                switch (idx) {
                  case 0: pendingList = PendingLeaveApproval.getList(val['data']['pending']);
                  case 1: {
                    print(val);
                    recentList = RecentLeaveApproval.getList(val['data']['recent']);
                  }
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
                          return UserInfoButton(
                              icon: Image.network(
                                m.avatarUrl,
                                errorBuilder: (_, _, _) {
                                  return Image.asset('assets/images/profile.png');
                                },
                              ),
                              title: m.name,
                              subTitle: 'รอการอนุมัติ ${m.count} คำขอ',
                              fontTitle: 15,
                              fontSub: 13,
                              fontWeightTitle: FontWeight.w500,
                              roles: [],
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

                                // DynamicPushPopup(
                                //   initialConfig: PopupConfig(
                                //       title: 'รายละเอียด',
                                //       fit: FlexFit.tight,
                                //       maxHeight: 750,
                                //       scroll: false,
                                //       safeArea: false
                                //   ),
                                //   builder: (context) {
                                //     return AttendanceDetailPopup(
                                //       reqId: m.attendanceId,
                                //       onSuccess: () {
                                //         setState(() {
                                //           pendingList.remove(m);
                                //           recentList.insert(0, RecentAttendanceApprovalModel(id: m.id, status: 'approved', name: m.name, attendanceId: m.attendanceId));
                                //         });
                                //       },
                                //       onRejected: () {
                                //         setState(() {
                                //           pendingList.remove(m);
                                //           recentList.insert(0, RecentAttendanceApprovalModel(id: m.id, status: 'rejected', name: m.name, attendanceId: m.attendanceId));
                                //         });
                                //       },
                                //     );
                                //   }, // โยนหน้า 1 เข้าไป
                                // ).showPopup(context);

                                final List<RecentLeaveApproval>? res = await Navigator.push<List<RecentLeaveApproval>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeaveApprovalDetail(userId: m.userId),
                                  ),
                                );

                                setState(() {
                                  if (res != null) {
                                    for (int i = 0; i < res.length; i++) {
                                      if (res[i].status == .approved) {
                                        recentList.insert(0, RecentLeaveApproval(userId: res[i].userId, name: res[i].name, requestId: res[i].requestId, status: .approved, type: res[i].type, dateStart: res[i].dateStart));
                                      } else {
                                        recentList.insert(0, RecentLeaveApproval(userId: res[i].userId, name: res[i].name, requestId: res[i].requestId, status: .rejected, type: res[i].type, dateStart: res[i].dateStart));
                                      }
                                    }

                                    int idx = pendingList.indexOf(m);
                                    if (idx != -1) {
                                      final temp = m.count - res.length;
                                      if (temp <= 0) {
                                        pendingList.remove(m);
                                      } else {
                                        pendingList[idx].count = temp;
                                      }
                                    }
                                  }
                                });
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
                              'ไม่พบคำขอลางาน',
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
                              icon: m.status.icon,
                              iconColor: m.status.color,
                              title: '${m.type.display} | ${m.name}',
                              subTitle: 'หมายเลขคำขอ: ${m.requestId}',
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
                                    return LeaveApprovalDetailPopup(
                                      requestID: m.requestId,
                                      onApproved: () {
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
