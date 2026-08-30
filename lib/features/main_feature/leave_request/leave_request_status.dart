import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_request_detail.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_type.dart';
import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/services/leave/leave_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/core/utils/responsive.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/date_filter_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:attendance_system/shared/widgets/utils/sliver_separator_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LeaveRequestStatus extends StatefulWidget {
  const LeaveRequestStatus({super.key});
  @override
  State<LeaveRequestStatus> createState() => _LeaveRequestPage();
}

class _LeaveRequestPage extends State<LeaveRequestStatus> {

  List<PendingLeaveRequestModel> pendingLeaves = [];
  List<LeaveRequestModel> recentLeaves = [];

  DateTime? filterStartAllow;
  DateTime? filterEndAllow;

  DateTime? filterStart;
  DateTime? filterEnd;

  @override
  Widget build(BuildContext context) {

    pendingLeaves.sort((a, b) => a.dateStart.toLocal().millisecondsSinceEpoch.compareTo(b.dateStart.toLocal().millisecondsSinceEpoch));
    recentLeaves.sort((a, b) => b.dateStart.toLocal().millisecondsSinceEpoch.compareTo(a.dateStart.toLocal().millisecondsSinceEpoch));

    return AppScaffold(
      maxWidth: Responsive.widthFor(ContentShape.list),
      header: Header.mainHeader(
        context,
        title: 'ส่งคำขอลางาน',
        subTitle: 'Leave Request',
        iconPath: 'icon_leave.svg',
        iconColor: Colors.white
      ),
      content: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: 10, right: 10, top: 20),
            child: Column(
              children: [
                Expanded(
                  // 🚩 (2026-08-22) เดิม SingleChildScrollView + Column -> ทุกแถวของ
                  // "รายการล่าสุด" ถูก build พร้อมกันตอนเปิดหน้า (คำขอสะสมไปเรื่อยๆ)
                  // ⚠️ ห้ามเอา SingleChildScrollView กลับมาครอบ ไม่งั้น sliver ข้างในจะ
                  // ถูก shrink-wrap แล้ว build ครบทุกแถวเหมือนเดิม
                  child: CustomScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                        SliverToBoxAdapter(
                          child: SeparatorCard(
                          children: [
                            IconTextButton(
                              icon: 'icon_create_role.svg',
                              label: 'สร้างคำขอใหม่',
                              color: Color(0xFF4986FF),
                              arrow: false,
                              onPressed: () async {
                                final result = await context.pushNamed<(String?, String?, DateTime?)>(RouteNames.attendanceRequestCreate);
                                if (result != null) {
                                  final (id, leaveType, dateStart) = result;

                                  pendingLeaves.add(PendingLeaveRequestModel(id: id ?? '', leaveType: LeaveTypeX.fromString(leaveType!), dateStart: dateStart!));
                                }
                              },
                            )
                          ],
                        ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 13)),

                        ServiceUpdaterProMax(
                            requests: [
                              () => LeaveRequestService().getPending(),
                              () => LeaveRequestService().getRecent(filterStart, filterEnd),
                              () => LeaveRequestService().getFilterRange(),
                            ],
                            onSuccess: (index, data) => {
                              setState(() {
                                switch (index) {
                                  case 0: {
                                    pendingLeaves = PendingLeaveRequestModel.getList(data['pending']);
                                  }
                                  case 1: {
                                    recentLeaves = LeaveRequestModel.getList(data['recent']);
                                  }
                                  case 2: {

                                    final start = DateTime.tryParse(data['start']);
                                    final end = DateTime.tryParse(data['end']);

                                    if (start != null) {
                                      filterStartAllow = DateTime(start.year, start.month, 1);
                                    }
                                    if (end != null) {
                                      filterEndAllow = DateTime(end.year, end.month + 1, 0);
                                    }
                                  }
                                }
                              })
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
                                  // "รอดำเนินการ" ของตัวเองมีไม่กี่รายการ (คำขอที่ยังไม่ถูก
                                  // ตัดสิน) -> ปล่อยเป็นก้อนเดียวไว้ ตัวที่โตไม่จำกัดคือ
                                  // "รายการล่าสุด" ข้างล่าง
                                  SliverToBoxAdapter(
                                    child: Container(
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
                                          (pendingLeaves.isEmpty && getState(0) != ServiceUpdaterProMaxState.loading) ?
                                          Padding(
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
                                              ...pendingLeaves.map((m) {
                                                return AppButton(
                                                  icon: 'icon_pending.svg',
                                                  iconColor: Color(0xFFE79E00),
                                                  title: '${m.leaveType.display} | ${DateFormat.MMMd('th_TH').format(m.dateStart)} ${DateFormat.y('th_TH').format(m.dateStart)}',
                                                  subTitle: 'หมายเลขคำขอ: ${m.id}',
                                                  weightTitle: FontWeight.w500,
                                                  onPressed: () {

                                                    DynamicPushPopup(
                                                      initialConfig: PopupConfig(
                                                        title: 'รายละเอียด',
                                                        fit: FlexFit.tight,
                                                        maxHeight: 750,
                                                      ),
                                                      builder: (context) {
                                                        return LeaveRequestDetail(
                                                          requestID: m.id,
                                                          onCancel: () {
                                                            setState(() {
                                                              recentLeaves.add(LeaveRequestModel(id: m.id, leaveType: m.leaveType, dateStart: m.dateStart, status: .canceled));
                                                              pendingLeaves.remove(m);
                                                            });
                                                          },
                                                          onResend: () {},
                                                        );
                                                      }, // โยนหน้า 1 เข้าไป
                                                    ).showPopup(context);

                                                    // MultiPagePopup(
                                                    //   title: 'รายละเอียดคำขอ',
                                                    //   fit: FlexFit.tight,
                                                    //   maxHeight: 750,
                                                    //   builder: (BuildContext context) {
                                                    //     return LeaveRequestDetail(
                                                    //       requestID: m.id,
                                                    //       onCancel: () {
                                                    //         setState(() {
                                                    //           pendingLeaves.remove(m);
                                                    //         });
                                                    //       },
                                                    //     );
                                                    //   }
                                                    // ).showPopup(context);
                                                  },
                                                );
                                              })
                                            ],
                                          )
                                        ],
                                      )
                                  ),
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

                                  if (recentLeaves.isEmpty && getState(1) != ServiceUpdaterProMaxState.loading)
                                    SliverToBoxAdapter(
                                      child: SeparatorCard(
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: double.infinity,
                                            padding: EdgeInsetsGeometry.all(25),
                                            child: Text(
                                              'ไม่มีพบคำขอลางาน',
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
                                        itemCount: recentLeaves.length,
                                        itemBuilder: (context, index) {
                                            final m = recentLeaves[index];
                                            return AppButton(
                                              icon: m.status.icon,
                                              iconColor: m.status.color,
                                              title: '${m.leaveType.display} | ${DateFormat.MMMd('th_TH').format(m.dateStart)} ${DateFormat.y('th_TH').format(m.dateStart)}',
                                              subTitle: 'หมายเลขคำขอ: ${m.id}',
                                              weightTitle: FontWeight.w500,
                                              onPressed: () {
                                                DynamicPushPopup(
                                                  initialConfig: PopupConfig(
                                                    title: 'รายละเอียด',
                                                    fit: FlexFit.tight,
                                                    maxHeight: 750,
                                                  ),
                                                  builder: (context) {
                                                    return LeaveRequestDetail(
                                                      requestID: m.id,
                                                      onCancel: () {},
                                                      onResend: () {
                                                        setState(() {
                                                          recentLeaves.remove(m);
                                                          pendingLeaves.add(PendingLeaveRequestModel(id: m.id, leaveType: m.leaveType, dateStart: m.dateStart));
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
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
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

