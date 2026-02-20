import 'package:attendance_system/core/data/api/api.dart';
import 'package:attendance_system/core/data/entities/config_attendance_request_model.dart';
import 'package:dio/dio.dart';

class ConfigAttendanceRequestApi extends Api {

  Future<Response<dynamic>> getData() async {
    return dio.get('/system/config/attendance_request/get');
  }

  Future<Response<dynamic>> update(ConfigAttendanceRequestModel data) async {
    return dio.put(
      '/system/config/attendance_request/update',
      data: {
        'request-need-signature': data.requestNeedSignature,
        'approve-need-signature': data.approveNeedSignature,
        'specify-approval-reason': data.specifyApprovalReason,
        'specify-remark': data.specifyRemark,
        'required-remark': data.requiredRemark,
        'evidence-file': data.evidenceFile,
        'required-evidence-file': data.requiredEvidenceFile,
      }
    );
  }
}
