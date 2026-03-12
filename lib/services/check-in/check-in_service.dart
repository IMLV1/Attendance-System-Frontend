import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import 'check-in_model.dart';

class AttendanceService {
  final Dio dio = GetIt.I<ApiClient>().dio;
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
  // เพิ่มเข้าไปในคลาส AttendanceService
  //
  Future<AttendanceModel?> getTodayAttendance(String date) async {
    try {
      // 💡 เปลี่ยน URL เป็นเส้นใหม่ที่เพื่อนเพิ่งทำให้
      final response = await dio.get('/api/attendance/today');

      if (response.statusCode == 200 && response.data != null) {
        debugPrint("✅ ข้อมูลจาก Backend (GET): ${response.data}");

        var data = response.data;

        if (data is Map<String, dynamic>) {
          // 💡 ดึงค่าจาก JSON ที่เพื่อนส่งมา (จะได้ "08:30" หรือ null)
          String? checkInValue = data['checkIn'];
          String? checkOutValue = data['checkOut'];

          // 💡 แปลงเป็น true/false ให้หน้าจอเอาไปปรับสถานะปุ่ม
          // ถ้าไม่เท่ากับ null แปลว่าเช็คอิน/เช็คเอาต์แล้ว -> ได้ค่า true
          bool isCheckIn = checkInValue != null;
          bool isCheckOut = checkOutValue != null;

          return AttendanceModel(
            // ถ้าเป็น null ให้แสดง "---" แทน
            checkInTime: checkInValue ?? "---",
            checkOutTime: checkOutValue ?? "---",
            hasCheckedIn: isCheckIn,
            hasCheckedOut: isCheckOut,
            lastUpdateDate: date,
          );
        }
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ ดึงข้อมูลเวลาล้มเหลว: ${e.message}");
      return null;
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