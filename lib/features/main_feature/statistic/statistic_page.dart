import 'package:attendance_system/features/main_feature/statistic/attendance_statistic.dart';
import 'package:attendance_system/features/main_feature/statistic/leave_statistic.dart';
import 'package:attendance_system/features/main_feature/statistic/working_day.dart';
import 'package:attendance_system/features/main_feature/statistic/working_hour.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_updater_promax.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
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
                          () => getAttendanceStat(),
                          () => Utils.mockResponse(
                            data: {
                              'total-working-hour': 10144.51,
                              'total-average-hour': 802.0,
                              'weekly-working-hour': 42.0,
                              'weekly-average-hour': 25.0,
                              'monthly-working-hour': 102.0,
                              'monthly-average-hour': 240.0,
                              'yearly-working-hour': 2452.0,
                              'yearly-average-hour': 1020.0,
                              'total': {
                                '64': 1300.0,
                                '65': 2117.0,
                                '66': 1893.0,
                                '67': 1529.0,
                                '68': 1989.0,
                                '69': 482.0,
                              },
                              'week': {
                                'อา.': 13.0,
                                'จ.': 21.0,
                                'อ.': 8.0,
                                'พ.': 6.0,
                                'พฤ.': 5.5,
                                'ศ.': 4.75,
                                'ส.': 9.02,
                              },
                              'month': {
                                '1': 13.0,
                                '2': 18.0,
                                '3': 13.0,
                                '4': 1.0,
                                '5': 13.0,
                                '6': 3.0,
                                '7': 13.0,
                                '8': 18.0,
                                '9': 12.0,
                                '10': 13.0,
                                '11': 5.0,
                                '12': 13.0,
                                '13': 6.0,
                                '14': 13.0,
                                '15': 9.0,
                                '16': 3.0,
                                '17': 17.0,
                                '18': 7.0,
                                '19': 7.0,
                                '20': 0.0,
                                '21': 3.0,
                                '22': 5.0,
                                '23': 7.0,
                                '24': 4.0,
                                '25': 8.0,
                                '26': 4.0,
                                '27': 16.0,
                                '28': 2.0,
                                '29': 13.0,
                                '30': 10.0,
                              },
                              'year': {
                                'ม.ค.': 19.98,
                                'ก.พ.': 17.74,
                                'มี.ค.': 13.48,
                                'เม.ย.': 3.94,
                                'พ.ค.': 2.61,
                                'มิ.ย.': 5.30,
                                'ก.ค.': 14.60,
                                'ส.ค.': 7.89,
                                'ก.ย.': 3.27,
                                'ต.ค.': 10.77,
                                'พ.ย.': 7.81,
                                'ธ.ค.': 3.05,
                              }
                            }
                          )
                        ],
                        onSuccess: (index, data) {
                          switch(index) {
                            case 0: statistic = StatisticModel.fromJson(data);
                            case 1: workingHour = WorkingHourModel.fromJson(data);
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
                                      onTap: () {},
                                      child: Row(
                                        spacing: 6,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/filter.svg',
                                            colorFilter: ColorFilter.mode(Color(0xFF2C2C2C), BlendMode.srcIn),
                                          ),
                                          Text(
                                              'ตัวกรอง',
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