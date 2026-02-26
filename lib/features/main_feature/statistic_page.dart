import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../shared/widgets/utils/popup/date_filter_popup.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});


  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  DateTime? _startDate;
  DateTime? _endDate;

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
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 10),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: GestureDetector(
                  onTap: _showFilter,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: SvgPicture.asset(
                            'assets/images/filterIcon__attendance.svg'
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'ตัวกรอง',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                            color: AppColors.blackTextColor
                        ),
                      )
                    ],
                  ),
                ),
              ),
              workdayCard(),
            ],
          ),

        )
    );
  }

  Widget workdayCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.lightTextColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16)
      ),
      child: Row(
        children: [
          Expanded(
            child: SeparatorCard(
              borderRadius: BorderRadius.circular(22),
              children: [
                _buildSummaryCard(
                    IconPath: 'assets/images/bag.svg',
                    title: 'วันทำงานทั้งหมด', value: '25 วัน'),
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
                    title: 'วันทำงานทั้งหมด', value: '25 วัน',valueColor: AppColors.textmurasaki),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String IconPath,
    required String title,
    required String value,
    Colors? colortext,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightTextColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
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
                      color: AppColors.blackTextColor
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? AppColors.primaryColor,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
    );
  }
}