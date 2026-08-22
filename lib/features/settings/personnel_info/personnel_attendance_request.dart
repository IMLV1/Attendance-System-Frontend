import 'package:attendance_system/features/main_feature/time_request/time_request_page.dart';
import 'package:attendance_system/features/settings/personnel_info/choose_personnel.dart';
import 'package:attendance_system/features/settings/personnel_info/personnel_attendance_request_detail.dart';
import 'package:attendance_system/services/personnel_info/personnel_attendance_request_service.dart';
import 'package:attendance_system/services/personnel_info/personnel_info_model.dart';
import 'package:attendance_system/services/personnel_info/personnel_info_service.dart';
import 'package:attendance_system/services/time_request/time_request_model.dart';
import 'package:attendance_system/services/user_management/user_management_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/app_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/date_filter_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_popup_config.dart';
import 'package:attendance_system/shared/widgets/utils/popup/multi_page/dynamic_push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:attendance_system/shared/widgets/utils/user_info_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../shared/widgets/utils/sliver_separator_list.dart';

class PersonnelAttendanceRequest extends StatefulWidget {

  final PersonnelInfoModel personnel;

  const PersonnelAttendanceRequest({super.key, required this.personnel});

  @override
  State<StatefulWidget> createState() => _PersonnelAttendanceRequestState();

}

class _PersonnelAttendanceRequestState extends State<PersonnelAttendanceRequest> {

  PersonnelInfoModel? personnel;

  List<PendingAttendanceRequestModel> pendingList = [];
  List<AttendanceRequestModel> recentList = [];

  int permissionLevel = 0;

  DateTime? filterStartAllow;
  DateTime? filterEndAllow;

  DateTime? filterStart;
  DateTime? filterEnd;

  @override
  void initState() {
    super.initState();
    personnel = widget.personnel;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: Header.subHeader(
        context,
        title: 'บันทึกการขออนุมัติเวลางาน',
        onBack: () {
          Navigator.of(context).pop(personnel);
        }
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
                  // 🚩 (2026-08-22) เดิม SingleChildScrollView -> ทุกแถวของ "รายการล่าสุด"
                  // ถูก build พร้อมกันตอนเปิดหน้า
                  // ⚠️ ห้ามเอา SingleChildScrollView กลับมาครอบ ไม่งั้น sliver ข้างในจะ
                  // ถูก shrink-wrap แล้ว build ครบทุกแถวเหมือนเดิม
                  child: CustomScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [ ServiceUpdaterProMax(
                      requests: [
                          () => PersonnelAttendanceRequestService().getPending(personnel!.id),
                          () => PersonnelAttendanceRequestService().getRecent(personnel!.id, filterStart, filterEnd),
                          () => PersonnelAttendanceRequestService().getFilterRange(personnel!.id),
                          () => PersonnelInfoService().getPermissionLevel(personnel!.id),
                      ],
                      onSuccess: (index, data) {
                        setState(() {
                          switch (index) {
                            case 0: pendingList = PendingAttendanceRequestModel.getList(data['pending']);
                            case 1: recentList = AttendanceRequestModel.getList(data['recent']);
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
                            case 3: permissionLevel = data['permission-level'] ?? 0;
                          }
                        });
                      },
                      fetchOnInit: true,
                      builder: (trigger, getState) {
                        return SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE3E3E3),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 14),
                                child: SeparatorCard(
                                  children: [
                                    UserInfoButton(
                                      icon: Image.network(
                                        personnel!.avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Image.asset('assets/images/profile.png'),
                                      ),
                                      title: personnel!.nameTH,
                                      subTitle: personnel!.nameEN,
                                      roles: [
                                        ...personnel!.roles,
                                        Role(id: '0000000000', name: personnel!.initRole, color: Color(0xFF535353))
                                      ],
                                      onPressed: () {
                                        PushPopup(
                                            title: 'เลือกบุคลากร',
                                            fit: FlexFit.tight,
                                            maxHeight: 700,
                                            scroll: false,
                                            builder: (BuildContext context) {
                                              return ChoosePersonnel(
                                                  onChoose: (personnel) {
                                                    setState(() {
                                                      this.personnel = personnel;
                                                    });
                                                    trigger(-1);
                                                  }
                                              );
                                            }
                                        ).showPopup(context);
                                      },
                                    )
                                  ],
                                )
                            ),
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 13)),

                            if (getState(0) == ServiceUpdaterProMaxState.loading &&
                                getState(1) == ServiceUpdaterProMaxState.loading)
                              SliverToBoxAdapter(
                                child: Center(child: CupertinoActivityIndicator()),
                              )
                            else ...[
                                // "รอดำเนินการ" มีไม่กี่รายการ -> ปล่อยเป็นก้อนเดียว
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
                                                      scroll: false,
                                                      safeArea: false,
                                                    ),
                                                    builder: (context) {
                                                      return PersonnelAttendanceRequestDetail(
                                                        id: m.id,
                                                        permissionLevel: permissionLevel,
                                                        onApproved: () {
                                                          setState(() {
                                                            pendingList.remove(m);
                                                            recentList.add(AttendanceRequestModel(id: m.id, dateStart: m.dateStart, dateEnd: m.dateEnd, status: 'approved'));
                                                          });
                                                        },
                                                        onRejected: () {
                                                          setState(() {
                                                            pendingList.remove(m);
                                                            recentList.add(AttendanceRequestModel(id: m.id, dateStart: m.dateStart, dateEnd: m.dateEnd, status: 'rejected'));
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

                                if (recentList.isEmpty && getState(1) != ServiceUpdaterProMaxState.loading)
                                  SliverToBoxAdapter(
                                    child: SeparatorCard(
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
                                                  scroll: false,
                                                  safeArea: false,
                                                ),
                                                builder: (context) {
                                                  return PersonnelAttendanceRequestDetail(
                                                    id: m.id,
                                                    permissionLevel: permissionLevel,
                                                    onApproved: () { },
                                                    onRejected: () { },
                                                  );
                                                }, // โยนหน้า 1 เข้าไป
                                              ).showPopup(context);
                                            },
                                          );
                                      },
                                  ),
                            ],
                            SliverToBoxAdapter(child: SizedBox(height: 20)),
                          ]
                        );
                      }
                    ) ],
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