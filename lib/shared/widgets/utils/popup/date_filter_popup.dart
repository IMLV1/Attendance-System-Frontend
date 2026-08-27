import 'package:attendance_system/shared/widgets/utils/animation/animated_widget.dart';
import 'package:attendance_system/shared/widgets/utils/ios_menu.dart';
import 'package:attendance_system/shared/widgets/utils/native_select/native_select.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/popup/push_popup.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/text_button.dart';
import 'package:attendance_system/shared/widgets/utils/wheel_selector.dart';
import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

final List<String> month = [
  'มกราคม',
  'กุมภาพันธ์',
  'มีนาคม',
  'เมษายน',
  'พฤษภาคม',
  'มิถุนายน',
  'กรกฎาคม',
  'สิงหาคม',
  'กันยายน',
  'ตุลาคม',
  'พฤศจิกายน',
  'ธันวาคม',
];

class DateFilterPopup {
  final String title;
  final String buttonLabel;
  final void Function(DateTime? dateFrom, DateTime? dateTo)? onSubmit;
  final bool backButton;
  final DateTime? currentDateFrom;
  final DateTime? currentDateTo;
  final DateTime? allowDateFrom;
  final DateTime? allowDateTo;
  final double maxHeight;
  final double minHeight;
  final FlexFit fit;


  DateFilterPopup({
    this.title = 'ตัวกรอง',
    this.buttonLabel = 'บันทึก',
    this.onSubmit,
    this.backButton = true,
    this.currentDateFrom,
    this.currentDateTo,
    this.allowDateFrom,
    this.allowDateTo,
    this.maxHeight = 700,
    this.minHeight = 0,
    this.fit = FlexFit.tight,
  });

  void showPopup(BuildContext context) {

    DateTime? rangeStart = currentDateFrom;
    DateTime? rangeEnd = currentDateTo;

    PushPopup(
      title: title,
      buttonLabel: buttonLabel,
      minHeight: minHeight,
      maxHeight: maxHeight,
      fit: fit,
      buttonAction: (context) {
        Navigator.of(context).pop();
        onSubmit?.call(rangeStart, rangeEnd);
      },
      builder: (context) => DateSelectorFilter(
        currentDateFrom: currentDateFrom,
        currentDateTo: currentDateTo,
        allowDateFrom: allowDateFrom,
        allowDateTo: allowDateTo,
        onSelect: (start, end) {
          rangeStart = start;
          rangeEnd = end;
        },
      )
    ).showPopup(context);
  }

}


class DateSelectorFilter extends StatefulWidget {

  final DateTime? currentDateFrom;
  final DateTime? currentDateTo;
  final DateTime? allowDateFrom;
  final DateTime? allowDateTo;
  final void Function(DateTime? dateFrom, DateTime? dateTo) onSelect;

  const DateSelectorFilter({
    super.key,
    this.currentDateFrom,
    this.currentDateTo,
    this.allowDateFrom,
    this.allowDateTo,
    required this.onSelect,
  });

  @override
  State<StatefulWidget> createState() => DateSelectorFilterState();
}

class DateSelectorFilterState extends State<DateSelectorFilter> {

  /// สลับปีแล้วดันเดือนให้อยู่ในช่วงที่อนุญาต
  ///
  /// 🚩 (2026-08-27) logic นี้เดิมเขียนอยู่ใน onTap ของเมนู พอเพิ่มทาง
  /// `<select>` บนเว็บเข้ามาก็ต้องใช้ร่วมกันทั้งสองทาง จึงดึงออกมาเป็นเมธอด
  /// ไม่งั้นแก้ที่เดียวแล้วอีกทางจะเพี้ยน
  void _selectYear(int year) {
    final maxDate = allowDateTo ?? DateTime(DateTime.now().year + 100);
    final minDate = allowDateFrom ?? DateTime(DateTime.now().year - 100);

    int month = _focusedDay.month;
    if (year == maxDate.year && month > maxDate.month) month = maxDate.month;
    if (year == minDate.year && month < minDate.month) month = minDate.month;

    _focusedDay = DateTime(year, month);
  }


  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  DateTime? allowDateFrom;
  DateTime? allowDateTo;



  int selectedMonthIndex = 0;
  int selectedYearIndex = 0;

  String focused = '';
  List<String> years = [];



  DateTime _initialFocusedDay() {
    final now = DateTime.now();

    if (allowDateTo != null && allowDateTo!.isBefore(now)) {
      return allowDateTo!;
    }

    if (allowDateFrom != null && allowDateFrom!.isAfter(now)) {
      return allowDateFrom!;
    }

    return widget.currentDateFrom ?? now;
  }

