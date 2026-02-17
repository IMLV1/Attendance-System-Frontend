import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

enum CalendarPopupMode { dateTime, halfDay }

class CalendarPopup {

  final String title;
  final String buttonLabel;
  final CalendarPopupMode mode;
  final Function(DateTime date)? onSubmit;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;
  final bool scroll;

  const CalendarPopup({
    this.title = 'เลือกวันที่',
    this.buttonLabel = 'บันทึก',
    required this.mode,
    this.onSubmit,
    this.maxHeight = double.infinity,
    this.minHeight = 0,
    this.fit = FlexFit.tight,
    this.scroll = true,
  });

  void showPopup(BuildContext context) {

    DateTime? selectedDate;

    PushPopup(
      title: title,
      buttonLabel: buttonLabel,

      buttonAction: (context) {

        if (selectedDate != null && onSubmit != null) {
          onSubmit!(selectedDate!);
        }

        Navigator.pop(context);
      },

      maxHeight: maxHeight,
      minHeight: minHeight,
      fit: fit,
      scroll: scroll,

      builder: (context) {
        return _CalendarPopupContent(
          mode: mode,
          onSubmit: (date) {
            selectedDate = date;
          },
        );
      },

    ).showPopup(context);
  }
}

class _CalendarPopupContent extends StatefulWidget {

  final CalendarPopupMode mode;
  final Function(DateTime date)? onSubmit;

  const _CalendarPopupContent({
    required this.mode,
    this.onSubmit,
  });

  @override
  State<_CalendarPopupContent> createState() => _CalendarPopupContentState();
}

class _CalendarPopupContentState extends State<_CalendarPopupContent> {

  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: TableCalendar(

        locale: 'th_TH',

        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(3000, 12, 31),

        focusedDay: _focusedDay,

        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,

        rangeSelectionMode: RangeSelectionMode.enforced,

        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),

        onRangeSelected: (start, end, focusedDay) {

          setState(() {
            _rangeStart = start;
            _rangeEnd = end;
            _focusedDay = focusedDay;
          });

          if (start != null) {
            widget.onSubmit?.call(start);
          }

        },

        calendarStyle: CalendarStyle(

          rangeHighlightColor: const Color(0xFFE3F2FD),

          rangeStartDecoration: const BoxDecoration(
            color: Color(0xFF4A80F0),
            shape: BoxShape.circle,
          ),

          rangeEndDecoration: const BoxDecoration(
            color: Color(0xFF4A80F0),
            shape: BoxShape.circle,
          ),

          todayDecoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),

          todayTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),

          selectedDecoration: const BoxDecoration(
            color: Color(0xFF4A80F0),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
