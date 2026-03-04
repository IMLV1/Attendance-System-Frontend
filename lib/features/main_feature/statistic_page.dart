import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/services/service_loader.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../services/statistic/attendance_stat_model.dart';
import '../../shared/widgets/utils/popup/date_filter_popup.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

Future<Response<dynamic>> getAttendenceStat({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // จำลองการโหลดข้อมูล 1 วินาที
  await Future.delayed(const Duration(seconds: 1));

  // --- ข้อมูล Mock ที่สมมติว่า Backend ส่งกลับมา ---
  final mockData = {
    "total_work_days": 25,
    "actual_work_days": 20,
    "on_time_percent": 70.0,
    "on_time_days": 14,
    "late_days": 4,
    "absent_days": 2,
    "total_leave_days": 6,
    "over_leave_days": 2,
    "leave_details": [
      {"label": "ลาป่วย", "used_days": 1.0, "quota_days": 60.0},
      {"label": "ลากิจส่วนตัว", "used_days": 1.0, "quota_days": 45.0},
      {"label": "ลาพักผ่อน", "used_days": 1.0, "quota_days": 21.5},
      {"label": "ลาคลอดบุตร", "used_days": 1.0, "quota_days": 180.0},
      {
        "label": "ลาช่วยเหลือภริยาคลอดบุตร",
        "used_days": 1.0,
        "quota_days": 60.0,
      },
      {
        "label": "ลากิจเพื่อเลี้ยงดูบุตร",
        "used_days": 1.0,
        "quota_days": 150.0,
      },
    ],
  };

  // ส่งกลับเป็น Response เพื่อให้ ServiceLoader ทำงานต่อได้
  return Response(
    requestOptions: RequestOptions(path: ''),
    data: mockData,
    statusCode: 200,
  );

}

class _StatisticPageState extends State<StatisticPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  // ประกาศตัวแปรไว้ด้านบน State
  AttendanceStatModel? _statData;

  void _showFilter() {
    DateFilterPopup(
      title: 'ตัวกรองข้อมูล',
      currentDateFrom: _startDate,
      currentDateTo: _endDate,
      onSubmit: (dateFrom, dateTo) {
        setState(() {
          _startDate = dateFrom;
          _endDate = dateTo;
        });
      },
    ).showPopup(context);
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
          child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
              child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            ServiceLoader(
                                key: ValueKey('$_startDate$_endDate'),
                                request: () => getAttendenceStat(startDate: _startDate, endDate: _endDate),
                                onSuccess: (data) {
                                  _statData = AttendanceStatModel.fromJson(data);
                                },
                                builder: () {
                                  return Column(
                                    spacing: 13,
                                    children: [
                                      Column(
                                        spacing: 6,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 6),
                                            child: InkWell(
                                              onTap: _showFilter,
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
                                                ],
                                              ),
                                            ),

                                            // GestureDetector(
                                            //   onTap: _showFilter,
                                            //   behavior: HitTestBehavior.opaque,
                                            //   child: Row(
                                            //     children: [
                                            //       SizedBox(
                                            //         width: 22,
                                            //         height: 22,
                                            //         child: SvgPicture.asset(
                                            //           'assets/images/filterIcon__attendance.svg',
                                            //         ),
                                            //       ),
                                            //
                                            //       SizedBox(width: 5),
                                            //
                                            //       Text(
                                            //         'ตัวกรอง',
                                            //         style: TextStyle(
                                            //           fontSize: 16,
                                            //           fontWeight: FontWeight.w200,
                                            //           color: AppColors.blackTextColor,
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                          ),
                                          workdayCard(),
                                        ],
                                      ),
                                      attendanceRateCard(),

                                    ],
                                  );
                                }
                            ),
                          ],
                        )
                      )
                    )
                  ]
                )
              )
          )
      );
  }

  Widget workdayCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: SeparatorCard(
              borderRadius: BorderRadius.circular(22),
              children: [
                _buildSummaryCard(
                  IconPath: 'assets/images/bag.svg',
                  title: 'วันทำงานทั้งหมด',
                  value: '${_statData?.totalWorkDays ?? 0} วัน',
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: SeparatorCard(
              borderRadius: BorderRadius.circular(22),
              children: [
                _buildSummaryCard(
                  IconPath: 'assets/images/people.svg',
                  title: 'วันทำงานทั้งหมด',
                  value: '${_statData?.actualWorkDays ?? 0} วัน',
                  valueColor: AppColors.textmurasaki,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String IconPath,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(22),
            ),
            child: SizedBox(
              width: 30,
              height: 30,
              child: SvgPicture.asset(IconPath),
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                    color: AppColors.blackTextColor,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularChart(double percent) {
    final double onTime = _statData?.onTimePercent ?? 0;
    final double late =
        (_statData?.lateDays ?? 0) / (_statData?.actualWorkDays ?? 1) * 100;
    final double absent =
        (_statData?.absentDays ?? 0) / (_statData?.actualWorkDays ?? 1) * 100;

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
              ],
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${percent.toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textgreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "ตรงเวลา",
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

  Widget attendanceRateCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column( // เพิ่ม Column คลุมตรงนี้
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
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
          // 1. ส่วนบัตรขาว (SeparatorCard)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              SeparatorCard(
                borderRadius: BorderRadius.circular(22),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildCircularChart(_statData?.onTimePercent ?? 0),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildLegend(
                                    AppColors.buttonCheckIn,
                                    'ตรงเวลา',
                                    '${_statData?.onTimeDays ?? 0} วัน',
                                    '${_statData?.onTimePercent?.toInt() ?? 0}',
                                  ),
                                  SizedBox(height: 10),
                                  _buildLegend(
                                    AppColors.yellowchart,
                                    'มาสาย',
                                    '${_statData?.lateDays ?? 0} วัน',
                                    '${((_statData?.lateDays ?? 0) / (_statData?.actualWorkDays ?? 1) * 100).toInt()}',
                                  ),
                                  SizedBox(height: 10),
                                  _buildLegend(
                                    AppColors.buttonCheckOut,
                                    'ขาดงาน',
                                    '${_statData?.absentDays ?? 0} วัน',
                                    '${((_statData?.absentDays ?? 0) / (_statData?.actualWorkDays ?? 1) * 100).toInt()}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 2),
                child: Row(
                  spacing: 7,
                  children: [
                    SvgPicture.asset('assets/images/iicon.svg'),
                    Text.rich(
                        TextSpan(
                            style: TextStyle(
                              fontSize: 10,
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
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          leaveSectionCard(),
        ],
      ),

    );
  }

  Widget _buildLegend(Color color, String label, String day, String percent) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        SizedBox(width: 5),

        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.blackTextColor,
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
        Text(
          day,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.blackTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(width: 10),

        if (percent.isNotEmpty) ...[
          SizedBox(width: 5),
          Text(
            '${percent}%',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.blackTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget leaveSectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          // หัวข้อ "การลางาน"
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 6,
              children: [
                SvgPicture.asset(
                  'assets/images/icon_leave.svg', // อย่าลืมเช็คชื่อไฟล์ icon นะครับ
                  width: 18,
                  height: 18,
                ),
                Text(
                  'การลางาน',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackTextColor,
                  ),
                ),
              ],
            ),
          ),

          // บัตรขาวแสดงรายละเอียดการลา
          SeparatorCard(
            borderRadius: BorderRadius.circular(22),
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildLeaveSummaryItem(
                            title: 'ลางานทั้งหมด',
                            value: '${_statData?.totalLeaveDays ?? 0} วัน',
                            valueColor: Color(0xFF5D5FEF), // สีม่วงน้ำเงิน
                          ),
                          SizedBox(height: 10),
                          _buildLeaveSummaryItem(
                            title: 'ลางานเกิน',
                            value: '${_statData?.overLeaveDays ?? 0} วัน',
                            valueColor: Color(0xFFFF8A48), // สีส้ม
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 15),

                    Expanded(
                      flex: 5,
                      child: Column(
                        spacing: 10,
                        children: _statData?.leaveDetails.map((leave) {
                          return _buildLeaveDetailRow(
                            label: leave.label,
                            used: leave.usedDays.toInt(),
                            quota: leave.quotaDays.toInt(),
                          );
                        }).toList() ?? [],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget ย่อยสำหรับสรุปตัวเลขฝั่งซ้าย
  Widget _buildLeaveSummaryItem({required String title, required String value, required Color valueColor}) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  String _getLeaveIconPath(String label) {
    if (label.contains('ลาป่วย')) return 'assets/images/icon_sick.svg';
    if (label.contains('ลากิจ')) return 'assets/images/icon_leave_personal.svg';
    if (label.contains('ลาพักผ่อน')) return 'assets/images/icon_rest.svg';
    if(label.contains('ลาคลอดบุตร')) return'assets/images/leave_maternity.svg';
    if(label.contains('ลาช่วยเหลือภริยาคลอดบุตร')) return 'assets/images/icon_leave_assist_childbirth.svg';
    if(label.contains('ลากิจเพื่อเลี้ยงดูบุตร'))return'assets/images/icon_taking_care_child.svg';

    return 'assets/images/icon_leave.svg';
  }

  // Widget ย่อยสำหรับรายการลาฝั่งขวา
  Widget _buildLeaveDetailRow({required String label, required int used, required int quota}) {
    return Row(
      children: [
        // icon สำหรับประเภทการลา (ปรับตามจริง)
        SizedBox(
          width: 14,
          height: 14,
          child: SvgPicture.asset(
            _getLeaveIconPath(label),
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.blackTextColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$used / $quota วัน',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
