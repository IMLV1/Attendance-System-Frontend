import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ServiceLoaderState { loading, success, error }

class ServiceLoader extends StatefulWidget {
  final Future<Response> Function() request;
  final Widget Function() builder;
  final void Function(dynamic) onSuccess;
  final Color color;

  const ServiceLoader({
    super.key,
    required this.request,
    required this.onSuccess,
    required this.builder,
    this.color = Colors.black
  });

  @override
  State<ServiceLoader> createState() => _ServiceLoaderState();
}

class _ServiceLoaderState extends State<ServiceLoader> {
  ServiceLoaderState _state = ServiceLoaderState.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {

    setState(() {
      _state = ServiceLoaderState.loading;
    });

    try {
      Response res = await widget.request();

      if (!mounted) return;

      if (res.statusCode! >= 200 && res.statusCode! < 300) {
        widget.onSuccess(res.data);
        setState(() {
          _state = ServiceLoaderState.success;
        });
      } else {
        setState(() {
          _state = ServiceLoaderState.error;
          _errorMessage = res.statusMessage;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _state = ServiceLoaderState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    if (_errorMessage != null) print(_errorMessage);
    
    switch (_state) {
      case ServiceLoaderState.loading:
        return Center(
          child: CupertinoActivityIndicator(color: widget.color),
        );

      case ServiceLoaderState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง...'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _load,
                child: const Text(
                    "รีเฟรช",
                  style: TextStyle(
                    color: AppColors.primaryColor
                  ),
                ),
              ),
            ],
          ),
        );

      case ServiceLoaderState.success:
        return widget.builder();
    }
  }
}
