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

  const WorkingHour(this.workingHour, {super.key});

  @override
  State<StatefulWidget> createState() => _WorkingHourState();
}

class _WorkingHourState extends State<WorkingHour> {

  StatisticMode selection = StatisticMode.total;

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {

    return Column(
      spacing: 6,
      children: [
        /// Title
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
                            setState(() {
                              selection = StatisticMode.total;
                              touchedIndex = -1;
                            });
                          }
                      ),
                      _selectionButton(
                          text: 'สัปดาห์',
                          selected: selection == StatisticMode.week,
                          onTap: () {
                            setState(() {
                              selection = StatisticMode.week;
                              touchedIndex = -1;
                            });
                          }
                      ),
                      _selectionButton(
                          text: 'เดือน',
                          selected: selection == StatisticMode.month,
                          onTap: () {
                            setState(() {
                              selection = StatisticMode.month;
                              touchedIndex = -1;
                            });
                          }
                      ),
                      _selectionButton(
                          text: 'ปี',
                          selected: selection == StatisticMode.year,
                          onTap: () {
                            setState(() {
                              selection = StatisticMode.year;
                              touchedIndex = -1;
                            });
                          }
                      ),
                    ],
                  ),

                  Expanded(
                      child: LayoutBuilder(
                          builder: (context, constraints) {
                            // final random = Random();
                            return _barChart(
                              data: switch (selection) {
                                StatisticMode.total => widget.workingHour?.total ?? {},
                                StatisticMode.week => widget.workingHour?.week ?? {},
                                StatisticMode.month => widget.workingHour?.month ?? {},
                                StatisticMode.year => widget.workingHour?.year ?? {},
                              }, // { for (var item in List.generate((random.nextDouble() * 31.0).toInt(), (i) => i)) '${item+1}' : random.nextDouble() * 50.0 },
                              width: constraints.maxWidth,
                            );
                          }
                      )
                  ),
                ],
              ),
            ),

            /// Summary
            Row(
              children: [
                Container(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(0xFFECECEC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: SvgPicture.asset('assets/images/total_working_hour.svg'),
                      )
                    ],
                  ),
                ),
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
    int labelAmount = (width / (keyWidth + 3.5)).floor();

    double barWidth = min((width / data.length) * 0.5, 40);

    double leftReverseSide = getReservedSize(text: data.isNotEmpty ? Utils.numberFormat(pow(10, (log(data.values.reduce(max).round().abs()) / ln10).floor() + 1) * 8) : '', style: TextStyle(fontSize: 11), extraPadding: 6);

    return BarChart(
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