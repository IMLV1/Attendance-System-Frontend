import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';

class ClockWidget extends StatelessWidget {
  final DateTime? time; // 💡 รับค่าจากหน้า CheckinPage

  /// ขนาดตัวเลขเวลา — จอกว้างใช้ใหญ่กว่านี้ได้ (ดู `checkin_page.dart`)
  final double timeFontSize;

  /// ขนาดบรรทัดวันที่ใต้เวลา
  final double dateFontSize;

  const ClockWidget({
    super.key,
    this.time,
    this.timeFontSize = 40,
    this.dateFontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    // 🚩 แก้: ใช้ "--:--" แทนข้อความ "กำลังซิงค์เวลา..." — layout/ขนาดตัวอักษรเหมือนตอนมีเวลาจริง
    // เป๊ะ (ไม่มีจังหวะ layout กระโดดตอนสลับจาก placeholder ไปเป็นเวลาจริง)
    return Column(
      children: [
        Text(
          time == null ? '--:--' : DateFormat('HH:mm').format(time!),
          style: TextStyle(fontSize: timeFontSize, fontWeight: FontWeight.bold),
        ),
        Text(
          // เพิ่มการเช็ค locale ให้เป็นภาษาไทยตามเดิม
          time == null ? '--' : DateFormat('EEEE d MMMM yyyy', 'th').format(time!),
          style: TextStyle(fontSize: dateFontSize, color: AppColors.lightTextColor),
        ),
      ],
    );
  }
}