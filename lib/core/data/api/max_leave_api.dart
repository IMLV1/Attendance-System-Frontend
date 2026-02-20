import 'package:attendance_system/core/data/api/api.dart';
import 'package:attendance_system/core/data/entities/max_leave_model.dart';
import 'package:dio/dio.dart';

class MaxLeaveApi extends Api {

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
