import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ServiceUpdaterProMaxState { loading, success, error, idle }

class ServiceUpdaterProMax extends StatefulWidget {

  final List<Future<Response>> Function() requests;
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

  Future<void> _load(int reqIndex) async {

    setState(() {
      _states[reqIndex] = ServiceUpdaterProMaxState.loading;
    });

    try {
      Response res = await widget.requests()[reqIndex];
      if (!mounted) return;
      if (res.statusCode! >= 200 && res.statusCode! < 300) {
        setState(() {
          widget.onSuccess?.call(reqIndex, res.data);
          _states[reqIndex] = ServiceUpdaterProMaxState.success;
        });
      } else {
        setState(() {
          widget.onError?.call(reqIndex, {'error': {'type': 1, 'info': res.data}});
          _states[reqIndex] = ServiceUpdaterProMaxState.error;
        });
      }
    } catch (e) {
      if (!mounted) return;

      if (e is DioException && e.response != null) {
        setState(() {
          widget.onError?.call(reqIndex, {'error': {'type': 2, 'info': e.response?.statusMessage ?? 'Unknown error'}});
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
    _states.addAll(List.generate(widget.requests().length, (index) => ServiceUpdaterProMaxState.idle));

    if (widget.fetchOnInit) {
      for (int i = 0; i < widget.requests().length; i++) {
        _load(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return widget.builder(
        _load,
        _getState
    );
  }

}