import 'package:attendance_system/core/data/api/api.dart';

import 'package:dio/dio.dart';

class ApiHandler {
  final Future<Response> Function() request;
  final void Function(Map<String, dynamic> error)? onError;
  final void Function(Map<String, dynamic> data)? onSuccess;

  const ApiHandler({required this.request, this.onError, this.onSuccess});

  Future<void> call() async {

    try {
      Response res = await request();

      if (res.statusCode! >= 200 && res.statusCode! < 300) {
        onSuccess?.call(res.data);
      } else {
        onError?.call(res.data);
      }

    } catch (e) {
      onError?.call({'error': e.toString()});
    }
  }
}