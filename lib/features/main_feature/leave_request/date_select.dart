import 'package:attendance_system/shared/widgets/utils/animation/animated_widget.dart';
import 'package:attendance_system/shared/widgets/utils/ios_menu.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/text_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


class DateSelect extends StatefulWidget {

  final bool allowRetroactive;
  final LeaveDate? dateData;
  final void Function(LeaveDate date) onChanged;

  // 🚩 เพิ่ม (2026-08-13): ขอบเขตปีงบประมาณปัจจุบัน — ยื่นลาได้เฉพาะในช่วงนี้เท่านั้น
  // (backend บังคับด้วย ดู ValidateLeaveWithinCurrentBudgetYear) ถ้าเป็น null จะไม่จำกัด
  // เพื่อไม่ให้หน้าพังตอนดึง config ไม่สำเร็จ — backend ยังเป็นด่านสุดท้ายอยู่ดี
  final DateTime? budgetStart;
  final DateTime? budgetEnd;

  /// วันที่ผู้ใช้ลาไปแล้ว — ปิดไม่ให้เลือกซ้ำ (ดู [OccupiedLeaveDates])
  final OccupiedLeaveDates occupiedDates;

  const DateSelect({
    super.key,
    required this.allowRetroactive,
    this.dateData,
    required this.onChanged,
    this.budgetStart,
    this.budgetEnd,
    this.occupiedDates = const OccupiedLeaveDates.empty(),
  });

  @override
  State<StatefulWidget> createState() {
    return _DateSelectState();
  }
}

class _DateSelectState extends State<DateSelect> {

  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _fromDateMorning = true;
  bool _toDateMorning = false;

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

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.dateData?.fromDate ?? DateTime.now();
    _rangeStart = widget.dateData?.fromDate;
    _rangeEnd = widget.dateData?.toDate;
    _fromDateMorning = widget.dateData?.fromDateMorning ?? true;
    _toDateMorning = widget.dateData?.toDateMorning ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 13,
      children: [
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
                      child: MenuAnchor(
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
                                        ...month.map((m) {
                                          return IosMenuItem(
                                            label: m['name'],
                                            onTap: () {
                                              setState(() {
                                                _monthController.close();
                                                _focusedDay = DateTime(focusedMonth.year, m['index']+1);
                                              });
                                            },
                                          );
                                        })
                                      ],
  ),
],
                      ),
                    ),
                    Expanded(
                      child: MenuAnchor(
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
                                              for (int i = -1; i <= 10; i++)
                                                IosMenuItem(
                                                  label: (DateTime.now().year + 543 + i).toString(),
                                                  onTap: () {
                                                    setState(() {
                                                      _yearController.close();
                                                      _focusedDay = DateTime(
                                                          DateTime.now().year + i, focusedMonth.month
                                                      );
                                                    });
                                                  },
                                                ),
                                            ],
  ),
],
                        ),
                    )
                  ],
                );
              }
            ),
            enabledDayPredicate: (day) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day + 1);

              // ต้องอยู่ในปีงบประมาณปัจจุบันเสมอ (ถ้ารู้ขอบเขต)
              final d = DateTime(day.year, day.month, day.day);
              if (widget.budgetStart != null && d.isBefore(widget.budgetStart!)) return false;
              if (widget.budgetEnd != null && d.isAfter(widget.budgetEnd!)) return false;

              // 🚩 (2026-08-26) วันที่ลาไปแล้ว "เต็มวัน" ปิดตั้งแต่ต้นทาง
              // เดิมเลือกได้หมด แล้วค่อยโดน backend ตอบ 409 ตอนกดส่ง (หลังเซ็นชื่อ
              // ไปแล้วด้วย) — รู้ได้ตั้งแต่แรกก็ควรบอกตั้งแต่แรก
              //
              // วันที่ลาไว้แค่ครึ่งเดียวยังปล่อยให้เลือก เพราะยื่นอีกครึ่งได้จริง
              if (widget.occupiedDates.isFull(d)) return false;

              return (widget.allowRetroactive) ? true : day.isAfter(
                DateTime(today.year, today.month, today.day),
              );
            },
            locale: 'th_TH',
            firstDay: widget.budgetStart ?? DateTime(2000),
            lastDay: widget.budgetEnd ?? DateTime(2100),
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
                LeaveDate(
                  fromDate: _rangeStart,
                  toDate: _rangeEnd,
                  fromDateMorning: _fromDateMorning,
                  toDateMorning: _toDateMorning,
                )
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
          separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
          children: [
            Column(
              children: [
                IconTextValueButton(
                  icon: 'calendar_in.svg',
                  label: 'จากวันที่',
                  arrow: false,
                  value: (_rangeStart != null) ? '${DateFormat.MMMd('th_TH').format(_rangeStart!)} ${num.parse(DateFormat.y('th_TH').format(_rangeStart!)) + 543}' : '---'
                ),
                AnimatedSizeWidget(
                  enable: _rangeStart != null,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.only(left: 45, right: 15),
                        child: Divider(height: 0),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            spacing: 10,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,

                              ),
                              Expanded(
                                child: Text(
                                    'ช่วงครึ่งวัน',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    )
                                ),
                              ),

                              TextToggleSwitch(
                                isFirst: widget.dateData?.fromDateMorning ?? true,
                                onChanged: (bool isFirst) {
                                  setState(() {
                                    _fromDateMorning = isFirst;
                                  });

                                  widget.onChanged(
                                      LeaveDate(
                                        fromDate: _rangeStart,
                                        toDate: _rangeEnd,
                                        fromDateMorning: _fromDateMorning,
                                        toDateMorning: _toDateMorning,
                                      )
                                  );
                                },
                                label1: 'เช้า',
                                label2: 'เย็น',
                                color: Color(0xFF4986FF),
                              ),
                            ],
                          )
                      )
                    ],
                  )
                )
              ],
            )
          ],
        ),
        SeparatorCard(
          separatorPadding: EdgeInsetsGeometry.only(left: 45, right: 15),
          children: [
            Column(
              children: [
                IconTextValueButton(
                    icon: 'calendar_out.svg',
                    label: 'ถึงวันที่',
                    arrow: false,
                    value: (_rangeEnd != null) ? '${DateFormat.MMMd('th_TH').format(_rangeEnd!)} ${num.parse(DateFormat.y('th_TH').format(_rangeEnd!)) + 543}' : '---'
                ),
                AnimatedSizeWidget(
                  enable: _rangeEnd != null,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.only(left: 45, right: 15),
                        child: Divider(height: 0)
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            spacing: 10,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,

                              ),
                              Expanded(
                                child: Text(
                                    'ช่วงครึ่งวัน',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    )
                                ),
                              ),
                              TextToggleSwitch(
                                isFirst: widget.dateData?.toDateMorning ?? false,
                                onChanged: (bool isFirst) {

                                  setState(() {
                                    _toDateMorning = isFirst;
                                  });

                                  widget.onChanged(
                                      LeaveDate(
                                        fromDate: _rangeStart,
                                        toDate: _rangeEnd,
                                        fromDateMorning: _fromDateMorning,
                                        toDateMorning: _toDateMorning,
                                      )
                                  );
                                },
                                label1: 'เช้า',
                                label2: 'เย็น',
                                color: Color(0xFF4986FF),
                              )
                            ],
                          )
                      )
                    ],
                  )
                )
              ],
            )
          ],
        )
      ],
    );
  }
}

