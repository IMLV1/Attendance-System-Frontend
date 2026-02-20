import 'dart:convert';

import 'package:attendance_system/core/data/api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/attendance_model.dart';

class AttendanceApi extends Api {

  static const String _storageKey = 'daily_attendance_state';

  Future<Response<dynamic>> postAttendance(DateTime ntpTime, String type) async {
    // 1. เตรียมข้อมูล วันที่ และ เวลา
    String dateOnly = DateFormat('yyyy-MM-dd').format(ntpTime);
    String timeOnly = DateFormat('HH:mm:ss').format(ntpTime);
    String isoTimestamp = '${ntpTime.toUtc().toIso8601String().split('.').first}Z';


    final Map<String, dynamic> dataPayload = {
      'timestamp': isoTimestamp,
      'type': type,
    };

    // 3. Print ข้อมูลที่จะส่งออกไปดูใน Console
    debugPrint("[API Request] กำลังส่งข้อมูลไป Backend...");
    debugPrint("Payload: ${jsonEncode(dataPayload)}");

    try {
      // 4. ยิง API เพียงครั้งเดียวและเก็บค่าไว้ในตัวแปร response
      final response = await dio.post(
        '/api/attendance/record',
        data: dataPayload,
      );

      // 5. Print ผลลัพธ์เมื่อสำเร็จ
      debugPrint("[API Success] Server ตอบกลับมาด้วย Code: ${response.statusCode}");
      debugPrint("Data จาก Server: ${response.data}");

      return response;
    } on DioException catch (e) {
      // 6. Print เมื่อเกิดข้อผิดพลาด
      debugPrint("[API Error] เกิดปัญหา: ${e.message}");
      if (e.response != null) {
        debugPrint("Response Error Data: ${e.response?.data}");
        debugPrint("Status Code: ${e.response?.statusCode}");
      }
      rethrow; // ส่ง Error ต่อไปให้หน้า UI จัดการโชว์ SnackBar
    }
  }

  // 2. บันทึกสถานะลงในเครื่อง (Local Storage)
  Future<void> saveLocalState(AttendanceModel model) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(model.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

  // 3. โหลดสถานะจากในเครื่องมาใช้
  Future<AttendanceModel?> getLocalState(DateTime networkTime) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      return AttendanceModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // 4. ล้างข้อมูล (ใช้ตอน Reset ประจำวัน)
  Future<void> clearLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}