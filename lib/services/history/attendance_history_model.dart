
//item
class AttendanceHistoryModel {
  final DateTime date;
  final String? dow;
  final String? checkIn;
  final String? checkOut;

  AttendanceHistoryModel(
  {
    required this.date,
    this.dow,
    this.checkIn,
    this.checkOut
  });

  //// factory — ต้องเขียน return เอง
  //from JSON -> Json to object
  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      date: DateTime.parse(json['date'] as String),
      dow: json['dow'] as String?,
      checkIn: json['checkIn']?.toString(),
      checkOut: json['checkOut']?.toString(),
    );
  }

  static List<AttendanceHistoryModel> getList(List<dynamic> list) {
    return list.map((m) => AttendanceHistoryModel.fromJson(m as Map<String, dynamic>)).toList();
  }
}