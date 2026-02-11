import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ServiceState { loading, success, error, idle }

class ServiceUpdater extends StatefulWidget {

  final Future<Response> Function() request;
  final Widget Function(
    Function() trigger,
    ServiceState state,
    Widget loadingWidget,
    Widget errorWidget
  ) builder;
  final void Function() onSuccess;
  final Color color;
  final Widget defaultErrorWidget;
  final Widget defaultLoadingWidget;

  const ServiceUpdater({
    super.key,
    required this.request,
    required this.onSuccess,
    required this.builder,
    this.color = Colors.black,
    this.defaultErrorWidget = const SizedBox(),
    this.defaultLoadingWidget = const SizedBox(),
  });

  @override
  State<StatefulWidget> createState() => _ServiceUpdaterState();

}

class _ServiceUpdaterState extends State<ServiceUpdater> {

  ServiceState _state = ServiceState.idle;
  String? _errorMessage;

  Future<void> _load() async {

    setState(() {
      _state = ServiceState.loading;
    });

    try {
      Response res = await widget.request();

      if (!mounted) return;

      if (res.statusCode == 200) {
        widget.onSuccess();
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
    return widget.builder(
      _load,

      _state,

      (_state == ServiceState.loading) ?
      Center(child: CupertinoActivityIndicator(color: widget.color)) : widget.defaultLoadingWidget,

      (_state == ServiceState.error) ?
      Text(
        'เกิดข้อผิดพลาด: กรุณาลองใหม่อีกครั้ง',
        style: TextStyle(
          color: Colors.red
        )
      ) : widget.defaultErrorWidget

    );
  }

}