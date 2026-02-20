


class LeaveRequestModel {
  final String id;
  final String leaveType;
  final DateTime dateStart;
  final bool approve;

  LeaveRequestModel({
    required this.id,
    required this.leaveType,
    required this.dateStart,
    required this.approve
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
        id: json['id'] ?? '',
        leaveType: json['leave-type'] ?? '',
        dateStart: DateTime.tryParse(json['date-start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        approve: json['approved'] ?? false
    );
  }

  static List<LeaveRequestModel> getList(List<dynamic> items) {
    return items.map((m) => LeaveRequestModel.fromJson(
      Map<String, dynamic>.from(m),
    )).toList();
  }
}

class PendingLeaveRequestModel {
  final String id;
  final String leaveType;
  final DateTime dateStart;

  const PendingLeaveRequestModel({
    required this.id,
    required this.leaveType,
    required this.dateStart,
  });

  factory PendingLeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return PendingLeaveRequestModel(
        id: json['id'] ?? '',
        leaveType: json['leave-type'] ?? '',
        dateStart: DateTime.tryParse(json['date-start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<PendingLeaveRequestModel> getList(List<dynamic> items) {
    return items.map((m) => PendingLeaveRequestModel.fromJson(
      Map<String, dynamic>.from(m),
    )).toList();
  }
}
