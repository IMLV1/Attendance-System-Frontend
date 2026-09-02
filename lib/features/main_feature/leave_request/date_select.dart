import 'package:attendance_system/shared/widgets/utils/animation/animated_widget.dart';
import 'package:attendance_system/shared/widgets/utils/ios_menu.dart';
import 'package:attendance_system/shared/widgets/utils/native_select/native_select.dart';
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

  /// ขอบเขตที่ปฏิทินยอมรับ — ต้องเป็นค่าเดียวกับ `firstDay`/`lastDay` ของ
  /// TableCalendar ข้างล่าง
  DateTime get _firstDay => widget.budgetStart ?? DateTime(2000);
  DateTime get _lastDay => widget.budgetEnd ?? DateTime(2100);

  /// 🚩 (2026-08-27) ตัวเลือกเดือน/ปีเคยเสนอค่านอกขอบเขตปฏิทิน
  ///
  /// รายการปีถูกเขียนตายไว้ว่า `now.year - 1` ถึง `+10` ตั้งแต่ตอนที่ปฏิทินยัง
  /// ไม่จำกัดช่วง พอเพิ่มการล็อกให้อยู่ในปีงบประมาณ (`firstDay`/`lastDay`)
  /// รายการก็ไม่ได้ตามไปด้วย — เลือกปีที่เกิน `lastDay` แล้ว TableCalendar
  /// assert แตกทันที (`isSameDay(focusedDay, lastDay) || focusedDay.isBefore(lastDay)`)
  /// หน้าจอกลายเป็นแดงทั้งหน้า
  ///
  /// แก้สองชั้น: ไม่เสนอค่าที่เลือกไม่ได้ตั้งแต่แรก และ clamp กันไว้อีกชั้น
  /// เผื่อมีทางอื่นมาตั้งค่าผิดช่วง
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

  // ───────── ครึ่งวันที่ถูกจองไปแล้ว ─────────
  //
  // 🚩 (2026-09-02) ปฏิทินเดิมปิดได้แค่วันที่ "เต็มทั้งสองครึ่ง" (isFull) วันที่
  // จองไว้ครึ่งเดียวจึงเลือกเป็นเต็มวันได้ แล้วไปโดน 409 ตอนกดส่ง — และก่อนถึง
  // ตรงนั้นพรีวิว "คำขอนี้จะใช้สิทธิ์ N วัน" ก็ขึ้นเลขผิดด้วย เพราะ
  // /calculate_days ไม่รู้จักใบลาเดิมของผู้ใช้เลย (ไม่มีพารามิเตอร์ user)
  //
  // กติกาที่ backend ใช้จริง (CheckOverlappingLeave) แปลเป็นเงื่อนไขฝั่งหน้าจอ:
  //   วันเดียว     — ครึ่งที่เลือกต้องว่าง
  //   หลายวัน      — วันแรกใช้ตั้งแต่ครึ่งที่เลือกถึงสิ้นวัน (บ่ายต้องว่างเสมอ)
  //                  วันสุดท้ายใช้ตั้งแต่เช้าถึงครึ่งที่เลือก (เช้าต้องว่างเสมอ)
  //                  วันที่อยู่ตรงกลางลาเต็มวัน ต้องว่างทั้งสองครึ่ง
  bool get _startMorningTaken =>
      _rangeStart != null && widget.occupiedDates.isMorningTaken(_rangeStart!);

  bool get _startAfternoonTaken =>
      _rangeStart != null && widget.occupiedDates.isAfternoonTaken(_rangeStart!);

  bool get _endMorningTaken =>
      _rangeEnd != null && widget.occupiedDates.isMorningTaken(_rangeEnd!);

  bool get _endAfternoonTaken =>
      _rangeEnd != null && widget.occupiedDates.isAfternoonTaken(_rangeEnd!);

  /// ช่วงนี้ชนใบลาเดิมแบบที่แก้ด้วยการสลับครึ่งวันไม่ได้หรือเปล่า
  bool _rangeHasConflict(DateTime start, DateTime end) {
    if (isSameDay(start, end)) return false;

    // วันแรกใช้ถึงสิ้นวันเสมอ / วันสุดท้ายใช้ตั้งแต่เช้าเสมอ
    if (widget.occupiedDates.isAfternoonTaken(start)) return true;
    if (widget.occupiedDates.isMorningTaken(end)) return true;

    // วันตรงกลางลาเต็มวันเสมอ จึงต้องว่างทั้งสองครึ่ง
    for (var d = start.add(const Duration(days: 1));
        d.isBefore(DateTime(end.year, end.month, end.day));
        d = d.add(const Duration(days: 1))) {
      if (widget.occupiedDates.isPartlyTaken(d)) return true;
    }
    return false;
  }

  /// ดันครึ่งวันไปอยู่ครึ่งที่ยังว่างจริง — เรียกทุกครั้งที่ช่วงวันเปลี่ยน
  void _clampHalves() {
    if (_startMorningTaken) _fromDateMorning = false;
    if (_startAfternoonTaken) _fromDateMorning = true;
    if (_endAfternoonTaken) _toDateMorning = true;
    if (_endMorningTaken) _toDateMorning = false;
  }

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
                                                _focusedDay = _clamp(
                                                    DateTime(focusedMonth.year, m['index'] + 1));
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
                            for (int y = _firstDay.year; y <= _lastDay.year; y++)
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
                                              for (int y = _firstDay.year; y <= _lastDay.year; y++)
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
              final s = start;
              final e = end ?? start;

              // ปฏิทินยอมให้ "ลาก" คร่อมวันที่ปิดอยู่ได้ (enabledDayPredicate กันได้
              // แค่การแตะเลือก) จึงต้องตรวจทั้งช่วงอีกชั้น
              //
              // ไม่ขึ้นข้อความเตือน — วันที่ลาไปแล้วถูกทำเป็นสีจางในปฏิทินอยู่แล้ว
              // ผู้ใช้เห็นเองว่าทำไมช่วงถึงไม่ขยับ (ตกลงกันแล้ว 2026-09-02)
              if (s != null && e != null && _rangeHasConflict(s, e)) {
                setState(() => _focusedDay = focusedDay);
                return; // คงช่วงเดิมไว้ ส่งไปก็โดนปฏิเสธอยู่ดี
              }

              setState(() {
                _rangeStart = s;
                _rangeEnd = e;
                _focusedDay = focusedDay;
                _clampHalves();
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
                                // ใช้ค่าใน state ไม่ใช่ prop ที่ส่งเข้ามาตอนแรก —
                                // ครึ่งวันถูกบังคับเปลี่ยนได้จาก _clampHalves()
                                isFirst: _fromDateMorning,
                                disableFirst: _startMorningTaken,
                                disableSecond: _startAfternoonTaken,
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
                                isFirst: _toDateMorning,
                                disableFirst: _endMorningTaken,
                                disableSecond: _endAfternoonTaken,
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
  bool isFull(DateTime day) => isMorningTaken(day) && isAfternoonTaken(day);

  /// 🚩 (2026-09-02) เปิดข้อมูลระดับ "ครึ่งวัน" ออกมาใช้
  ///
  /// เดิมมีแต่ [isFull] ปฏิทินจึงรู้แค่ว่าวันนั้นเต็มหรือยัง แต่ไม่รู้ว่า
  /// **เหลือครึ่งไหน** — วันที่จองบ่ายไว้แล้วยังเลือกเป็น "เต็มวัน" ได้อยู่
  /// ซึ่ง backend จะตอบ 409 ตอนกดส่ง (ดู CheckOverlappingLeave)
  bool isMorningTaken(DateTime day) => _slots.contains(_dayIndex(day) * 2);

  bool isAfternoonTaken(DateTime day) => _slots.contains(_dayIndex(day) * 2 + 1);

  /// มีครึ่งใดครึ่งหนึ่งถูกจองแล้ว — ใช้กับ "วันที่อยู่กลางช่วง" ซึ่งถูกลาเต็มวัน
  /// เสมอ จึงต้องว่างทั้งสองครึ่ง
  bool isPartlyTaken(DateTime day) => isMorningTaken(day) || isAfternoonTaken(day);

  bool get isEmpty => _slots.isEmpty;
}
