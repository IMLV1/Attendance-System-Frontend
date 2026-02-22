import 'package:attendance_system/app/route_names.dart';
import 'package:attendance_system/features/main_feature/leave_request/date_select.dart';
import 'package:attendance_system/features/main_feature/leave_request/leave_request_create.dart';
import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

Future<Response> mockData() async {
  await Future.delayed(const Duration(milliseconds: 200));

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
  await Future.delayed(const Duration(milliseconds: 200));

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
                              onPressed: () {
                                context.pushNamed(RouteNames.attendanceRequestCreate);
                              },
                            )
                          ],
                        ),
                        ServiceLoader(
                          request: () => mockData(),
                          onSuccess: (jsonData) {
                            setState(() {
                              pendingLeaves = PendingLeaveRequestModel.getList(jsonData['pending']);
                            });
                          },
                          builder: () => Container(
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
                                      Text('รอดำเนินการ')
                                    ],
                                  ),
                                  SeparatorCard(
                                    separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 10),
                                    children: [
                                      ...pendingLeaves!.map((m) {
                                        return AppButton(
                                          icon: 'icon_pending.svg',
                                          iconColor: Color(0xFFE79E00),
                                          title: '${leaveNames[m.leaveType]!} | ${DateFormat.MMMd('th_TH').format(m.dateStart)} ${DateFormat.y('th_TH').format(m.dateStart)}',
                                          subTitle: 'หมายเลขคำขอ ${m.id}',
                                          weightTitle: FontWeight.w500,
                                        );
                                      })
                                    ],
                                  )
                                ],
                              )
                          ),
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
                            ServiceLoader(
                                request: () => mockData2(),
                                onSuccess: (jsonData) {
                                  setState(() {
                                    recentLeaves = LeaveRequestModel.getList(jsonData['recent']);
                                  });
                                },
                                builder: () => SeparatorCard(
                                  separatorPadding: EdgeInsetsGeometry.only(left: 60, right: 10),
                                  children: [
                                    ...recentLeaves!.map((m) {
                                      return AppButton(
                                        icon: m.approve ? 'icon_success.svg' : 'icon_cancel.svg',
                                        iconColor: m.approve ? Color(0xFF30D143) : Color(0xFFE7000B),
                                        title: '${leaveNames[m.leaveType]!} | ${DateFormat.MMMd('th_TH').format(m.dateStart)} ${DateFormat.y('th_TH').format(m.dateStart)}',
                                        subTitle: 'หมายเลขคำขอ ${m.id}',
                                        weightTitle: FontWeight.w500,
                                      );
                                    })
                                  ],
                                )
                            )
                          ],
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