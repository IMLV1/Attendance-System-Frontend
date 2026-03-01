

import 'package:attendance_system/core/network/api_client.dart';
import 'package:attendance_system/services/history/attendance_history_model.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class AttendanceHistoryService {
  // หยิบโทรศัพท์ (Dio) จากกล่องกลาง (GetIt) มาใช้
  final Dio dio = GetIt.I<ApiClient>().dio;

  // ฟังก์ชันนี้ชื่อ fetchHistory แปลว่า "ไปดึงประวัติมา"
  // รับวันเริ่ม และวันจบ (จะส่งมาหรือไม่ส่งก็ได้)
  // Future คือบอกว่า "ต้องรอก่อนนะ ยังไม่ได้คำตอบทันที"
  // List<AttendanceHistoryItem> คือผลลัพธ์ที่ได้จะเป็นรายการข้อมูลการเข้างาน
  Future<List<AttendanceHistoryModel>> fetchHistory({
    String? startDate, // "2026-12-01"
    String? endDate,   // "2026-12-31"
  }) async {//บอกว่า "ฟังก์ชันนี้มีการรอนะ"
    final res = await dio.get(//await = "รอจนกว่าจะเสร็จก่อน แล้วค่อยทำต่อ"
      '/api/attendance/history',//endpoint
      queryParameters: {
        if (startDate != null)
          'startDate': startDate,
        if(endDate != null)
          'endDate': endDate
      },
      //คือการแนบข้อมูลไปกับ URL : /api/attendance/history?startDate=2026-01-01&endDate=2026-01-31
    );

    //debug
    print("status: ${res.statusCode}");
    print("type: ${res.data.runtimeType}");
    print("data: ${res.data}");

    //สมมติ backend คืนเป็น list ตรงๆ: [ {...}, {...} ]
    final raw = res.data;
    final List<Map<String, dynamic>> list;

    if (raw is List) {
      list = raw.cast<Map<String, dynamic>>();
    } else if (raw is Map && raw['data'] is List) {
      list = (raw['data'] as List).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Unexpected response format: ${raw.runtimeType}');
    }

    return list.map(AttendanceHistoryModel.fromJson).toList();
  }
}