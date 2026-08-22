import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class AttendanceHistoryService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  /// 🚩 (2026-08-22) รองรับแบ่งหน้า — เดิมดึงประวัติทั้งหมดทีเดียว (เป็นร้อยรายการ)
  /// ทำให้หน้าประวัติกระตุกหนักตอนเปิด
  /// ส่ง [limit] มา = backend ตอบเป็น {data, total, has-more}
  /// ไม่ส่ง = ตอบ array ดิบเหมือนเดิม
  Future<Response<dynamic>> fetchHistory({
    String? startDate,
    String? endDate,
    int? limit,
    int? offset,
  }) {
    return dio.get(
      '/api/attendance/history',
      queryParameters: {
        'startDate': ?startDate,
        'endDate': ?endDate,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
  }

  Future<Response<dynamic>> getFilterRange() {
    return dio.get('/api/attendance/filter_range');
  }
}