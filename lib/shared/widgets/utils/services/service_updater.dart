import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ServiceUpdatorState { loading, success, error, idle }

class ServiceUpdater extends StatefulWidget {

  final Future<Response> Function() request;
  final Widget Function(
    void Function() trigger,
    ServiceUpdatorState state,
    String errorMessage,
  ) builder;
  final void Function()? onSuccess;
  final void Function(dynamic error)? onError;
  final void Function(dynamic data)? onSuccessResponse;
  final bool fetchOnInit;

  const ServiceUpdater({
    super.key,
    required this.request,
    required this.builder,
    this.onSuccess,
    this.onError,
    this.onSuccessResponse,
    this.fetchOnInit = false,
  });

  @override
  State<StatefulWidget> createState() => _ServiceUpdaterState();

}

class _ServiceUpdaterState extends State<ServiceUpdater> {

  ServiceUpdatorState _state = ServiceUpdatorState.idle;
  String? _errorMessage;

  Future<void> _load() async {

    setState(() {
      _state = ServiceUpdatorState.loading;
    });

    try {
      Response res = await widget.request();

      if (!mounted) return;

      if (res.statusCode! >= 200 && res.statusCode! < 300) {
        setState(() {
          _state = ServiceUpdatorState.success;
        });
        widget.onSuccess?.call();
        widget.onSuccessResponse?.call(res.data);
      } else {
        setState(() {
          _state = ServiceUpdatorState.error;
          _errorMessage = res.statusMessage;
        });
        widget.onError?.call({'error': {'type': 1, 'status': res.statusCode, 'info': res.data}});
      }
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && e.response != null) {
        setState(() {
          _state = ServiceUpdatorState.error;
          _errorMessage = e.response?.statusMessage ?? 'Unknown error';
        });
        widget.onError?.call({'error': {'type': 2, 'status': e.response?.statusCode ?? 0, 'info': _errorMessage}});
      } else {
        setState(() {
          _state = ServiceUpdatorState.error;
          _errorMessage = e.toString();
        });
        widget.onError?.call({'error': {'type': 3, 'info': _errorMessage}});
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.fetchOnInit) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return widget.builder(
      _load,
      _state,
      _errorMessage ?? 'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง...'
    );
  }

}