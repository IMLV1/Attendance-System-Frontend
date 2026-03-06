import 'package:attendance_system/features/main_feature/leave_request/leave_type.dart';
import 'package:attendance_system/services/statistic/attendance_stat_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeaveStatistic extends StatelessWidget {
  final StatisticModel? statistic;

  const LeaveStatistic(this.statistic, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        /// Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            spacing: 6,
            children: [
              SvgPicture.asset(
                'assets/images/icon_leave.svg', // อย่าลืมเช็คชื่อไฟล์ icon นะครับ
                width: 16,
                height: 16,
              ),
              Text(
                'การลางาน',
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
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            spacing: 13,
            children: [
              /// Summary
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                child: Column(
                  spacing: 10,
                  children: [
                    Column(
                      children: [
                        Text('ลางานทั้งหมด',
                            style: TextStyle(fontSize: 14, color: Color(0xFF767676))
                        ),
                        Text(
                          '${statistic?.leaveDetail.totalLeaveDays ?? '---'} วัน',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D5FEF)
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('ลางานเกิน',
                            style: TextStyle(fontSize: 14, color: Color(0xFF767676))
                        ),
                        Text(
                          '${statistic?.leaveDetail.overLeaveDays ?? '---'} วัน',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8A48)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Details
              Expanded(
                child: Column(
                  spacing: 5,
                  children: [
                    _buildLegend(LeaveType.sick, statistic?.leaveDetail.leaveDetails.sick),
                    _buildLegend(LeaveType.personal, statistic?.leaveDetail.leaveDetails.personal),
                    _buildLegend(LeaveType.vacation, statistic?.leaveDetail.leaveDetails.vacation),
                    _buildLegend(LeaveType.maternity, statistic?.leaveDetail.leaveDetails.maternity),
                    _buildLegend(LeaveType.paternity, statistic?.leaveDetail.leaveDetails.paternity),
                    _buildLegend(LeaveType.parental, statistic?.leaveDetail.leaveDetails.parental),
                  ]
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildLegend(LeaveType leaveType, LeaveTypeDetailModel? leaveData) {

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
                      leaveType.display,
                      style: TextStyle(
                          color: Color(0xFF767676),
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
}