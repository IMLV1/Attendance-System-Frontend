import 'package:attendance_system/services/time_request/time_request_model.dart';
import 'package:attendance_system/shared/widgets/utils/ios_menu.dart';
import 'package:attendance_system/shared/widgets/utils/native_select/native_select.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../shared/widgets/utils/animation/animated_widget.dart';
import '../../../shared/widgets/utils/separator_card.dart';
import '../../../shared/widgets/utils/wheel_selector.dart';

class TimeRequestPopup extends StatefulWidget {
  final TimeDate? dateData;
  final void Function(TimeDate date) onChanged;

  const TimeRequestPopup({
    super.key,
    this.dateData,
    required this.onChanged
  });

  @override
  State<StatefulWidget> createState() {
    return _TimeRequestPopupState();
  }
}

class _TimeRequestPopupState extends State<TimeRequestPopup> {
  final List<String> hours = List.generate(24, (index) => index.toString().padLeft(2, '0'),);
  final List<String> minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'),);

  DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  /// ขอบเขตที่ปฏิทินยอมรับ — ต้องตรงกับ `firstDay`/`lastDay` ของ TableCalendar
  static final DateTime _firstDay = DateTime(2000);
  static final DateTime _lastDay = DateTime(2100);

  /// 🚩 (2026-08-27) รายการปีเคยไล่ย้อนหลัง 100 ปีจากปีปัจจุบัน (ถึง ~1926)
  /// ทั้งที่ปฏิทินรับตั้งแต่ 2000 เท่านั้น เลือกปีก่อนหน้านั้นแล้ว TableCalendar
  /// assert แตกทันที หน้าจอแดงทั้งหน้า (เจอบั๊กฝาแฝดกันใน date_select.dart
  /// ซึ่งพังคนละทาง — ของนั่นเสนอปีที่ *เกิน* lastDay)
  DateTime _clamp(DateTime d) {
    if (d.isBefore(_firstDay)) return _firstDay;
    if (d.isAfter(_lastDay)) return _lastDay;
    return d;
  }

  /// เดือนที่เลือกได้ในปีที่กำลังดูอยู่
  Iterable<Map<String, dynamic>> _selectableMonths(int year) {
    final from = year == _firstDay.year ? _firstDay.month : 1;
    final to = year == _lastDay.year ? _lastDay.month : 12;
    return month
        .cast<Map<String, dynamic>>()
        .where((m) => m['index'] + 1 >= from && m['index'] + 1 <= to);
  }

  final List<dynamic> month = [
    {'name': 'มกราคม', 'index': 0},
    {'name': 'กุมภาพันธ์', 'index': 1},
    {'name': 'มีนาคม', 'index': 2},
    {'name': 'เมษายน', 'index': 3},
    {'name': 'พฤษภาคม', 'index': 4},
    {'name': 'มิถุนายน', 'index': 5},
    {'name': 'กรกฎาคม', 'index': 6},
    {'name': 'สิงหาคม', 'index': 7},
    {'name': 'กันยายน', 'index': 8},
    {'name': 'ตุลาคม', 'index': 9},
    {'name': 'พฤศจิกายน', 'index': 10},
    {'name': 'ธันวาคม', 'index': 11},
  ];

  final MenuController _monthController = MenuController();
  final MenuController _yearController = MenuController();

  bool onSelect1 = false;
  int? selectedHour1;
  int? selectedMinute1;

  bool onSelect2 = false;
  int? selectedHour2;
  int? selectedMinute2;

