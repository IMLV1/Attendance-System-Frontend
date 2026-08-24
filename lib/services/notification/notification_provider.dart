import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/auth/token_storage.dart';
import '../../service_locator.dart';
import '../notification/notification_model.dart';
import '../notification/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = getIt<NotificationService>();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  Timer? _pollTimer;

  /// 🚩 แก้ (2026-08-22): เดิมดึงข้อมูลครั้งเดียวตอนสร้าง provider แล้วไม่ดึงซ้ำอีกเลย
  /// -> แจ้งเตือนใหม่ที่เข้ามาระหว่างใช้งานจะไม่ถูกนับ จุดแดงเลยไม่เคยขึ้น
  /// และถ้าครั้งแรกดึงตอนยังไม่ล็อกอิน (ไม่มี token) จะ fail แล้วว่างถาวร
  /// ตอนนี้ดึงซ้ำเป็นระยะ + ข้ามการดึงถ้ายังไม่มี token
  /// 15 วิ — สั้นพอให้จุดแดงขึ้นเร็วหลังล็อกอิน และหลังสลับบัญชีข้อมูลของคนเก่า
  /// ค้างอยู่ไม่นาน (endpoint เบา ข้อมูลไม่เยอะ)
  static const _pollInterval = Duration(seconds: 15);

  NotificationProvider() {
    fetchNotifications();
    _pollTimer = Timer.periodic(_pollInterval, (_) => fetchNotifications());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    // ⚠️ สำคัญ: ห้ามยิงตอนยังไม่ล็อกอิน — จะได้ 401 แล้ว interceptor จะพยายาม
    // refresh token ต่อ พอไม่สำเร็จก็สั่ง logout ทั้งที่ผู้ใช้กำลังอยู่หน้า login อยู่แล้ว
    final token = await getIt<TokenStorage>().accessToken;
    if (token == null || token.isEmpty) return;

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

  /// ล้างข้อมูลตอน logout — กันแจ้งเตือนของคนก่อนหน้าค้างให้คนถัดไปเห็น
  void clear() {
    _notifications = [];
    notifyListeners();
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
