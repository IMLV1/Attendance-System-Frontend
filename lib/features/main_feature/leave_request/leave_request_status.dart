import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_request_detail.dart';
import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/services/leave/leave_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/date_filter_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/example_usage.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

Future<Response> mockData() async {
  await Future.delayed(const Duration(milliseconds: 1000));

  return Response(
    requestOptions: RequestOptions(path: '/mock/data'),
    statusCode: 200,
    data: {
      'pending': [
        {
          'id': 'LEV000000065013',
          'leave-type': 'sick',
          'date-start': '2026-02-18T18:00:45.621Z'
        },
        {
          'id': 'LEV000000065013',
          'leave-type': 'sick',
          'date-start': '2026-02-18T18:00:45.621Z'
        },
        {
          'id': 'LEV000000065013',
          'leave-type': 'sick',
          'date-start': '2026-02-18T18:00:45.621Z'
        },
      ]
    }
  );
}

Future<Response> mockData2() async {
  await Future.delayed(const Duration(milliseconds: 2000));

  return Response(
    requestOptions: RequestOptions(path: '/mock/data'),
    statusCode: 200,
    data: {
      'recent': [
        {
          'id': 'LEV000000065013',
          'leave-type': 'sick',
          'date-start': '2026-02-18T18:00:45.621Z',
          'approved': true
        },
        {
          'id': 'LEV000000065013',
          'leave-type': 'sick',
          'date-start': '2026-02-18T18:00:45.621Z',
          'approved': false
        },
        {
          'id': 'LEV000000065013',
          'leave-type': 'sick',
          'date-start': '2026-02-18T18:00:45.621Z',
          'approved': true
        },
        {
          'id': 'LEV000000065013',
          'leave-type': 'sick',
          'date-start': '2026-02-18T18:00:45.621Z',
          'approved': true
        },
      ]
    }
  );
}

Future<Response> mockData3() async {
  await Future.delayed(const Duration(milliseconds: 200));

  return Response(
      requestOptions: RequestOptions(path: '/mock/data'),
      statusCode: 200,
      data: {
        'start': '2025-04-01T00:00:00.000Z',
        'end': '2027-06-30T00:00:00.000Z'
      }
  );
}

class LeaveRequestStatus extends StatefulWidget {
  const LeaveRequestStatus({super.key});
  @override
  State<LeaveRequestStatus> createState() => _LeaveRequestPage();
}

class _LeaveRequestPage extends State<LeaveRequestStatus> {

  final Map<String, String> leaveNames = {
    'sick': 'ลาป่วย',
    'personal': 'ลากิจส่วนตัว',
    'vacation': 'ลาพักผ่อน',
    'maternity': 'ลาคลอดบุตร',
    'paternity': 'ลาช่วยเหลือภริยาคลอดบุตร',
    'parental': 'ลากิจเพื่อเลี้ยงดูบุตร'
  };

  List<PendingLeaveRequestModel> pendingLeaves = [];
  List<LeaveRequestModel> recentLeaves = [];

  DateTime? filterStartAllow;
  DateTime? filterEndAllow;

  DateTime? filterStart;
  DateTime? filterEnd;

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
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
                                final result = await context.pushNamed<(String?, String?, DateTime?)>(RouteNames.attendanceRequestCreate);
                                if (result != null) {
                                  final (id, leaveType, dateStart) = result;

                                  print('$id, $leaveType, ${dateStart?.toIso8601String()}');

                                  pendingLeaves.add(PendingLeaveRequestModel(id: id ?? '', leaveType: leaveType!, dateStart: dateStart!));
                                }
                              },
                            )
                          ],
                        ),

                        ServiceUpdaterProMax(
                            requests: () => [
                              LeaveRequestService().getPending(),
                              LeaveRequestService().getRecent(filterStart, filterEnd),
                              LeaveRequestService().getFilterRange(),
                            ],
                            onSuccess: (index, data) => {
                              setState(() {
                                switch (index) {
                                  case 0: pendingLeaves = PendingLeaveRequestModel.getList(data['pending']);
                                  case 1: {
                                    recentLeaves = LeaveRequestModel.getList(data['recent']);
                                  }
                                  case 2: {

                                    final start =  DateTime.tryParse(data['start']);
                                    final end =  DateTime.tryParse(data['end']);

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
                                              ...pendingLeaves!.map((m) {
                                                return AppButton(
                                                  icon: 'icon_pending.svg',
                                                  iconColor: Color(0xFFE79E00),
                                                  title: '${leaveNames[m.leaveType] ?? ''} | ${DateFormat.MMMd('th_TH').format(m.dateStart)} ${DateFormat.y('th_TH').format(m.dateStart)}',
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
                                      (recentLeaves.isEmpty && getState(1) != ServiceUpdaterProMaxState.loading) ?
                                      SeparatorCard(
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
                                      ) :
                                      SeparatorCard(
                                        separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 10),
                                        children: [
                                          ...recentLeaves!.map((m) {
                                            return AppButton(
                                              icon: m.approve ? 'icon_success.svg' : 'icon_cancel.svg',
                                              iconColor: m.approve ? Color(0xFF30D143) : Color(0xFFE7000B),
                                              title: '${leaveNames[m.leaveType] ?? ''} | ${DateFormat.MMMd('th_TH').format(m.dateStart)} ${DateFormat.y('th_TH').format(m.dateStart)}',
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

