import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

class SignatureService {
  final Dio dio = GetIt.I<ApiClient>().dio;

  Future<Response<dynamic>> get() async {
    return dio.get(
      '/api/signature/get',
      options: Options(responseType: ResponseType.bytes),
    );
  }



  Future<Response<dynamic>> update(Uint8List pngBytes) async {

    FormData formData = FormData.fromMap({
      "signature": MultipartFile.fromBytes(
        pngBytes,
        filename: "signature.png",
        contentType: DioMediaType.parse("image/png"),
      ),
    });

    return dio.put(
      '/api/signature/update',
      data: formData
    );
  }

  Future<Response<dynamic>> clear() async {
    return dio.delete('/api/signature/clear');
  }
}
