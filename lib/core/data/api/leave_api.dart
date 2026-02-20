import 'package:attendance_system/core/network/api_client.dart';
import 'package:attendance_system/features/main_feature/leave_request/date_select.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LeaveRequestService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> create(String leaveType, LeaveDate leaveDate, String remark, List<PlatformFile> files) async {

    List<MultipartFile> multipartFiles = [];

    for (var file in files) {
      if (kIsWeb) {
        multipartFiles.add(
          MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        if (file.path != null) {
          multipartFiles.add(
            await MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          );
        }
      }
    }

    var formData = FormData.fromMap({
      'leave-type': leaveType,
      'date-from': leaveDate.fromDate!.toIso8601String(),
      'date-to': leaveDate.toDate!.toIso8601String(),
      'from-date-morning': leaveDate.fromDateMorning,
      'to-date-morning': leaveDate.toDateMorning,
      'remark': remark,
      'files': multipartFiles
    });


    return dio.post('/api/leave_request/create',
      data: formData
    );
  }
}


