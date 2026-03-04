import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

Future<Response<dynamic>> getAttendenceStat({
  DateTime? startDate,
  DateTime? endDate,
}) async{
  String? startStr = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null;
  String? endStr = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null;

  try{
    debugPrint('API Request: กำลังดึงข้อมูลสถิติการเข้าออก...');
    debugPrint('Start Date: $startStr, End Date: $endStr');

    final response = await Dio().get(
      'api/attendance/stat',
      queryParameters: {
        if (startStr != null) 'startDate': startStr,
        if (endStr != null) 'endDate': endStr,
      },
    );
    debugPrint('API Success: ได้รับข้อมูลสถิติการเข้าออกจาก Server');
    return response;
  }on DioException catch(e){
    debugPrint('API Error: เกิดปัญหาในการดึงข้อมูลสถิติการเข้าออก: ${e.message}');
    rethrow;
  }
}