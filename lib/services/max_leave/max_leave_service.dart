import 'package:attendance_system/services/max_leave/max_leave_model.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class MaxLeaveService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> getData(String userId) async {
    return dio.get('/system/user_management/leave/quotas/$userId');
  }

  Future<Response<dynamic>> updateMaxLeave(String id, MaxLeaveModel maxLeave) {
    return dio.put(
      '/system/user_management/update_max_leave/$id',
      data: {
        'sick': maxLeave.sick,
        'personal': maxLeave.personal,
        'vacation': maxLeave.vacation,
        'maternity': maxLeave.maternity,
        'paternity': maxLeave.paternity,
        'parental': maxLeave.parental
      },
    );
  }
}
