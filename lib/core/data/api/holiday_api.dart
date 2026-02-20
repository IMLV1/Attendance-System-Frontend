import 'package:attendance_system/core/data/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class HolidayApi extends Api {

  Future<bool> checkTodayIsHoliday(DateTime ntpTime) async {
    try {
      // ดึงข้อมูลปีปัจจุบันจากเวลา NTP
      final year = ntpTime.year;
      final response = await dio.get('https://iapp.co.th/docs/data/holiday/thai/$year.json');

      if (response.statusCode == 200) {
        List holidays = response.data;
        String todayString = DateFormat('yyyy-MM-dd').format(ntpTime);

        for (var holiday in holidays) {
          if (holiday['date'] == todayString) {
            String name = holiday['name'] ?? "";

            //  Filter: ไม่เอาวันแรงงาน และ วันหยุดธนาคาร
            if (name.contains("วันแรงงาน") ||
                name.contains("ธนาคาร") ||
                name.contains("Bank Holiday")) {
              debugPrint("📌 วันนี้คือ $name (แต่เรานับเป็นวันทำงาน)");
              return false;
            }

            debugPrint("📅 วันนี้คือวันหยุด: $name");
            return true; // เป็นวันหยุดราชการอื่นๆ
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Holiday API Error: $e");
    }
    return false; // ถ้า Error หรือหาไม่เจอ ให้ถือว่าเป็นวันทำงานปกติ
  }
}