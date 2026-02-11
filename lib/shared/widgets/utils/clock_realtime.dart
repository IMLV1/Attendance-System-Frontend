import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // อย่าลืมเพิ่ม intl ใน pubspec.yaml นะครับ

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Timer _timer;
  String _currentTime = '';
  String _currentDay = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    // ตั้ง Timer ให้ทำงานทุกๆ 1 วินาที
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      // ปรับ Format ตามที่คุณต้องการได้ที่นี่
      _currentTime = DateFormat('HH:mm').format(now);
      _currentDay = DateFormat('EEEE d MMMM yyyy', 'th').format(now); // แบบภาษาไทย
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // สำคัญมาก: ต้องคืน Memory เมื่อไม่ได้ใช้ Widget นี้แล้ว
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _currentTime,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            // color: AppColors.unSelectMenuColor, // นำสีจากไฟล์ AppColors ของคุณมาใส่
          ),
        ),
        Text(
          _currentDay,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            // color: AppColors.lightTextColor, // นำสีจากไฟล์ AppColors ของคุณมาใส่
          ),
        )
      ],
    );
  }
}