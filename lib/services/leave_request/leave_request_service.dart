import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class LeaveRequestService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> create(String leaveType) async {
    return dio.post('/leave_request/create',
      data: {
        'leave-type': leaveType,
        'date-from': ''
      }
    );
  }
}
