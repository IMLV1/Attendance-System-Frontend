import 'package:attendance_system/shared/theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ServiceState { loading, success, error }

class ServiceLoader extends StatefulWidget {
  final Future<Response> Function() request;
  final Widget Function() builder;
  final void Function(dynamic) onSuccess;

  const ServiceLoader({
    super.key,
    required this.request,
    required this.onSuccess,
    required this.builder,
  });

  @override
  State<ServiceLoader> createState() => _ServiceLoaderState();
}

class _ServiceLoaderState extends State<ServiceLoader> {
  ServiceState _state = ServiceState.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {

    setState(() {
      _state = ServiceState.loading;
    });

    try {
      Response res = await widget.request();

      if (!mounted) return;

      if (res.statusCode == 200) {
        widget.onSuccess(res.data);
        setState(() {
          _state = ServiceState.success;
        });
      } else {
        setState(() {
          _state = ServiceState.error;
          _errorMessage = res.statusMessage;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _state = ServiceState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case ServiceState.loading:
        return const Center(
          child: CupertinoActivityIndicator(),
        );

      case ServiceState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง...'),
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

      case ServiceState.success:
        return widget.builder();
    }
  }
}
