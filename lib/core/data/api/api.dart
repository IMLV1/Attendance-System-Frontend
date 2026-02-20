import 'package:attendance_system/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

abstract class Api {
  final Dio dio = GetIt.I<ApiClient>().dio;
}