import 'package:flutter/cupertino.dart';

class NavigationState extends ChangeNotifier {
  String _currentPage = 'checkin';

  String get currentPage => _currentPage;

  void setPage(String pageId) {
    _currentPage = pageId;
    notifyListeners();
  }
}