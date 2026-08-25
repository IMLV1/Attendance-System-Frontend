import 'dart:math';

import 'package:attendance_system/services/statistic/statistic_model.dart';
import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum StatisticMode {total, week, month, year}

class WorkingHour extends StatefulWidget {

  final WorkingHourModel? workingHour;

  /// 🚩 (Phase 3) บนจอกว้าง `/statistic` ดึงการ์ดสรุปสองใบขึ้นไปรวมแถวเดียวกับ
  /// KPI วันทำงานที่หัวหน้า ส่วนกราฟอยู่ล่างสุด — สองส่วนนี้จึงต้องแยกวางกันได้
  /// เดิมตัวเลขทั้งสี่กระจายอยู่คนละหัวคนละท้ายหน้าเพราะมาจากคนละ model
  final bool showChart;
  final bool showSummary;

  /// โหมดที่เลือกอยู่ (ทั้งหมด / สัปดาห์ / เดือน / ปี)
  ///
  /// ตัวเลขในการ์ดสรุปเปลี่ยนตามปุ่มที่อยู่เหนือกราฟ พอแยกสองส่วนออกจากกันแล้ว
  /// จึงต้องยกสถานะนี้ขึ้นไปให้หน้าถือแทน ทั้งคู่จะได้อ่านค่าจากตัวเดียวกัน
  /// ถ้าไม่ส่งมา (จอแคบ ใช้เป็นก้อนเดียว) ตัวเองเก็บสถานะเหมือนเดิม
  final StatisticMode? mode;
  final ValueChanged<StatisticMode>? onModeChanged;

  const WorkingHour(
    this.workingHour, {
    super.key,
    this.showChart = true,
    this.showSummary = true,
    this.mode,
    this.onModeChanged,
  });

  @override
  State<StatefulWidget> createState() => _WorkingHourState();
}

class _WorkingHourState extends State<WorkingHour> {

  StatisticMode _ownSelection = StatisticMode.total;

  StatisticMode get selection => widget.mode ?? _ownSelection;

  void _selectMode(StatisticMode mode) {
    final notify = widget.onModeChanged;
    if (notify != null) {
      notify(mode);
    } else {
      setState(() => _ownSelection = mode);
    }
  }

  int touchedIndex = -1;

  /// จำนวนแท่งของรอบวาดก่อนหน้า — ใช้ตัดสินใจว่าจะเปิด animation ไหม
  /// (ดูเหตุผลใน [_barChart])
  int? _prevBarCount;

  @override
  Widget build(BuildContext context) {

    return Column(
      spacing: 6,
      children: [
        /// Title
        if (widget.showChart)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            spacing: 6,
            children: [
              SvgPicture.asset(
                'assets/images/working_hour.svg', // อย่าลืมเช็คชื่อไฟล์ icon นะครับ
                width: 16,
                height: 16,
              ),
              Text(
                'ชั่วโมงทำงาน',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.blackTextColor,
                ),
              ),
            ],
          ),
        ),

        Column(
          spacing: 13,
          children: [
            /// Content
            if (widget.showChart)
            Container(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 20),
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                spacing: 50,
                children: [
                  /// Selection Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _selectionButton(
                          text: 'ทั้งหมด',
                          selected: selection == StatisticMode.total,
                          onTap: () {
                            setState(() => touchedIndex = -1);
                            _selectMode(StatisticMode.total);
                          }
                      ),
                      _selectionButton(
                          text: 'สัปดาห์',
                          selected: selection == StatisticMode.week,
                          onTap: () {
                            setState(() => touchedIndex = -1);
                            _selectMode(StatisticMode.week);
                          }
                      ),
                      _selectionButton(
                          text: 'เดือน',
                          selected: selection == StatisticMode.month,
                          onTap: () {
                            setState(() => touchedIndex = -1);
                            _selectMode(StatisticMode.month);
                          }
                      ),
                      _selectionButton(
                          text: 'ปี',
                          selected: selection == StatisticMode.year,
                          onTap: () {
                            setState(() => touchedIndex = -1);
                            _selectMode(StatisticMode.year);
                          }
                      ),
                    ],
                  ),

