import 'package:attendance_system/core/data/api/api.dart';
import 'package:attendance_system/core/data/entities/config_leave_model.dart';
import 'package:dio/dio.dart';

class ConfigLeaveApi extends Api {

  Future<Response<dynamic>> getData() async {
    return dio.get('/system/config/leave/get');
  }

  Future<Response<dynamic>> update(ConfigLeaveModel data) async {
    return dio.put(
        '/system/config/leave/update',
        data: {
          'sick': {
            'request-need-signature': data.sick.requestNeedSignature,
            'approve-need-signature': data.sick.approveNeedSignature,
            'allow-retroactive': data.sick.allowRetroactive,
            'specify-remark': data.sick.specifyRemark,
            'required-remark': data.sick.requiredRemark,
            'evidence-file': data.sick.evidenceFile,
            'required-evidence-file': data.sick.requiredEvidenceFile,
          },
          'personal': {
            'request-need-signature': data.personal.requestNeedSignature,
            'approve-need-signature': data.personal.approveNeedSignature,
            'allow-retroactive': data.personal.allowRetroactive,
            'specify-remark': data.personal.specifyRemark,
            'required-remark': data.personal.requiredRemark,
            'evidence-file': data.personal.evidenceFile,
            'required-evidence-file': data.personal.requiredEvidenceFile,
          },
          'vacation': {
            'request-need-signature': data.vacation.requestNeedSignature,
            'approve-need-signature': data.vacation.approveNeedSignature,
            'allow-retroactive': data.vacation.allowRetroactive,
            'specify-remark': data.vacation.specifyRemark,
            'required-remark': data.vacation.requiredRemark,
            'evidence-file': data.vacation.evidenceFile,
            'required-evidence-file': data.vacation.requiredEvidenceFile,
          },
          'maternity': {
            'request-need-signature': data.maternity.requestNeedSignature,
            'approve-need-signature': data.maternity.approveNeedSignature,
            'allow-retroactive': data.maternity.allowRetroactive,
            'specify-remark': data.maternity.specifyRemark,
            'required-remark': data.maternity.requiredRemark,
            'evidence-file': data.maternity.evidenceFile,
            'required-evidence-file': data.maternity.requiredEvidenceFile,
          },
          'paternity': {
            'request-need-signature': data.paternity.requestNeedSignature,
            'approve-need-signature': data.paternity.approveNeedSignature,
            'allow-retroactive': data.paternity.allowRetroactive,
            'specify-remark': data.paternity.specifyRemark,
            'required-remark': data.paternity.requiredRemark,
            'evidence-file': data.paternity.evidenceFile,
            'required-evidence-file': data.paternity.requiredEvidenceFile,
          },
          'parental': {
            'request-need-signature': data.parental.requestNeedSignature,
            'approve-need-signature': data.parental.approveNeedSignature,
            'allow-retroactive': data.parental.allowRetroactive,
            'specify-remark': data.parental.specifyRemark,
            'required-remark': data.parental.requiredRemark,
            'evidence-file': data.parental.evidenceFile,
            'required-evidence-file': data.parental.requiredEvidenceFile,
          },
        }
    );
  }
}
