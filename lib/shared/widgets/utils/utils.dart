import 'dart:math';

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
}