import 'package:attendance_system/services/statistic/attendance_stat_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkingDay extends StatelessWidget {

  final StatisticModel? statistic;

  const WorkingDay(this.statistic, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      children: [
        Container(
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
                    Padding(
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
                              child: SvgPicture.asset('assets/images/bag.svg'),
                            ),
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown, // 👈 This tells the text to shrink if it overflows
                                  alignment: Alignment.centerLeft, // Keep it aligned to the left
                                  child: Text(
                                    'วันทำงานทั้งหมด',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w200,
                                      color: AppColors.blackTextColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${statistic?.totalWorkDays ?? '---'} วัน',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor, // AppColors.textmurasaki
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SeparatorCard(
                  borderRadius: BorderRadius.circular(22),
                  children: [
                    Padding(
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
                              child: SvgPicture.asset('assets/images/people.svg'),
                            ),
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown, // 👈 This tells the text to shrink if it overflows
                                  alignment: Alignment.centerLeft, // Keep it aligned to the left
                                  child: Text(
                                    'วันที่ต้องทำงานจริง',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w200,
                                      color: AppColors.blackTextColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${statistic?.actualWorkDays ?? '---'} วัน',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textmurasaki
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}