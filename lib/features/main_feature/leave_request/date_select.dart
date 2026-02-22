import 'package:attendance_system/shared/widgets/utils/animation/animated_widget.dart';
import 'package:attendance_system/shared/widgets/utils/icon_text_value_button.dart';
import 'package:attendance_system/shared/widgets/utils/separator_card.dart';
import 'package:attendance_system/shared/widgets/utils/text_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../shared/widgets/utils/text_button.dart' as utils;

class DateSelect extends StatefulWidget {

  final bool allowRetroactive;
  final LeaveDate? dateData;
  final void Function(LeaveDate date) onChanged;

  const DateSelect({super.key, required this.allowRetroactive, this.dateData, required this.onChanged});

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
                        clipBehavior: Clip.none,
                        style: const MenuStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                          elevation: WidgetStatePropertyAll(0),
                        ),
                        menuChildren: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: child,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 100,
                                    spreadRadius: 6,
                                    offset: Offset.zero,
                                  ),
                                ],
                              ),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: 400,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: SizedBox(
                                  width: 200,
                                  child: SingleChildScrollView(
                                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                    primary: false,
                                    child: SeparatorCard(
                                      borderRadius: BorderRadius.circular(0),
                                      children: [
                                        ...month.map((m) {
                                          return utils.TextButton(
                                            arrow: false,
                                            label: m['name'],
                                            onPressed: () {
                                              setState(() {
                                                _monthController.close();
                                                _focusedDay = DateTime(focusedMonth.year, m['index']+1);
                                              });
                                            },
                                          );
                                        })
                                      ],
                                    ),
                                  )
                                ),
                              )
                            ),
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
                          clipBehavior: Clip.none,
                          style: const MenuStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                            elevation: WidgetStatePropertyAll(0),
                          ),
                          menuChildren: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: child,
                                );
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.18),
                                        blurRadius: 100,
                                        spreadRadius: 6,
                                        offset: Offset.zero,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 400,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: SizedBox(
                                        width: 200,
                                        child: SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                          primary: false,
                                          child: SeparatorCard(
                                            borderRadius: BorderRadius.circular(0),
                                            children: [
                                              for (int i = -1; i <= 10; i++)
                                                utils.TextButton(
                                                  arrow: false,
                                                  label: (DateTime.now().year + 543 + i).toString(),
                                                  onPressed: () {
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
                                        )
                                    ),
                                  )
                              ),
                            ),
                          ],
                        ),
                    )
                  ],
                );
              }
            ),
            enabledDayPredicate: (day) {
              final today = DateTime.now();
              return (widget.allowRetroactive) ? true : !day.isBefore(
                DateTime(today.year, today.month, today.day),
              );
            },
            locale: 'th_TH',
            firstDay: DateTime(DateTime.now().year - 100 ,1 ,1),
            lastDay: DateTime(DateTime.now().year + 100 ,31 ,12),
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