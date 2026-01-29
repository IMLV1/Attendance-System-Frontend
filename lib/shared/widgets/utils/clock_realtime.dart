import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../theme/app_colors.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Timer _timer;
  String _timeString = "";
  String _dateString = "";

  @override
  void initState() {
    super.initState();
    // เริ่มต้นระบบภาษาไทย
    initializeDateFormatting('th', null);
    // อัปเดตเวลาทันทีที่เริ่ม
    _updateTime();
    // ตั้ง Timer ให้ทำงานทุก 1 วินาที
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel(); // สำคัญ! ต้องยกเลิก timer เมื่อปิดหน้าจอนี้
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();

    setState(() {
      // ฟอร์แมตเวลา (08:30)
      _timeString = DateFormat('HH:mm').format(now);

      // ฟอร์แมตวันที่ภาษาไทย (วันพฤหัสบดีที่ 29 มกราคม 2569)
      // ใช้ปี พ.ศ. โดยการบวก 543
      _dateString = DateFormat("EEEEที่ d MMMM ", 'th').format(now) +
          (now.year + 543).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _timeString,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.unSelectMenuColor,
          ),
        ),
        Text(
          _dateString,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextColor,
          ),
        )
      ],
    );
  }
}