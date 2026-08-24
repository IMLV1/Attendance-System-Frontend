import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class ConfigBudgetYearService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getData() async {
    return dio.get('/system/config/budget_year/get');
  }

  /// ขอบเขตปีงบประมาณปัจจุบัน — ใช้จำกัดปฏิทินตอนเลือกวันลา
  /// (ยื่นลาได้เฉพาะภายในปีงบประมาณปัจจุบันเท่านั้น)
  Future<Response<dynamic>> getCurrentPeriod() async {
    return dio.get('/system/config/budget_year/current');
  }

  /// [applyMode] เลือกว่าวันตัดรอบใหม่จะมีผลเมื่อไหร่ (ปีงบที่ผ่านไปแล้วไม่ถูกแตะทั้ง 2 กรณี)
  ///  - 'next'    : ไม่แตะปีงบปัจจุบัน เริ่มใช้กับปีงบถัดไป
  ///  - 'current' : ปิดปีงบปัจจุบันที่วันตัดรอบใหม่ทันที (ปีนั้นจะสั้น/ยาวกว่า 12 เดือน)
  Future<Response<dynamic>> update(int day, int month, {String applyMode = 'next'}) async {
    return dio.put(
      '/system/config/budget_year/update',
      data: {
        'day': day,
        'month': month,
        'apply-mode': applyMode,
      }
    );
  }
}
