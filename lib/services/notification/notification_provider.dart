import 'package:flutter/material.dart';
import '../../service_locator.dart';
import '../notification/notification_model.dart';
import '../notification/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = getIt<NotificationService>();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.fetchNotifications();
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update: Update local state immediately
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      
      // Call service in background
      await _notificationService.markAsRead(id);
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic update: Update local state immediately
    bool hasUnread = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasUnread = true;
      }
    }

    if (hasUnread) {
      notifyListeners();
      
      // Call service in background
      await _notificationService.markAllAsRead();
    }
  }
}
