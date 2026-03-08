import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'notification_model.dart';
import 'dart:async';

class NotificationService {
  // Mock data to simulate the backend
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

  /// Fetch notifications from the simulated backend
  Future<List<NotificationModel>> fetchNotifications() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("[NotificationService] Fetched ${_mockNotifications.length} notifications (Mock Data)");
    return List.from(_mockNotifications); // Return a copy of the list
  }

  /// Mark a specific notification as read in the simulated backend
  Future<bool> markAsRead(String notificationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications[index] = _mockNotifications[index].copyWith(isRead: true);
      debugPrint("[NotificationService] Marked notification $notificationId as read");
      return true;
    }
    return false;
  }

  /// Mark all notifications as read in the simulated backend
  Future<bool> markAllAsRead() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (int i = 0; i < _mockNotifications.length; i++) {
      _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
    }
    debugPrint("[NotificationService] Marked all notifications as read");
    return true;
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