class LeaveDate {

  final DateTime? fromDate;
  final DateTime? toDate;

  final bool fromDateMorning;
  final bool toDateMorning;

  const LeaveDate({this.fromDate, this.toDate, this.fromDateMorning = true, this.toDateMorning = false});
}
/// วันที่ผู้ใช้ลาไปแล้ว แปลงมาจาก `GET /leave_request/occupied_dates`
///
/// 🚩 (2026-08-26) ใช้เกณฑ์ "ช่องครึ่งวัน" ชุดเดียวกับ `CheckOverlappingLeave`
/// ฝั่ง backend เป๊ะๆ — เช้า = ช่องคู่, บ่าย = ช่องคี่ ถ้าสองที่นี้หลุดจากกันเมื่อไหร่
/// ปฏิทินจะปิดวันไม่ตรงกับที่ backend ยอมรับจริง ซึ่งงงกว่าไม่ปิดเลย
///
/// ปิดเฉพาะวันที่ **เต็มทั้งสองครึ่ง** เท่านั้น วันที่ลาไว้แค่ครึ่งเดียวยังเลือกได้
/// เพราะยื่นอีกครึ่งได้จริง (ตกลงกันแล้วว่าลาเช้า+ลาบ่ายวันเดียวกันคนละใบควรได้)
class OccupiedLeaveDates {

  /// ช่องครึ่งวันที่ถูกจองแล้ว นับจาก 1970-01-01 (วัน * 2 + 0 เช้า / 1 บ่าย)
  final Set<int> _slots;

  const OccupiedLeaveDates._(this._slots);

  const OccupiedLeaveDates.empty() : _slots = const {};

  static const _epoch = 1970;

  static int _dayIndex(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day)
          .difference(DateTime.utc(_epoch, 1, 1))
          .inDays;

  factory OccupiedLeaveDates.fromJson(dynamic data) {
    final list = (data is Map ? data['data'] : data);
    if (list is! List) return const OccupiedLeaveDates.empty();

    final slots = <int>{};
    for (final item in list) {
      if (item is! Map) continue;

      final from = DateTime.tryParse('${item['date-from']}');
      final to = DateTime.tryParse('${item['date-to']}');
      if (from == null || to == null) continue;

      final fromMorning = item['from-date-morning'] == true;
      final toMorning = item['to-date-morning'] == true;

      final start = _dayIndex(from) * 2 + (fromMorning ? 0 : 1);
      final end = _dayIndex(to) * 2 + (toMorning ? 0 : 1);
      if (end < start) continue;

      for (var s = start; s <= end; s++) {
        slots.add(s);
      }
    }
    return OccupiedLeaveDates._(slots);
  }

  /// วันนี้ถูกจองไปแล้วทั้งวัน (ทั้งเช้าและบ่าย) หรือยัง
  bool isFull(DateTime day) {
    final i = _dayIndex(day) * 2;
    return _slots.contains(i) && _slots.contains(i + 1);
  }

  bool get isEmpty => _slots.isEmpty;
}
