import 'dart:math';

import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:attendance_system/shared/widgets/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkingHour extends StatefulWidget {

  const WorkingHour({super.key});

  @override
  State<StatefulWidget> createState() => _WorkingHourState();
}

class _WorkingHourState extends State<WorkingHour> {

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        spacing: 13,
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
                      selected: false,
                    ),
                    _selectionButton(
                      text: 'สัปดาห์',
                      selected: true,
                    ),
                    _selectionButton(
                      text: 'เดือน',
                      selected: false,
                    ),
                    _selectionButton(
                      text: 'ปี',
                      selected: false,
                    ),
                  ],
                ),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final random = Random();
                      return _barChart(
                        data: { for (var item in List.generate((random.nextDouble() * 31.0).toInt(), (i) => i)) '${item+1}' : random.nextDouble() * 50.0 },
                        width: constraints.maxWidth,
                      );
                    }
                  )
                ),
              ],
            ),
          ),
        ],
      ),
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

    double keyWidth = getMaxKeyWidth(data, TextStyle(fontSize: 12));
    int labelAmount = (width / (keyWidth + 3.5)).floor();

    double barWidth = min((width / data.length) * 0.5, 40);

    return BarChart(
      BarChartData(
        // 1. Map labels to the X axis

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
                      child: Text(data.keys.toList()[index], style: TextStyle(fontSize: 12)),
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
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Padding(
                  padding: EdgeInsetsGeometry.only(right: 10),
                  child: Text(
                    Utils.numberFormat(value.round()),
                    textAlign: TextAlign.end,
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

        // 2. Use the index as the 'x' parameter
        barGroups: data.keys.toList().asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                width: barWidth,
                toY: data[entry.value] ?? 0,
                color: Color(0xFF8979FF),
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
}