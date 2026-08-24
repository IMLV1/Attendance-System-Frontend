import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';

class ClockWidget extends StatelessWidget {
  final DateTime? time; // 💡 รับค่าจากหน้า CheckinPage

  const ClockWidget({super.key, this.time});

  @override
  Widget build(BuildContext context) {
    // 🚩 แก้: ใช้ "--:--" แทนข้อความ "กำลังซิงค์เวลา..." — layout/ขนาดตัวอักษรเหมือนตอนมีเวลาจริง
    // เป๊ะ (ไม่มีจังหวะ layout กระโดดตอนสลับจาก placeholder ไปเป็นเวลาจริง)
    return Column(
      children: [
        Text(
          time == null ? '--:--' : DateFormat('HH:mm').format(time!),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          // เพิ่มการเช็ค locale ให้เป็นภาษาไทยตามเดิม
          time == null ? '--' : DateFormat('EEEE d MMMM yyyy', 'th').format(time!),
          style: const TextStyle(fontSize: 15, color: AppColors.lightTextColor),
        ),
      ],
    );
  }
}