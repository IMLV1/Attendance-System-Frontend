import 'package:attendance_system/features/main_feature/statistic/attendance_statistic.dart';
import 'package:attendance_system/features/main_feature/statistic/leave_statistic.dart';
import 'package:attendance_system/features/main_feature/statistic/working_day.dart';
import 'package:attendance_system/features/main_feature/statistic/working_hour.dart';
import 'package:attendance_system/services/statistic/statistic_service.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/animation/animated_widget.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:attendance_system/shared/widgets/utils/wheel_selector.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../services/statistic/statistic_model.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

Future<Response<dynamic>> getAttendanceStat() async {
  // จำลองการโหลดข้อมูล 1 วินาที
  await Future.delayed(const Duration(seconds: 1));

  // --- ข้อมูล Mock ที่สมมติว่า Backend ส่งกลับมา ---
  final mockData = {
    'total_work_days': 25,
    'actual_work_days': 20,
    'attendance_detail': {
      'on_time_days': 14,
      'late_days': 2,
      'absent_days': 4,
    },
    'leave_detail': {
      'total_leave_days': 6,
      'over_leave_days': 2,
      'leaves': {
        'sick': {
          'used_days': 1.5,
          'quota_days': 60.0
        },
        'personal': {
          'used_days': 1.0,
          'quota_days': 60.5
        },
        'vacation': {
          'used_days': 1.5,
          'quota_days': 60.5
        },
        'maternity': {
          'used_days': 1.0,
          'quota_days': 60.0
        },
        'paternity': {
          'used_days': 1.0,
          'quota_days': 60.0
        },
        'parental': {
          'used_days': 1.0,
          'quota_days': 60.0
        },
      }
    }
  };

  // ส่งกลับเป็น Response เพื่อให้ ServiceLoader ทำงานต่อได้
  return Response(
    requestOptions: RequestOptions(path: ''),
    data: mockData,
    statusCode: 200,
  );

}

class _StatisticPageState extends State<StatisticPage> {

  StatisticModel? statistic;
  WorkingHourModel? workingHour;
  DateTime yearFilter = DateTime(DateTime.now().year);

  DateTime? allowFilterStart;
  DateTime? allowFilterEnd;

  List<int> getYears(DateTime? start, DateTime? end) {
    if (start == null || end == null) return [];

    int startYear = start.year;
    int endYear = end.year;

    // สลับค่าถ้าปีเริ่มต้นมากกว่าปีสิ้นสุด
    if (startYear > endYear) {
      int temp = startYear;
      startYear = endYear;
      endYear = temp;
    }

    // สร้าง Array ของปี
    return [for (int y = startYear; y <= endYear; y++) y];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideNavigation: false,
      header: Header.mainHeader(
        context,
        title: 'สถิติ',
        subTitle: 'Statistic',
        iconPath: 'statis.svg',
      ),
      content: Container(
        color: AppColors.backgroundColor,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                  child: Column(
                    children: [
                      ServiceUpdaterProMax(
                        requests: [
                          () => StatisticService().getStatistic(year: yearFilter),
                          () => StatisticService().getWorkingHour(),
                          () => StatisticService().getFilterRange(),
                        ],
                        onSuccess: (index, data) {
                          switch(index) {
                            case 0: statistic = StatisticModel.fromJson(data);
                            case 1: workingHour = WorkingHourModel.fromJson(data);
                            case 2: {
                              allowFilterStart = DateTime.tryParse(data['start']);
                              allowFilterEnd = DateTime.tryParse(data['end']);
                            }
                          }
                        },
                        fetchOnInit: true,
                        builder: (trigger, getState) {
                          return Column(
                            spacing: 13,
                            children: [
                              /// First Part
                              Column(
                                spacing: 6,
                                children: [
                                  /// Filter
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: InkWell(
                                      onTap: () {
                                        if (statistic != null) {
                                          int selectedIndex = getYears(
                                            allowFilterStart, allowFilterEnd)
                                            .indexOf(yearFilter.year);
                                          PushPopup(
                                            title: 'เลือกปีงบประมาณ',
                                            buttonLabel: 'บันทึก',
                                            fit: FlexFit.tight,
                                            maxHeight: 650,
                                            buttonAction: (context) {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                int year = getYears(
                                                    allowFilterStart,
                                                    allowFilterEnd)[selectedIndex];
                                                yearFilter = DateTime(year);
                                              });
                                            },
                                            builder: (context) {
                                              bool opened = false;

                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return SeparatorCard(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            IconTextValueButton(
                                                              icon: 'budget_year.svg',
                                                              label: 'ปีงบประมาณ',
                                                              value: (getYears(
                                                                  allowFilterStart,
                                                                  allowFilterEnd)[selectedIndex] +
                                                                  543)
                                                                  .toString(),
                                                              onPressed: () {
                                                                setState(() {
                                                                  opened =
                                                                  !opened;
                                                                });
                                                              },
                                                            ),
                                                            AnimatedSizeWidget(
                                                                enable: opened,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                        padding: EdgeInsetsGeometry
                                                                            .symmetric(
                                                                            horizontal: 15),
                                                                        child: Divider(
                                                                            height: 0)
                                                                    ),
                                                                    WheelSelector(
                                                                      looping: false,
                                                                      height: 150,
                                                                      initialLeftIndex: selectedIndex,
                                                                      leftItems: getYears(
                                                                          allowFilterStart,
                                                                          allowFilterEnd)
                                                                          .map((
                                                                          e) =>
                                                                          (e +
                                                                              543)
                                                                              .toString())
                                                                          .toList(),
                                                                      onChanged: (
                                                                          left,
                                                                          right) {
                                                                        setState(() {
                                                                          selectedIndex =
                                                                              left;
                                                                        });
                                                                      },
                                                                    )
                                                                  ],
                                                                )
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    );
                                                  }
                                              );
                                            },
                                          ).showPopup(context);
                                        }
                                      },
                                      child: Row(
                                        spacing: 6,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/filter.svg',
                                            colorFilter: ColorFilter.mode(Color(0xFF2C2C2C), BlendMode.srcIn),
                                          ),
                                          Text(
                                            'ปีงบประมาณ ${yearFilter.year + 543}',
                                            style: TextStyle(
                                                color: Color(0xFF2C2C2C)
                                            )
                                          ),
                                          if (getState(0) == ServiceUpdaterProMaxState.loading)
                                            CupertinoActivityIndicator()
                                        ],
                                      ),
                                    ),
                                  ),

                                  Column(
                                    spacing: 13,
                                    children: [
                                      /// Working Day
                                      WorkingDay(statistic),

                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFEAEAEA),
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        child: Column(
                                          spacing: 13,
                                          children: [
                                            /// Attendance Statistic
                                            AttendanceStatistic(statistic),

                                            /// Leave Statistic
                                            LeaveStatistic(statistic),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),

                              /// Working Hour
                              WorkingHour(workingHour)
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                )
              )
            )
          ]
        )
      )
    );
  }
}