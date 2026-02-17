import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../services/system_config/attendance_time/config_attendance_time_model.dart';
import '../../../shared/widgets/utils/separator_card.dart';
import '../../../shared/widgets/utils/wheel_selector.dart';

class TimeRequestPopup extends StatefulWidget {
  const TimeRequestPopup({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TimeRequestPopupState();
  }
}

class _TimeRequestPopupState extends State<StatefulWidget> {
  final List<String> hours = List.generate(24, (index) => index.toString().padLeft(2, '0'),);
  final List<String> minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'),);

  DateTime focusedDay = DateTime.now();
  DateTime? rangeStart;
  DateTime? rangeEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),

          child: TableCalendar(
            locale: 'th_TH',
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(3000, 12, 31),

            focusedDay: focusedDay,
            rangeStartDay: rangeStart,
            rangeEndDay: rangeEnd,

            rangeSelectionMode: RangeSelectionMode.enforced,

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),

            onRangeSelected: (start, end, focusedDay) {

              setState(() {
                rangeStart = start;
                rangeEnd = end;
                focusedDay = focusedDay;
              });
            },

            calendarStyle: const CalendarStyle(

              rangeHighlightColor: Color(0xFFE3F2FD),

              rangeStartDecoration: BoxDecoration(
                color: Color(0xFF4A80F0),
                shape: BoxShape.circle,
              ),

              rangeEndDecoration: BoxDecoration(
                color: Color(0xFF4A80F0),
                shape: BoxShape.circle,
              ),

              todayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),

              todayTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),

              selectedDecoration: BoxDecoration(
                color: Color(0xFF4A80F0),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        SeparatorCard(
          borderRadius: BorderRadius.circular(22),
          separatorPadding: EdgeInsetsGeometry.only(
            left: 45,
            right: 15,
          ),
          children: [
            IconTextValueButton(
              icon: 'clock_calendar.svg',
              label: 'จากวันที่',
              value: '9 ก.ย. 68',
              disable: true,
              arrow: false,
            ),
            IconTextValueButton(
              icon: 'clock_calendar.svg',
              label: 'ถึงวันที่',
              value: '9 ก.ย. 68',
              disable: true,
              arrow: false,
            )
          ],
        ),

        SeparatorCard(
          borderRadius: BorderRadius.circular(22),
          separatorPadding: EdgeInsetsGeometry.only(
            left: 45,
            right: 15,
          ),
          children: [
            WheelSelector(
              height: 150,
              // Data Sources
              leftItems: hours,
              rightItems: minutes,

              // Initial Positions
              // initialLeftIndex: data!.cutoffTime.hour,
              // initialRightIndex: data!.cutoffTime.minute,

              // Handle Changes
              onChanged: (leftIndex, rightIndex) {
                setState(() {
                  // data = data!.copyWith(cutoffTime: TimeOfDay(
                  //     hour: leftIndex,
                  //     minute: rightIndex ?? 0
                  // ));
                });
              },
            ),
            WheelSelector(
              height: 150,
              // Data Sources
              leftItems: hours,
              rightItems: minutes,

              // Initial Positions
              // initialLeftIndex: data!.cutoffTime.hour,
              // initialRightIndex: data!.cutoffTime.minute,

              // Handle Changes
              onChanged: (leftIndex, rightIndex) {
                setState(() {
                  // data = data!.copyWith(cutoffTime: TimeOfDay(
                  //     hour: leftIndex,
                  //     minute: rightIndex ?? 0
                  // ));
                });
              },
            ),
          ],
        )
      ],
    );
  }
}