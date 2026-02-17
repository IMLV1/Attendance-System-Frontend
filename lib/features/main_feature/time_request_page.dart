import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../shared/widgets/utils/calendar.dart';

class TimeRequestPage extends StatefulWidget {
  const TimeRequestPage({super.key});

  @override
  State<TimeRequestPage> createState() => _TimeRequestPage();
}

class _TimeRequestPage extends State<TimeRequestPage> {
  String startDate = "---";
  String endDate = "---";
  String startTime = "---";
  String endTime = "---";

  void _openDateTimeRangePicker() {
    PushPopup(
      title: 'เลือกช่วงเวลา',
      buttonLabel: 'บันทึก',
      buttonAction: (context) {
        Navigator.pop(context);
      },
      builder: (_) => CalendarTimePopupContent(
        onSave: (start, end, checkIn, checkOut) {
          setState(() {
            if (start != null) {
              startDate = "${start.day}/${start.month}/${start.year + 543}";
            }
            if (end != null) {
              endDate = "${end.day}/${end.month}/${end.year + 543}";
            }
            startTime = checkIn;
            endTime = checkOut;
          });
        },
      ),
    ).showPopup(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideNavigation: false,
      header: Header.mainHeader(
          context,
          title: 'ขออนุมัติเวลาเข้า-ออกงาน',
          subTitle: 'Attendance Request',
          iconPath: 'time_request.svg'
      ),
      content: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Row(
                   spacing: 6,
                   children: [
                     SizedBox(
                       height: 20,
                       width: 20,
                       child: SvgPicture.asset(
                         'assets/images/icon_req_lev.svg',
                       ),
                     ),
                     Text(
                       'รายละเอียดการเข้างาน',
                       style: TextStyle(
                         fontSize: 15,
                       ),
                     )
                   ],
                 ),
                  InkWell(
                    onTap: _openDateTimeRangePicker,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      // กล่องสีเทาใหญ่ที่อยู่ด้านหลังสุด
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _buildPickerCell("จากวันที่", startDate, 'assets/images/calendar_in.svg', h: 12, v: 10),),
                                _buildVerticalLine(),
                                Expanded(child: _buildPickerCell("ถึงวันที่", endDate, 'assets/images/calendar_out.svg', h: 12,v: 10),)
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: _buildPickerCell('เวลาเข้างาน', startTime,'assets/images/clock_calendar.svg'),
                                )
                              ),
                              const SizedBox(width: 10),

                              Flexible(
                                  child:Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: _buildPickerCell('เวลาเข้าออกงาน', endTime,'assets/images/clock_calendar.svg'),
                                  )
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],

              ),
            ),
          )
      ),
    );
  }

  Widget _buildPickerCell(String label, String value, String iconPath , {double h = 10, double v = 4}) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: h , vertical: v ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                iconPath,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightTextColor)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildVerticalLine() => Container(width: 2, height: 40, color: AppColors.lightTextColor);
}
