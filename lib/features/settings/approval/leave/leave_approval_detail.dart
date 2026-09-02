import 'package:attendance_system/services/approval/leave/leave_service.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/profile_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../services/approval/leave/leave_model.dart';
import '../../../../services/statistic/statistic_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/head_bar/header.dart';
import '../../../../shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import '../../../../shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import '../../../main_feature/leave_request/leave_type.dart';
import 'leave_approval_detail_popup.dart';

class LeaveApprovalDetail extends StatefulWidget {
  final String userId;
  const LeaveApprovalDetail({
    super.key,
    required this.userId
  });

  @override
  State<LeaveApprovalDetail> createState() {
    return _LeaveApprovalDetail();
  }
}

class _LeaveApprovalDetail extends State<LeaveApprovalDetail> {

  LeaveApprovalModel? model;
  List<PendingUserDetail> pending = [];
  List<RecentLeaveApproval> result = [];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        header: Header.subHeader(
          context,
          title: 'รายละเอียดบุคลากร',
          onBack: () {
            Navigator.pop(context, result);
          }
        ),
        content: SafeArea(
            child: Container(
                color: AppColors.backgroundColor,
                alignment: Alignment.topCenter,
                child: ServiceLoader(
                    // request: () => Utils.mockResponse(
                    //   data: {
                    //     'user-detail': {
                    //       'name': 'ด้วยดี ตามไทย',
                    //       'init-role': 'อาจารย์ประจำภาควิชาคอมพิวเตอร์',
                    //       'avatar-url': '',
                    //     },
                    //     'leave-info': {
                    //       'sick': {
                    //         'used_days': 1.5,
                    //         'quota_days': 60.0
                    //       },
                    //       'personal': {
                    //         'used_days': 1.0,
                    //         'quota_days': 60.5
                    //       },
                    //       'vacation': {
                    //         'used_days': 1.5,
                    //         'quota_days': 60.5
                    //       },
                    //       'maternity': {
                    //         'used_days': 1.0,
                    //         'quota_days': 60.0
                    //       },
                    //       'paternity': {
                    //         'used_days': 1.0,
                    //         'quota_days': 60.0
                    //       },
                    //       'parental': {
                    //         'used_days': 1.0,
                    //         'quota_days': 60.0
                    //       },
                    //     },
                    //     'user-pending': [
                    //       {
                    //         'request-id': 'REQ0021312',
                    //         'type': 'sick',
                    //         'date-from': '2026-02-15T18:00:45.621Z',
                    //         'date-to': '2026-02-28T18:00:45.621Z',
                    //       },
                    //       {
                    //         'request-id': 'REQ0021312',
                    //         'type': 'sick',
                    //         'date-from': '2026-02-15T18:00:45.621Z',
                    //         'date-to': '2026-02-28T18:00:45.621Z',
                    //       },
                    //     ]
                    //   }
                    // ),
                    request: () => LeaveApprovalService().getUserDetail(widget.userId),
                    onSuccess: (val) {

                      print(val);

                      setState(() {
                        model = LeaveApprovalModel.fromJson(val['data']);
                        pending = model!.pendingUser;
                      });
                    },
                    builder: () => Column(
                        children: [
                            Expanded(
                                child: SingleChildScrollView(
                                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10, top: 10, bottom: 10
                                        ),
                                      child: Column(
                                        spacing: 13,
                                        children: [
                                          SeparatorCard(
                                            children: [
                                              ProfileButton(
                                                icon: Image.network(
                                                  model!.userDetail.avatarUrl,
                                                  errorBuilder: (_, _, _) {
                                                    return Image.asset('assets/images/profile.png');
                                                  },
                                                ),
                                                title: model!.userDetail.name,
                                                subTitle: model!.userDetail.initRole,
                                                heightProfile: 55,
                                                widthProfile: 55,
                                              ),
                                            ],
                                          ),

                                          Container(
                                            padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(22),
                                            ),
                                            child:  Column(
                                                spacing: 5,
                                                children: [
                                                  _buildLegend(LeaveType.sick, model?.leaveDetail.sick, pending),
                                                  _buildLegend(LeaveType.personal, model?.leaveDetail.personal, pending),
                                                  _buildLegend(LeaveType.vacation, model?.leaveDetail.vacation, pending),
                                                  _buildLegend(LeaveType.maternity, model?.leaveDetail.maternity, pending),
                                                  _buildLegend(LeaveType.paternity, model?.leaveDetail.paternity, pending),
                                                  _buildLegend(LeaveType.parental, model?.leaveDetail.parental, pending),
                                                  _buildLegend(LeaveType.ordination, model?.leaveDetail.ordination, pending),
                                                  _buildLegend(LeaveType.military, model?.leaveDetail.military, pending),
                                                  _buildLegend(LeaveType.rehabilitation, model?.leaveDetail.rehabilitation, pending),
                                                ]
                                            ),
                                          ),

                                          Column(
                                            spacing: 5,
                                            children: [
                                              Row(
                                                spacing: 6,
                                                children: [
                                                  SizedBox(
                                                    width: 15,
                                                    height: 15,
                                                    child: SvgPicture.asset(
                                                        'assets/images/icon_pending.svg'
                                                    ),
                                                  ),
                                                  Text('รอการอนุมัติ'),
                                                ],
                                              ),
                                              (pending.isEmpty) ? SeparatorCard(
                                                children: [
                                                  Container(
                                                    color: Colors.white,
                                                    width: double.infinity,
                                                    padding: EdgeInsetsGeometry.all(25),
                                                    child: Text(
                                                      'ไม่มีพบคำขออนุมัติลางาน',
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
                                                    ...pending.map((m) {
                                                      return AppButton(
                                                        icon: m.type.icon,
                                                        title: formatRange(m.dateStart, m.dateEnd),
                                                        subTitle: 'หมายเลขคำขอ: ${m.reqId}',
                                                        weightTitle: FontWeight.w500,
                                                        onPressed: () {
                                                          DynamicPushPopup(
                                                            initialConfig: PopupConfig(
                                                              title: 'รายละเอียด',
                                                              fit: FlexFit.tight,
                                                              maxHeight: 750,
                                                              scroll: false,
                                                              safeArea: false,
                                                            ),
                                                            builder: (context) {
                                                              return LeaveApprovalDetailPopup(
                                                                requestID: m.reqId,
                                                                showProfile: false,
                                                                onApproved: () {
                                                                  setState(() {
                                                                    pending.remove(m);
                                                                    result.insert(0, RecentLeaveApproval(userId: widget.userId, name: model!.userDetail.name, requestId: m.reqId, status: .approved, type: m.type, dateStart: m.dateStart));
                                                                  });
                                                                },
                                                                onRejected: () {
                                                                  setState(() {
                                                                    pending.remove(m);
                                                                    result.insert(0, RecentLeaveApproval(userId: widget.userId, name: model!.userDetail.name, requestId: m.reqId, status: .rejected, type: m.type, dateStart: m.dateStart));
                                                                  });
                                                                },
                                                              );
                                                            }, // โยนหน้า 1 เข้าไป
                                                          ).showPopup(context);
                                                        },
                                                      );
                                                    })
                                                  ]
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                )
                            )
                        ]
                    )
                )
            )
        ),
    );
  }
}

Widget _buildLegend(LeaveType leaveType, LeaveTypeDetailModel? leaveData, List<PendingUserDetail> pending) {

  int count = pending.where((e) => e.type == leaveType).length;

  return Row(
    spacing: 6,
    children: [
      Expanded(
        child: Row(
          spacing: 10,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: SvgPicture.asset(
                'assets/images/${leaveType.icon}',
                width: 14,
                height: 14,
              ),
            ),
            Expanded(
              child: FittedBox(
                  fit: BoxFit.scaleDown, // 👈 This tells the text to shrink if it overflows
                  alignment: Alignment.centerLeft, // Keep it aligned to the left
                  child: Text(
                    '${leaveType.display} ${count <= 0 ? '' : '($count)'}',
                    style: TextStyle(
                        color: Color(0xFF3A3A3A),
                        fontSize: 13
                    ),
                  )
              ),
            )
          ],
        ),
      ),
      Text.rich(
          TextSpan(
              children: [
                TextSpan(
                  text: Utils.numberFormat(leaveData?.usedDays ?? 0),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
                TextSpan(
                  text: ' / ${Utils.numberFormat(leaveData?.quotaDays ?? 0)} วัน',
                  style: TextStyle(
                      fontSize: 13
                  ),
                )
              ]
          )
      )
    ],
  );
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