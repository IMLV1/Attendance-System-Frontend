import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NavigationGuard extends ChangeNotifier {
  bool _isDirty = false;
  bool get isDirty => _isDirty;

  set isDirty(bool value) {
    if (_isDirty != value) {
      _isDirty = value;
      notifyListeners();
    }
  }

  Future<Response<dynamic>> Function()? onSave;
  VoidCallback? onDiscard;

  void reset() {
    _isDirty = false;
    onSave = null;
    onDiscard = null;
    notifyListeners();
  }

  void update({
    required bool isDirty,
    Future<Response<dynamic>> Function()? onSave,
    VoidCallback? onDiscard,
  }) {
    final bool dirtyChanged = _isDirty != isDirty;
    _isDirty = isDirty;
    this.onSave = onSave;
    this.onDiscard = onDiscard;
    if (dirtyChanged) {
      notifyListeners();
    }
  }
}