  @override
  void initState() {
    super.initState();

    _focusedDay = widget.dateData?.fromDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
    _rangeStart = widget.dateData?.fromDate;
    _rangeEnd = widget.dateData?.toDate;

    selectedHour1 = widget.dateData?.startTime?.hour;
    selectedMinute1 = widget.dateData?.startTime?.minute;

    selectedHour2 = widget.dateData?.endTime?.hour;
    selectedMinute2 = widget.dateData?.endTime?.minute;
  }


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
            calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, focusedMonth) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    spacing: 15,
                    children: [
                      Expanded(
                        child: NativeSelect(
                          options: [
                            for (final m in _selectableMonths(focusedMonth.year))
                              ('${m['index']}', m['name'] as String),
                          ],
                          value: '${focusedMonth.month - 1}',
                          onChanged: (v) => setState(() {
                            _focusedDay = _clamp(
                                DateTime(focusedMonth.year, int.parse(v) + 1));
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
                                              ..._selectableMonths(focusedMonth.year).map((m) {
                                                return IosMenuItem(
                                                  label: m['name'],
                                                  onTap: () {
                                                    setState(() {
                                                      _monthController.close();
                                                      _focusedDay = _clamp(DateTime(focusedMonth.year, m['index'] + 1));
                                                    });
                                                  },
                                                );
                                              })
                                            ],
  ),
],
                        ),
                        ),
                      ),
                      Expanded(
                        child: NativeSelect(
                          options: [
                            for (int y = _lastDay.year; y >= _firstDay.year; y--)
                              ('$y', (y + 543).toString()),
                          ],
                          value: '${focusedMonth.year}',
                          onChanged: (v) => setState(() {
                            _focusedDay =
                                _clamp(DateTime(int.parse(v), focusedMonth.month));
                          }),
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
                                              for (int y = _lastDay.year; y >= _firstDay.year; y--)
                                                IosMenuItem(
                                                  label: (y + 543).toString(),
                                                  onTap: () {
                                                    setState(() {
                                                      _yearController.close();
                                                      _focusedDay = _clamp(
                                                          DateTime(y, focusedMonth.month));
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
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            locale: 'th_TH',
            enabledDayPredicate: (day) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);

              // Return true only for days strictly BEFORE today
              return day.isBefore(today);
            },
            focusedDay: _focusedDay,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: RangeSelectionMode.enforced,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),

            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _rangeStart = start;
                _rangeEnd = end ?? start;
                _focusedDay = focusedDay;
              });

              widget.onChanged(
                TimeDate(
                  fromDate: _rangeStart,
                  toDate: _rangeEnd,
                  startTime: (selectedHour1 != null && selectedMinute1 != null)
                      ? TimeOfDay(
                    hour: selectedHour1!,
                    minute: selectedMinute1!,
                  )
                      : null,
                  endTime: (selectedHour2 != null && selectedMinute2 != null)
                      ? TimeOfDay(
                    hour: selectedHour2!,
                    minute: selectedMinute2!,
                  )
                      : null,
                ),
              );

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
              value: (_rangeStart != null)
                  ? '${DateFormat.MMMd('th_TH').format(_rangeStart!)} ${num.parse(DateFormat.y('th_TH').format(_rangeStart!)) + 543}'
                  : '---',
              disable: true,
              arrow: false,
            ),
            IconTextValueButton(
              icon: 'clock_calendar.svg',
              label: 'ถึงวันที่',
              value: (_rangeEnd != null)
                  ? '${DateFormat.MMMd('th_TH').format(_rangeEnd!)} ${num.parse(DateFormat.y('th_TH').format(_rangeEnd!)) + 543}'
                  : '---',
              disable: true,
              arrow: false,
            )
          ],
        ),

        SeparatorCard(
          separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
          children: [
            Column(
              children: [
                IconTextValueButton(
                  arrow: false,
                  icon: 'check-in-time.svg',
                  label: 'เวลาเข้างาน',
                  value: (selectedHour1 == null || selectedMinute1 == null)
                      ? '--:--'
                      : '${selectedHour1!.toString().padLeft(2, '0')}:${selectedMinute1!.toString().padLeft(2, '0')}',
                  onPressed: () {
                    setState(() {
                      // onSelect1 = (!onSelect1) ? true : false;

                      if (!onSelect1) {
                        onSelect1 = true;
                        onSelect2 = false;
                      } else {
                        onSelect1 = false;
                      }
                    });
                  },
                ),
                AnimatedSizeWidget(
                  enable: onSelect1,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                        child: Divider(height: 0)
                      ),

                      WheelSelector(
                        height: 150,
                        // Data Sources
                        leftItems: hours,
                        rightItems: minutes,

                        // Initial Positions
                        initialLeftIndex: selectedHour1 ?? 0,
                        initialRightIndex: selectedMinute1 ?? 0,

                        // Handle Changes
                        onChanged: (leftIndex, rightIndex) {
                          setState(() {
                            selectedHour1 = leftIndex;
                            selectedMinute1 = rightIndex ?? 0;
                          });

                          widget.onChanged(
                            TimeDate(
                              fromDate: _rangeStart,
                              toDate: _rangeEnd,
                              startTime: (selectedHour1 != null && selectedMinute1 != null)
                                  ? TimeOfDay(
                                hour: selectedHour1!,
                                minute: selectedMinute1!,
                              )
                                  : null,
                              endTime: (selectedHour2 != null && selectedMinute2 != null)
                                  ? TimeOfDay(
                                hour: selectedHour2!,
                                minute: selectedMinute2!,
                              )
                                  : null,
                            ),
                          );

                        },
                      ),
                    ],
                  )
                ),
              ],
            ),

            Column(
              children: [
                IconTextValueButton(
                  arrow: false,
                  icon: 'check-out-time.svg',
                  label: 'เวลาออกงาน',
                  value: (selectedHour2 == null || selectedMinute2 == null)
                      ? '--:--'
                      : '${selectedHour2!.toString().padLeft(2, '0')}:${selectedMinute2!.toString().padLeft(2, '0')}',
                  onPressed: () {
                    setState(() {
                      // onSelect2 = (!onSelect2) ? true : false;

                      if (!onSelect2) {
                        onSelect2 = true;
                        onSelect1 = false;
                      } else {
                        onSelect2 = false;
                      }
                    });
                  },
                ),
                AnimatedSizeWidget(
                  enable: onSelect2,
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                          child: Divider(height: 0)
                      ),

                      WheelSelector(
                        height: 150,
                        // Data Sources
                        leftItems: hours,
                        rightItems: minutes,

                        // Initial Positions
                        initialLeftIndex: selectedHour2 ?? 0,
                        initialRightIndex: selectedMinute2 ?? 0,

                        // Handle Changes
                        onChanged: (leftIndex, rightIndex) {
                          setState(() {
                            selectedHour2 = leftIndex;
                            selectedMinute2 = rightIndex ?? 0;
                          });

                          widget.onChanged(
                            TimeDate(
                              fromDate: _rangeStart,
                              toDate: _rangeEnd,
                              startTime: (selectedHour1 != null && selectedMinute1 != null)
                                  ? TimeOfDay(
                                hour: selectedHour1!,
                                minute: selectedMinute1!,
                              )
                                  : null,
                              endTime: (selectedHour2 != null && selectedMinute2 != null)
                                  ? TimeOfDay(
                                hour: selectedHour2!,
                                minute: selectedMinute2!,
                              )
                                  : null,
                            ),
                          );

                        },
                      ),
                    ],
                  )
                )
              ],
            )
          ],
        ),
      ],
    );
  }
}