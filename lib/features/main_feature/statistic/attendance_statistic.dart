import 'package:attendance_system/services/statistic/statistic_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AttendanceStatistic extends StatelessWidget {
  final StatisticModel? statistic;

  const AttendanceStatistic(this.statistic, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        /// Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: SvgPicture.asset(
                  'assets/images/chart.svg',
                ),
              ),

              SizedBox(width: 5),

              Text(
                'อัตราการเข้างาน',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.blackTextColor,
                ),
              ),
            ],
          ),
        ),

        /// Content
        Container(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            spacing: 13,
            children: [
              /// Pie Chart
              _circularChart(),

              /// Details
              Expanded(
                child: Column(
                  spacing: 9,
                  children: [

                    Row(
                      children: [
                        Expanded(
                            flex: 9,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 6,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF03BC78),
                                      shape: BoxShape.circle,
                                      border: BoxBorder.all(color: Colors.grey, strokeAlign: BorderSide.strokeAlignOutside)
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                      'ตรงเวลา',
                                    )
                                )
                              ],
                            )
                        ),
                        Expanded(
                            flex: 6,
                            child: Text(
                              '${statistic?.attendanceDetail.onTimeDays ?? '--'} วัน',
                            )
                        ),
                        Expanded(
                            flex: 5,
                            child: Text(
                              '${statistic != null ? (statistic!.attendanceDetail.onTimeDays / statistic!.actualWorkDays * 100).toInt() : '--'}%',
                            )
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 9,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 6,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFFAF068),
                                      shape: BoxShape.circle,
                                      border: BoxBorder.all(color: Colors.grey, strokeAlign: BorderSide.strokeAlignOutside)
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                      'สาย',
                                    )
                                )
                              ],
                            )
                        ),
                        Expanded(
                            flex: 6,
                            child: Text(
                              '${statistic?.attendanceDetail.lateDays ?? '--'} วัน',
                            )
                        ),
                        Expanded(
                            flex: 5,
                            child: Text(
                              '${statistic != null ? (statistic!.attendanceDetail.lateDays / statistic!.actualWorkDays * 100).toInt() : '--'}%',
                            )
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 9,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 6,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFFF5151),
                                      shape: BoxShape.circle,
                                      border: BoxBorder.all(color: Colors.grey, strokeAlign: BorderSide.strokeAlignOutside)
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                      'ขาด',
                                    )
                                )
                              ],
                            )
                        ),
                        Expanded(
                            flex: 6,
                            child: Text(
                              '${statistic?.attendanceDetail.absentDays ?? '--'} วัน',
                            )
                        ),
                        Expanded(
                            flex: 5,
                            child: Text(
                              '${statistic != null ? (statistic!.attendanceDetail.absentDays / statistic!.actualWorkDays * 100).toInt() : '--'}%',
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),

        /// Info
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            spacing: 7,
            children: [
              SizedBox(
                height: 15,
                width: 15,
                child: SvgPicture.asset(
                    'assets/images/iicon.svg'
                ),
              ),
              Expanded(
                child: Text.rich(
                    TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyTextColor,
                        ),
                        children: [
                          TextSpan(text: 'อัตราการเข้างานจะถูกคำนวณจาก '),
                          TextSpan(
                            text: 'วันที่ต้องทำงานจริง',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' ในช่วงเวลาดังกล่าว'),
                        ]
                    )
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _circularChart() {

    final double onTime = (statistic?.attendanceDetail.onTimeDays ?? 0) / (statistic?.actualWorkDays ?? 1) * 100;
    final double late = (statistic?.attendanceDetail.lateDays ?? 0) / (statistic?.actualWorkDays ?? 1) * 100;
    final double absent = (statistic?.attendanceDetail.absentDays ?? 0) / (statistic?.actualWorkDays ?? 1) * 100;
    final double noData = 100 - (onTime + late + absent);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  color: AppColors.buttonCheckIn,
                  value: onTime,
                  radius: 12,
                  showTitle: false,
                ),
                PieChartSectionData(
                  color: AppColors.yellowchart,
                  value: late,
                  radius: 12,
                  showTitle: false,
                ),
                PieChartSectionData(
                  color: AppColors.buttonCheckOut,
                  value: absent,
                  radius: 12,
                  showTitle: false,
                ),
                PieChartSectionData(
                  color: Colors.grey.shade300,
                  value: noData,
                  radius: 12,
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${onTime.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textgreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ตรงเวลา',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.greyTextColor,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ],
    );
  }
}