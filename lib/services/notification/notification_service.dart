import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'notification_model.dart';
import 'dart:async';

class NotificationService {
  // Mock data to simulate the backend (kept as requested, not currently used)
  final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: "notif_1",
      title: "คำขอลางานถูกปฏิเสธ",
      message: "คำขอลาป่วยวันที่ 24 ก.ย. 2568 ถึงวันที่ 30 ก.ย. 2568 ถูกปฏิเสธโดย ผศ.ดร.สมชาย ใจดี",
      isRead: false,
      type: "LEAVE_REQUEST",
      status: "REJECTED",
      requestNumber: "LEV0000000065012",
      createdAt: DateTime(2025, 1, 13, 9, 41),
    ),
    NotificationModel(
      id: "notif_2",
      title: "คำขอลางานถูกอนุมัติ",
      message: "คำขอลากิจวันที่ 24 ก.ย. 2568 ถึงวันที่ 30 ก.ย. 2568 ถูกอนุมัติโดย ผศ.ดร.สมชาย ใจดี",
      isRead: true,
      type: "LEAVE_REQUEST",
      status: "APPROVED",
      requestNumber: "LEV0000000065013",
      createdAt: DateTime(2025, 1, 13, 9, 41),
    ),
    NotificationModel(
      id: "notif_3",
      title: "คำขอเวลาเข้า-ออกงานถูกอนุมัติ",
      message: "คำขออนุมัติเวลาเข้า-ออกงานวันที่ 24 ก.ย. 2568 ถึงวันที่ 30 ก.ย. 2568 ถูกอนุมัติโดย ผศ.ดร.สมชาย ใจดี",
      isRead: true,
      type: "ATTENDANCE_REQUEST",
      status: "APPROVED",
      requestNumber: "REQ0000000065013",
      createdAt: DateTime(2025, 1, 13, 9, 41),
    ),
    NotificationModel(
      id: "notif_4",
      title: "คำขอเวลาเข้า-ออกงานถูกปฏิเสธ",
      message: "คำขออนุมัติเวลาเข้า-ออกงานวันที่ 24 ก.ย. 2568 ถึงวันที่ 30 ก.ย. 2568 ถูกปฏิเสธโดย ผศ.ดร.สมชาย ใจดี",
      isRead: false,
      type: "ATTENDANCE_REQUEST",
      status: "REJECTED",
      requestNumber: "REQ0000000065014",
      createdAt: DateTime(2025, 1, 13, 9, 41),
    ),
    NotificationModel(
      id: "notif_5",
      title: "การอนุมัติคำขอลางาน",
      message: "คำขอลาป่วยวันที่ 24 ก.ย. 2568 ถึงวันที่ 30 ก.ย. 2568 โดย ผศ.ดร.สมชาย ใจดี",
      isRead: true,
      type: "APPROVER_LEAVE",
      status: "PENDING",
      requestNumber: "LEV0000000065015",
      createdAt: DateTime(2025, 1, 13, 9, 41),
    ),
    NotificationModel(
      id: "notif_6",
      title: "การอนุมัติเวลาเข้า-ออกงาน",
      message: "คำขออนุมัติเวลาเข้า-ออกงานวันที่ 24 ก.ย. 2568 ถึงวันที่ 30 ก.ย. 2568 โดย ผศ.ดร.สมชาย ใจดี",
      isRead: true,
      type: "APPROVER_ATTENDANCE",
      status: "PENDING",
      requestNumber: "REQ0000000065016",
      createdAt: DateTime(2025, 1, 13, 9, 41),
    ),
  ];

  final Dio _dio = GetIt.I<ApiClient>().dio;

  /// Fetch notifications from the backend
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _dio.get('/api/notifications');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("[NotificationService] Error fetching notifications: $e");
      return [];
    }
  }

  /// Mark a specific notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _dio.patch('/api/notifications/$notificationId/read');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("[NotificationService] Error marking as read: $e");
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _dio.patch('/api/notifications/read-all');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("[NotificationService] Error marking all as read: $e");
      return false;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/api/notifications/unread-count');
      if (response.statusCode == 200) {
        return response.data['count'] as int;
      }
      return 0;
    } catch (e) {
      debugPrint("[NotificationService] Error getting unread count: $e");
      return 0;
    }
  }

  /// Send a notification to the approver when a new request is created
  Future<Response<dynamic>> sendRequestNotification(String type, String requestNumber) async {
    final Dio dio = GetIt.I<ApiClient>().dio;
    return dio.post('/api/notifications/send-request', data: {
      'type': type,
      'requestNumber': requestNumber,
    });
  }

  /// Send a notification to the requester when their request is approved or rejected
  Future<Response<dynamic>> sendApprovalResponseNotification(String type, String requestNumber, String status) async {
    final Dio dio = GetIt.I<ApiClient>().dio;
    return dio.post('/api/notifications/send-response', data: {
      'type': type,
      'requestNumber': requestNumber,
      'status': status,
    });
  }
}
