// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:intl/intl.dart';
//
// class HolidayService {
//   final Dio dio;
//   HolidayService(this.dio);
//
//   Future<bool> checkTodayIsHoliday(DateTime ntpTime) async {
//     try {
//       // ดึงข้อมูลปีปัจจุบันจากเวลา NTP
//       final year = ntpTime.year;
//       final response = await dio.get('https://iapp.co.th/docs/data/holiday/thai/$year.json');
//
//       if (response.statusCode == 200) {
//         List holidays = response.data;
//         String todayString = DateFormat('yyyy-MM-dd').format(ntpTime);
//
//         for (var holiday in holidays) {
//           if (holiday['date'] == todayString) {
//             String name = holiday['name'] ?? "";
//
//             //  Filter: ไม่เอาวันแรงงาน และ วันหยุดธนาคาร
//             if (name.contains("วันแรงงาน") ||
//                 name.contains("ธนาคาร") ||
//                 name.contains("Bank Holiday")) {
//               debugPrint("📌 วันนี้คือ $name (แต่เรานับเป็นวันทำงาน)");
//               return false;
//             }
//
//             debugPrint("📅 วันนี้คือวันหยุด: $name");
//             return true; // เป็นวันหยุดราชการอื่นๆ
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("⚠️ Holiday API Error: $e");
//     }
//     return false; // ถ้า Error หรือหาไม่เจอ ให้ถือว่าเป็นวันทำงานปกติ
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class HolidayService {
  final Dio dio;
  HolidayService(this.dio);

  Future<bool> checkTodayIsHoliday(DateTime ntpTime) async {
    try {
      final year = ntpTime.year;
      // ใช้ API ของ Nager.Date สำหรับประเทศไทย (TH)
      final response = await dio.get(
        'https://date.nager.at/api/v3/PublicHolidays/$year/TH',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        List holidays = response.data;
        String todayString = DateFormat('yyyy-MM-dd').format(ntpTime);

        for (var holiday in holidays) {
          if (holiday['date'] == todayString) {
            // Nager.Date จะมีทั้งชื่อภาษาท้องถิ่น (localName) และชื่อสากล (name)
            String localName = holiday['localName'] ?? "";
            String englishName = holiday['name'] ?? "";

            // รวมชื่อเพื่อใช้เช็ก Filter
            String fullName = "$localName $englishName".toLowerCase();

            // 🚫 Filter: ไม่เอาวันแรงงาน และ วันหยุดธนาคาร
            if (fullName.contains("labor day") ||
                fullName.contains("วันแรงงาน") ||
                fullName.contains("bank holiday") ||
                fullName.contains("ธนาคาร")) {
              debugPrint("📌 พบวันหยุดแต่ยกเว้น (นับเป็นวันทำงาน): $localName");
              return false;
            }

            debugPrint("📅 วันนี้คือวันหยุดราชการ: $localName");
            return true;
          }
        }
      } else if (response.statusCode == 404) {
        debugPrint("ℹ️ ไม่พบข้อมูลวันหยุดสำหรับปี $year ในระบบ API");
      }
    } catch (e) {
      debugPrint("⚠️ Holiday API Error (Nager.Date): $e");
    }
    return false; // กรณี Error หรือหาไม่เจอ ให้ถือว่าเป็นวันทำงานปกติ
  }
}