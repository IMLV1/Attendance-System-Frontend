import 'package:attendance_system/core/data/api/api.dart';
import 'package:attendance_system/core/data/entities/config_attendance_time_model.dart';
import 'package:dio/dio.dart';

class ConfigAttendanceTimeApi extends Api {

  Future<Response<dynamic>> getData() async {
    return dio.get('/system/config/attendance_time/get');
  }

  Future<Response<dynamic>> update(ConfigAttendanceTimeModel data) async {
    return dio.put(
        '/system/config/attendance_time/update',
        data: {
          'auto-checkout': data.autoCheckout,
          'cutoff-time': {
            'hour': data.cutoffTime.hour,
            'minute': data.cutoffTime.minute,
          },
          'check-in-time': {
            'hour': data.checkInTime.hour,
            'minute': data.checkInTime.minute,
          },
          'check-out-time': {
            'hour': data.checkOutTime.hour,
            'minute': data.checkOutTime.minute,
          },
          'check-in-leave-time': {
            'hour': data.checkInLeaveTime.hour,
            'minute': data.checkInLeaveTime.minute,
          },
          'check-out-leave-time': {
            'hour': data.checkOutLeaveTime.hour,
            'minute': data.checkOutLeaveTime.minute,
          },
        }
    );
  }
}
