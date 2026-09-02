import 'dart:async';

import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'notification_model.dart';

class NotificationService {
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
}
