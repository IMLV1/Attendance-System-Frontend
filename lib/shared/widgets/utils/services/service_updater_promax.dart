import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ServiceUpdaterProMaxState { loading, success, error, idle }

class ServiceUpdaterProMax extends StatefulWidget {
  // 1. แก้ไขประเภทของตัวแปรนี้
  final List<Future<Response> Function()> requests;

  final Widget Function(
      Function(int reqIndex) trigger,
      Function(int reqIndex) getState,
      ) builder;
  final void Function(int reqIndex, dynamic data)? onSuccess;
  final void Function(int reqIndex, dynamic error)? onError;
  final bool fetchOnInit;

  const ServiceUpdaterProMax({
    super.key,
    required this.requests,
    required this.builder,
    this.onSuccess,
    this.onError,
    this.fetchOnInit = false,
  });

  @override
  State<StatefulWidget> createState() => _ServiceUpdaterProMaxState();
}

class _ServiceUpdaterProMaxState extends State<ServiceUpdaterProMax> {
  final List<ServiceUpdaterProMaxState> _states = [];

  ServiceUpdaterProMaxState _getState(int reqIndex) {
    return _states[reqIndex];
  }

  // 🚩 ดึงข้อความ error จาก field "error" ใน JSON body ก่อน (เดิมใช้ statusMessage ซึ่งเป็นแค่
  // reason phrase ของ HTTP เช่น "Internal Server Error" ไม่ใช่ข้อความจริงจาก backend)
  String _extractErrorMessage(dynamic data, String? fallbackStatusMessage) {
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    return fallbackStatusMessage ?? 'Unknown error';
  }

  Future<void> _load(int reqIndex) async {

    setState(() {
      _states[reqIndex] = ServiceUpdaterProMaxState.loading;
    });

    try {

      Response res = await widget.requests[reqIndex]();

      if (!mounted) return;

      if (res.statusCode! >= 200 && res.statusCode! < 300) {
        setState(() {
          widget.onSuccess?.call(reqIndex, res.data);
          _states[reqIndex] = ServiceUpdaterProMaxState.success;
        });
      } else {
        setState(() {
          widget.onError?.call(reqIndex, {'error': {'type': 1, 'info': _extractErrorMessage(res.data, res.statusMessage)}});
          _states[reqIndex] = ServiceUpdaterProMaxState.error;
        });
      }
    } catch (e) {
      if (!mounted) return;

      if (e is DioException && e.response != null) {
        setState(() {
          widget.onError?.call(reqIndex, {'error': {'type': 2, 'info': _extractErrorMessage(e.response?.data, e.response?.statusMessage)}});
          _states[reqIndex] = ServiceUpdaterProMaxState.error;
        });
      } else {
        setState(() {
          widget.onError?.call(reqIndex, {'error': {'type': 3, 'info': e.toString()}});
          _states[reqIndex] = ServiceUpdaterProMaxState.error;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 3. แก้ไขการอ้างอิง length
    _states.addAll(List.generate(widget.requests.length, (index) => ServiceUpdaterProMaxState.idle));

    if (widget.fetchOnInit) {
      // 4. แก้ไขการอ้างอิง length
      for (int i = 0; i < widget.requests.length; i++) {
        _load(i);
      }
    }
  }

  Future<void> _loadHandle(int reqIndex) async {
    if (reqIndex < 0) {
      for (int i = 0; i < widget.requests.length; i++) {
        _load(i);
      }
    } else {
      _load(reqIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_loadHandle, _getState);
  }
}