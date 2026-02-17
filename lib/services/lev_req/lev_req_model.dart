import 'package:file_picker/file_picker.dart';

class LevReqModel {
  final String type;
  final String maihed;
  final List<PlatformFile> file;
  final DateTime dateTime;
  final bool morning;

  const LevReqModel({required this.type, required this.maihed, required this.file, required this.dateTime, required this.morning});
}