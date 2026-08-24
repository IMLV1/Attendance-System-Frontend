import 'dart:math';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class Utils {
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'kB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(decimals).replaceAll(RegExp(r'\.?0+$'), '')} ${suffixes[i]}';
  }

  static int generateRandomNumber(int digits) {
    if (digits <= 0) {
      throw ArgumentError('Digits must be greater than 0');
    }

    final random = Random();

    int min = pow(10, digits - 1).toInt();   // smallest number with N digits
    int max = pow(10, digits).toInt() - 1;   // largest number with N digits

    return min + random.nextInt(max - min + 1);
  }

  static Future<Response> mockResponse({int delayed = 200, int statusCode = 200, dynamic data = const {}}) async {

    await Future.delayed(
      Duration(milliseconds: delayed),
    );

    return Response(

      requestOptions: RequestOptions(path: '/mock/data'),
      statusCode: statusCode,
      data: data,
    );
  }

  static String numberFormat(num number) {
    return NumberFormat('#,##0.#').format(number);
  }

  /// จำนวนวันลา — ตัด .0 ทิ้ง แต่คงครึ่งวันไว้ (9.0 -> "9", 9.5 -> "9.5")
  static String formatDays(num days) {
    return NumberFormat('0.#').format(days);
  }
}