  List<int> getMonthOfYear(int yearIndex) {
    return [
      for (int i = ((allowDateFrom?.year ?? DateTime.now().year) == int.parse(years[yearIndex])) ? (allowDateFrom?.month ?? DateTime.now().month) - 1 : 0 ; i <= (((allowDateTo?.year ?? DateTime.now().year) == int.parse(years[yearIndex])) ? (allowDateTo?.month ?? DateTime.now().month) - 1 : 11); i++)
        i
    ];
  }

  List<String> getYears() {
    return [
      for (int i = (allowDateFrom?.year ?? DateTime.now().year); i <= (allowDateTo?.year ?? DateTime.now().year); i++)
        i.toString()
    ];
  }

  final MenuController _monthController = MenuController();
  final MenuController _yearController = MenuController();

  @override
  void initState() {
    super.initState(); // Always call super.initState() first

    _rangeStart = widget.currentDateFrom;
    _rangeEnd = widget.currentDateTo;
    allowDateFrom = widget.allowDateFrom;
    allowDateTo = widget.allowDateTo;

    _focusedDay = _initialFocusedDay();

    // 1. Generate the years list first
    years.addAll(getYears());

    // 2. Calculate initial indices if currentDateFrom exists
    if (_rangeStart != null) {
      // Find index of the year
      final yearStr = _rangeStart!.year.toString();
      final yearIdx = years.indexOf(yearStr);

      if (yearIdx != -1) {
        selectedYearIndex = yearIdx;

        // Find index of the month within that specific year's month list
        final monthsInThatYear = getMonthOfYear(selectedYearIndex);
        final monthIdx = monthsInThatYear.indexOf(_rangeStart!.month - 1);

        if (monthIdx != -1) {
          selectedMonthIndex = monthIdx;
        }
      }
    } else {
      // Fallback: If no date is selected, you might want to point
      // the wheels to the current year/month if they exist in the range
      final now = DateTime.now();
      final yearIdx = years.indexOf(now.year.toString());
      if (yearIdx != -1) {
        selectedYearIndex = yearIdx;
        final months = getMonthOfYear(selectedYearIndex);
        final monthIdx = months.indexOf(now.month - 1);
        selectedMonthIndex = monthIdx != -1 ? monthIdx : 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 13,
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: Text(
                      'ล้าง',
                      style: TextStyle(
                          color: Color(0xFF626262),
                          fontSize: 17
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _rangeStart = null;
                        _rangeEnd = null;
                      });

                      widget.onSelect(_rangeStart, _rangeEnd);
                    },
                  )
                ],
              ),
            ),
            SeparatorCard(
              children: [
                Column(
                  children: [
                    IconTextValueButton(
                      icon: 'budget_year.svg',
                      label: 'เลือกเดือน',
                      value: _rangeStart == null ? '---' : '${month[getMonthOfYear(selectedYearIndex)[selectedMonthIndex]]} ${int.parse(years[selectedYearIndex])+543}',
                      onPressed: () {
                        setState(() {
                          focused = (focused != 'select-month') ? 'select-month' : '';
                        });
                      },
                    ),
                    AnimatedSizeWidget(
                        enable: focused == 'select-month',
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                              child: Divider(height: 0),
                            ),
                            WheelSelector(
                                height: 150,
                                rightItems: getMonthOfYear(selectedYearIndex)
                                    .map<String>((i) => month[i])
                                    .toList(),
                                refreshRight: true,
                                looping: false,
                                leftItems: years.map((m) => (int.parse(m) + 543).toString()).toList(),
                                initialLeftIndex: selectedYearIndex,
                                initialRightIndex: selectedMonthIndex,
                                onChanged: (left, right) {
                                  setState(() {
                                    if (selectedYearIndex != left) {
                                      selectedYearIndex = left;
                                      selectedMonthIndex = 0;
                                    } else {
                                      selectedMonthIndex = right ?? 0;
                                    }

                                    _rangeStart = DateTime(int.parse(years[selectedYearIndex]), getMonthOfYear(selectedYearIndex)[selectedMonthIndex] + 1, 1);
                                    _rangeEnd = DateTime(int.parse(years[selectedYearIndex]), getMonthOfYear(selectedYearIndex)[selectedMonthIndex] + 2, 0);

                                    _focusedDay = _rangeStart!;

                                    widget.onSelect(_rangeStart, _rangeEnd);
                                  });
                                }
                            ),
                          ],
                        )
                    )
                  ],
                ),
                Column(
                  children: [
                    TextButton(
                      label: 'เลือกช่วงเวลา',
                      onPressed: () {
                        setState(() {
                          focused = (focused != 'select-length') ? 'select-length' : '';
                        });
                      },
                    ),
                    AnimatedSizeWidget(
                        enable: focused == 'select-length',
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                              child: Divider(height: 0),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22)
                                ),
                                child: TableCalendar(
                                  calendarBuilders: CalendarBuilders(
                                      headerTitleBuilder: (context, focusedMonth) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          spacing: 15,
                                          children: [
                                            Expanded(
                                              child: NativeSelect(
                                                options: [
                                                  for (int i = ((allowDateFrom?.year ?? DateTime.now().year - 100) == _focusedDay.year) ? (allowDateFrom?.month ?? 1) - 1 : 0; i <= (((allowDateTo?.year ?? DateTime.now().year) == _focusedDay.year) ? (allowDateTo?.month ?? DateTime.now().month) - 1 : 11); i++)
                                                    ('$i', month[i]),
                                                ],
                                                value: '${_focusedDay.month - 1}',
                                                onChanged: (v) => setState(() {
                                                  _focusedDay = DateTime(
                                                      _focusedDay.year, int.parse(v) + 1);
                                                }),
                                                fallback: MenuAnchor(
                                                controller: _monthController,
                                                builder: (context, controller, child) {
                                                  return InkWell(
                                                      onTap: () => controller.open(),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: BoxBorder.all(
                                                              color: Colors.grey,
                                                              strokeAlign: BorderSide.strokeAlignOutside
                                                          ),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        padding: EdgeInsets.all(8),
                                                        child: Text(DateFormat.MMMM('th_TH').format(focusedMonth)),
                                                      )
                                                  );
                                                },
                                                style: IosMenu.menuStyle,
                                                menuChildren: [
  IosMenu(
    width: 200,
    maxHeight: 400,
    children: [

                                                                    for (int i = ((allowDateFrom?.year ?? DateTime.now().year - 100) == _focusedDay.year) ? (allowDateFrom?.month ?? 1) - 1 : 0 ; i <= (((allowDateTo?.year ?? DateTime.now().year) == _focusedDay.year) ? (allowDateTo?.month ?? DateTime.now().month) - 1 : 11); i++)
                                                                      IosMenuItem(
                                                                        label: month[i],
                                                                        onTap: () {
                                                                          setState(() {
                                                                            _monthController.close();
                                                                            _focusedDay = DateTime(
                                                                                focusedMonth.year, i + 1
                                                                            );
                                                                          });
                                                                        },
                                                                      ),

                                                                    // ...month.map((m) {
                                                                    //   return IosMenuItem(
                                                                    //     arrow: false,
                                                                    //     label: m['name'],
                                                                    //     onTap: () {
                                                                    //       setState(() {
                                                                    //         _monthController.close();
                                                                    //         _focusedDay = DateTime(focusedMonth.year, m['index']+1);
                                                                    //       });
                                                                    //     },
                                                                    //   );
                                                                    // })
                                                                  ],
  ),
],
                                              ),
                                              ),
                                            ),
                                            Expanded(
                                              child: NativeSelect(
                                                options: [
                                                  for (int i = (allowDateTo?.year ?? DateTime.now().year); i >= (allowDateFrom?.year ?? DateTime.now().year - 100); i--)
                                                    ('$i', (i + 543).toString()),
                                                ],
                                                value: '${_focusedDay.year}',
                                                onChanged: (v) =>
                                                    setState(() => _selectYear(int.parse(v))),
                                                fallback: MenuAnchor(
                                                controller: _yearController,
                                                builder: (context, controller, child) {
                                                  return InkWell(
                                                      onTap: () => controller.open(),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: BoxBorder.all(
                                                              color: Colors.grey,
                                                              strokeAlign: BorderSide.strokeAlignOutside
                                                          ),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        padding: EdgeInsets.all(8),
                                                        child: Text('${num.parse(DateFormat.y('th_TH').format(focusedMonth)) + 543}'),
                                                      )
                                                  );
                                                },
                                                style: IosMenu.menuStyle,
                                                menuChildren: [
  IosMenu(
    width: 200,
    maxHeight: 400,
    children: [
                                                                    for (int i = (allowDateTo?.year ?? DateTime.now().year); i >= (allowDateFrom?.year ?? DateTime.now().year - 100); i--)
                                                                      IosMenuItem(
                                                                        label: (i + 543).toString(),
                                                                        onTap: () {
                                                                          setState(() {
                                                                            _yearController.close();

                                                                            final maxDate = allowDateTo ?? DateTime(DateTime.now().year + 100);
                                                                            final minDate = allowDateFrom ?? DateTime(DateTime.now().year - 100);

                                                                            int month = _focusedDay.month;

                                                                            // If selected year is max year → clamp upper month
                                                                            if (i == maxDate.year && month > maxDate.month) {
                                                                              month = maxDate.month;
                                                                            }

                                                                            // If selected year is min year → clamp lower month
                                                                            if (i == minDate.year && month < minDate.month) {
                                                                              month = minDate.month;
                                                                            }

                                                                            _focusedDay = DateTime(i, month);
                                                                          });
                                                                        },
                                                                      ),
                                                                  ],
  ),
],
                                              ),
                                              ),
                                            )
                                          ],
                                        );
                                      }
                                  ),
                                  //enabledDayPredicate: (day) => (allowDateFrom == null || !day.isBefore(allowDateFrom!)) && (allowDateTo == null || !day.isAfter(allowDateTo!)),
                                  locale: 'th_TH',
                                  firstDay: allowDateFrom ?? DateTime(DateTime.now().year - 100, 1, 1),
                                  lastDay: allowDateTo ?? DateTime(DateTime.now().year + 100, 12, 31),
                                  focusedDay: _focusedDay,
                                  rangeStartDay: _rangeStart,
                                  rangeEndDay: _rangeEnd,
                                  rangeSelectionMode: RangeSelectionMode.enforced,
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                  ),
                                  onRangeSelected: (start, end, focusedDay) {
                                    if (start == null) return;

                                    setState(() {
                                      _rangeStart = start;
                                      _rangeEnd = end ?? start;
                                      _focusedDay = focusedDay;

                                      // ✅ 1. หา year index ใหม่
                                      selectedYearIndex =
                                          years.indexOf(start.year.toString());

                                      // ✅ 2. หา month list ของปีนั้น
                                      final monthsOfYear =
                                      getMonthOfYear(selectedYearIndex);

                                      // ✅ 3. หา index ของเดือนจริงใน list นั้น
                                      selectedMonthIndex =
                                          monthsOfYear.indexOf(start.month - 1);
                                    });

                                    widget.onSelect(_rangeStart, _rangeEnd);
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

                                    todayDecoration: BoxDecoration(
                                      color: Colors.transparent, // ทำให้โปร่งใส
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
                                )
                            ),
                          ],
                        )
                    )
                  ],
                )
              ],
            ),
          ],
        ),
        Container(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                    child: Row(
                      spacing: 10,
                      children: [
                        SvgPicture.asset('assets/images/calendar_in.svg'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ตั้งแต่วันที่',
                              style: TextStyle(
                                  color: Color(0xFF626262)
                              ),
                            ),
                            Text(
                              (_rangeStart != null) ? '${DateFormat.MMMd('th_TH').format(_rangeStart!)} ${num.parse(DateFormat.y('th_TH').format(_rangeStart!)) + 543}' : '---',
                              style: TextStyle(
                                  fontSize: 14
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                ),
                Container(width: 1.5, height: 40, color: Color(0xFFB1B1B1)),
                Expanded(
                    child: Row(
                      spacing: 10,
                      children: [
                        SvgPicture.asset('assets/images/calendar_out.svg'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ถึงวันที่',
                              style: TextStyle(
                                  color: Color(0xFF626262)
                              ),
                            ),
                            Text(
                              (_rangeEnd != null) ? '${DateFormat.MMMd('th_TH').format(_rangeEnd!)} ${num.parse(DateFormat.y('th_TH').format(_rangeEnd!)) + 543}' : '---',
                              style: TextStyle(
                                  fontSize: 14
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                )
              ],
            )
        ),
        /*SeparatorCard(
          separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
          children: [
            IconTextValueButton(
                icon: 'calendar_in.svg',
                label: 'จากวันที่',
                arrow: false,
                value: (_rangeStart != null) ? '${DateFormat.MMMd('th_TH').format(_rangeStart!)} ${num.parse(DateFormat.y('th_TH').format(_rangeStart!)) + 543}' : '---'
            ),
            IconTextValueButton(
                icon: 'calendar_out.svg',
                label: 'ถึงวันที่',
                arrow: false,
                value: (_rangeEnd != null) ? '${DateFormat.MMMd('th_TH').format(_rangeEnd!)} ${num.parse(DateFormat.y('th_TH').format(_rangeEnd!)) + 543}' : '---'
            ),
          ],
        ),*/
      ],
    );
  }

}