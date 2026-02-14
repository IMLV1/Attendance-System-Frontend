import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ServiceUpdatorState { loading, success, error, idle }

class ServiceUpdater extends StatefulWidget {

  final Future<Response> Function() request;
  final Widget Function(
    Function() trigger,
    ServiceUpdatorState state,
    String errorMessage,
  ) builder;
  final void Function() onSuccess;

  const ServiceUpdater({
    super.key,
    required this.request,
    required this.onSuccess,
    required this.builder,
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
        widget.onSuccess();
      } else {
        setState(() {
          _state = ServiceUpdatorState.error;
          _errorMessage = res.statusMessage;
        });
      }
    } catch (e) {
      if (!mounted) return;

      if (e is DioException && e.response != null) {
        setState(() {
          _state = ServiceUpdatorState.error;
          _errorMessage = e.response?.statusMessage ?? 'Unknown error';
        });
      } else {
        setState(() {
          _state = ServiceUpdatorState.error;
          _errorMessage = e.toString();
        });
      }
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