                  Expanded(
                      child: LayoutBuilder(
                          builder: (context, constraints) {
                            // final random = Random();
                            final data = switch (selection) {
                              StatisticMode.total => widget.workingHour?.total ?? {},
                              StatisticMode.week => widget.workingHour?.week ?? {},
                              StatisticMode.month => widget.workingHour?.month ?? {},
                              StatisticMode.year => widget.workingHour?.year ?? {},
                            }; // { for (var item in List.generate((random.nextDouble() * 31.0).toInt(), (i) => i)) '${item+1}' : random.nextDouble() * 50.0 },

                            // 🚩 (Phase 3) แท่งกว้างสุด 40 อยู่แล้ว แต่ fl_chart กระจาย
                            // แท่งให้เต็มความกว้างที่ได้รับเสมอ พอแท็บ "ทั้งหมด" มีแค่
                            // 2 แท่งบนจอกว้าง ~920 จึงได้แท่งเล็กจ้อยสองอันลอยห่างกัน
                            // คนละมุม (ดู PHASE3_PAGE_DESIGN.md หัวข้อ /statistic)
                            //
                            // จำกัดความกว้าง "กราฟ" ตามจำนวนแท่งแล้วจัดกลุ่มไว้กลาง
                            // — แท็บที่มีแท่งเยอะ (เดือน = 31 แท่ง) ยังได้เต็มความกว้าง
                            // เหมือนเดิมเพราะ min() เลือกค่าที่เล็กกว่า
                            const slotPerBar = 80.0;
                            const axisSpace = 60.0;
                            final chartWidth = min(
                              constraints.maxWidth,
                              max(320.0, data.length * slotPerBar + axisSpace),
                            );

                            return Center(
                              child: SizedBox(
                                width: chartWidth,
                                child: _barChart(data: data, width: chartWidth),
                              ),
                            );
                          }
                      )
                  ),
                ],
              ),
            ),

            /// Summary
            if (widget.showSummary)
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Container(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    spacing: 10,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: SvgPicture.asset('assets/images/total_working_hour.svg'),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown, // 👈 This tells the text to shrink if it overflows
                              alignment: Alignment.centerLeft, // Keep it aligned to the left
                              child: Text(
                                'ชั่วโมงทำงานรวม',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w200,
                                  color: AppColors.blackTextColor,
                                ),
                              ),
                            ),
                            Text(
                              '${switch(selection) {
                                StatisticMode.total => widget.workingHour?.totalWorkingHour ?? 0,
                                StatisticMode.week => widget.workingHour?.weeklyWorkingHour ?? 0,
                                StatisticMode.month => widget.workingHour?.monthlyWorkingHour ?? 0,
                                StatisticMode.year => widget.workingHour?.yearlyWorkingHour ?? 0,
                              }} ชม.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7765FF), // AppColors.textmurasaki
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: SvgPicture.asset('assets/images/average_working_hour.svg'),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                  fit: BoxFit.scaleDown, // 👈 This tells the text to shrink if it overflows
                                  alignment: Alignment.centerLeft, // Keep it aligned to the left
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'ชั่วโมงทำงานเฉลี่ยต่อ${(selection == StatisticMode.year ? 'เดือน' : selection == StatisticMode.total ? 'ปี' : 'วัน')}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w200,
                                        color: AppColors.blackTextColor,
                                      ),
                                    ),
                                  )
                              ),
                              Text(
                                '${switch(selection) {
                                  StatisticMode.total => widget.workingHour?.totalAverageHour ?? 0,
                                  StatisticMode.week => widget.workingHour?.weeklyAverageHour ?? 0,
                                  StatisticMode.month => widget.workingHour?.monthlyAverageHour ?? 0,
                                  StatisticMode.year => widget.workingHour?.yearlyAverageHour ?? 0,
                                }} ชม.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE33C74), // AppColors.textmurasaki
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _selectionButton({required String text, Function()? onTap, required bool selected}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 25,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              selected ? Color(0xFF525252).withValues(alpha: 0.10) : Colors.transparent,
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: selected ? Color(0xFF3C3C3C) : Color(0xFFB5B5B5),
                ),
              )
            ),
            Container(
              height: 2.25,
              width: double.infinity,
              color: selected ? Color(0xFF3C3C3C) : Color(0xFFB5B5B5),
            )
          ],
        ),
      ),
    );
  }

  Widget _barChart({required Map<String, double> data, required double width}) {

    double keyWidth = getMaxKeyWidth(data, TextStyle(fontSize: 11));

    // SAFEGUARD 1: Ensure labelAmount is never less than 1 to prevent division by zero later
    int labelAmount = max(1, (width / (keyWidth + 3.5)).floor());

    double barWidth = min((width / data.length) * 0.5, 40);

    // SAFEGUARD 2: Safely get the max value
    double maxValue = data.isNotEmpty ? data.values.reduce(max) : 0.0;

    // SAFEGUARD 3: Only run the log calculation if the max value is greater than 0
    String leftReservedText = '';
    if (maxValue > 0) {
      int exponent = (log(maxValue.round().abs()) / ln10).floor() + 1;
      leftReservedText = Utils.numberFormat(pow(10, exponent) * 8);
    } else {
      leftReservedText = '0'; // Fallback text to reserve layout space when all values are 0
    }

    // 🚩 (Phase 3) extraPadding ต้องเท่ากับ padding ขวาจริงที่ใช้ตอน render
    // ตัวเลขแกน Y ด้านล่าง (Padding right:10) ไม่งั้นพื้นที่ที่จองไว้แคบกว่าที่
    // ต้องใช้จริงอยู่ 4px ทำให้ตัวเลขที่มี comma (เช่น "1,282") ตัดขึ้นบรรทัดใหม่
    double leftReverseSide = getReservedSize(
        text: leftReservedText,
        style: TextStyle(fontSize: 11),
        extraPadding: 10
    );

    // 🚩 (2026-08-22) ปิด animation เมื่อ "จำนวนแท่ง" เปลี่ยน
    //
    // BarChart เป็น ImplicitlyAnimatedWidget — มันจะ lerp ระหว่างข้อมูลเก่ากับใหม่
    // แต่ lerpList ของ fl_chart (utils/lerp.dart) เขียนไว้แบบนี้:
    //     return List.generate(b.length, (i) {
    //       return lerp(i >= a.length ? b[i] : a[i], b[i], t);   // ← b[i] -> b[i]
    //     });
    // แท่งที่ index เกินความยาวของลิสต์เก่า จะได้ค่า b[i] เต็มตั้งแต่ t = 0
    // คือ "สูงเต็มที่ทันที" ในขณะที่ maxY (ความสูงแกน Y) เป็น double ธรรมดา
    // ที่ยัง lerp ไต่ขึ้นมาจากค่าเก่าอยู่ -> แท่งเลยถูกวาดทะลุขึ้นไปเหนือกรอบกราฟ
    //
    // เจอ 2 จังหวะ:
    //   1. เปิดหน้าครั้งแรก — workingHour ยังเป็น null อยู่เฟรมแรก (0 แท่ง)
    //      พอข้อมูลมาถึงกลายเป็น N แท่ง maxY เก่า ≈ 0 เลยพุ่งแรงสุด
    //   2. สลับ ทั้งหมด/สัปดาห์/เดือน/ปี ที่จำนวนแท่งไม่เท่ากัน (7 -> 31)
    //
    // ถ้าจำนวนแท่งเท่าเดิม lerp ทำงานถูกต้อง ปล่อยให้ animate ตามปกติ
    final barCount = data.length;
    final animate = _prevBarCount == barCount;
    _prevBarCount = barCount;

    return BarChart(
      duration: animate ? const Duration(milliseconds: 150) : Duration.zero,
      BarChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (double value, TitleMeta meta) {
                // Check if the value is within our list range
                int index = value.toInt();
                if (index >= 0 && index < data.length) {

                  if (index % (data.length / labelAmount).ceil() == 0) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 4, // space between bar and title
                      child: Text(data.keys.toList()[index], style: TextStyle(fontSize: 11)),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // Hide other titles for a clean look
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: leftReverseSide,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Padding(
                  padding: EdgeInsetsGeometry.only(right: 10),
                  child: Text(
                    Utils.numberFormat(value.round()),
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 11),
                  ),
                );
              }
            )
          )
        ),

        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (d) {
            return FlLine(
              color: Color(0xFFDBDEE4)
            );
          }
        ),

        borderData: FlBorderData(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey, // The color of your baseline
              width: 2,           // The thickness of the line
            ),
            // By leaving top, left, and right out, they default to BorderSide.none
            left: BorderSide.none,
            right: BorderSide.none,
            top: BorderSide.none,
          ),
        ),

        barTouchData: BarTouchData(
          handleBuiltInTouches: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (data) {
              return Color(0xFF8979FF).withValues(alpha: 0.2);
            },
            tooltipPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            // 2. Only trigger on Tap Up (when the user lifts their finger)
            if (event is FlTapUpEvent) {
              setState(() {
                if (barTouchResponse != null && barTouchResponse.spot != null) {
                  int tappedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;

                  // 3. Toggle Logic
                  if (touchedIndex == tappedBarIndex) {
                    touchedIndex = -1; // Tap same bar -> close it
                  } else {
                    touchedIndex = tappedBarIndex; // Tap new bar -> open it
                  }
                } else {
                  // Tap outside the bars -> close it
                  touchedIndex = -1;
                }
              });
            }
          },
        ),

        barGroups: data.keys.toList().asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            showingTooltipIndicators: touchedIndex == entry.key ? [0] : [],
            barRods: [
              BarChartRodData(
                width: barWidth,
                toY: data[entry.value] ?? 0,
                color: touchedIndex == entry.key || touchedIndex == -1 ? Color(0xFF8979FF) : Color(0xFFCBC4FF),
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double getMaxKeyWidth(Map<String, double> data, TextStyle style) {
    double maxWidth = 0;

    for (String key in data.keys) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: key, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (textPainter.size.width > maxWidth) {
        maxWidth = textPainter.size.width;
      }
    }

    return maxWidth;
  }

  double getReservedSize({
    required String text,
    required TextStyle style,
    double extraPadding = 0.0,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr, // Required for TextPainter to layout
    )..layout();

    return textPainter.size.width + extraPadding;
  }
}