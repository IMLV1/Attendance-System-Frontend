import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';

class ClockWidget extends StatelessWidget {
  final DateTime? time; // 💡 รับค่าจากหน้า CheckinPage

  const ClockWidget({super.key, this.time});

  @override
  Widget build(BuildContext context) {
    // ถ้ายังไม่มีเวลาส่งมาให้แสดง Loading
    if (time == null) return const Text("กำลังซิงค์เวลา...");

    return Column(
      children: [
        Text(
          DateFormat('HH:mm').format(time!),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          // เพิ่มการเช็ค locale ให้เป็นภาษาไทยตามเดิม
          DateFormat('EEEE d MMMM yyyy', 'th').format(time!),
          style: const TextStyle(fontSize: 15, color: AppColors.lightTextColor),
        ),
      ],
    );
  }
}